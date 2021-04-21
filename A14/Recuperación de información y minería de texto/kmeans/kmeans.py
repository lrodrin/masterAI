import json
import re

import nltk
import pandas as pd
from nltk.stem.snowball import SnowballStemmer
from sklearn.cluster import KMeans
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import silhouette_score
from tabulate import tabulate

pd.set_option('display.max_columns', None)

def create_inputData(json_file):
    """
    Create input data as dataframe
    """
    dict_books = json.load(json_file)
    df_books = pd.DataFrame.from_dict(dict_books)
    df_books = df_books.dropna()    # remove null values in df
    return df_books


def tokenize_and_stem(text):
    """
    Tokenization and stemming
    """
    # first tokenize by sentence, then by word to ensure that punctuation is caught as it's own token
    tokens = [word for sent in nltk.sent_tokenize(text) for word in nltk.word_tokenize(sent)]
    filtered_tokens = []
    # filter out any tokens not containing letters (e.g., numeric tokens, raw punctuation)
    for token in tokens:
        if re.search('[a-zA-Z]', token):
            filtered_tokens.append(token)
    stems = [stemmer.stem(t) for t in filtered_tokens]
    return stems


def tokenize_only(text):
    """
    Only tokenization
    """
    tokens = [word.lower() for sent in nltk.sent_tokenize(text) for word in nltk.word_tokenize(sent)]
    filtered_tokens = []
    for token in tokens:
        if re.search('[a-zA-Z]', token):
            filtered_tokens.append(token)
    return filtered_tokens


if __name__ == '__main__':
    books = open("../books/books.json", "r")
    df = create_inputData(books)    # create input data as dataframe

    # print df as table
    print(tabulate(df.head(), headers='keys', tablefmt='psql'))
    print(df.head().to_latex(index=False))  # convert table to latex format

    # select titles from dataframe
    titles = df["title"].to_list()
    print(titles[:10])  # first 10 titles

    language = "english"
    # nltk's English stopwords as variable called 'stopwords'
    stopwords = nltk.corpus.stopwords.words(language)
    # nltk's SnowballStemmer as variabled 'stemmer'
    stemmer = SnowballStemmer(language)
    print(stopwords[:10])  # first 10 stopwords

    # tf-idf matrix
    tfidf_vectorizer = TfidfVectorizer(stop_words=stopwords, use_idf=True, tokenizer=tokenize_and_stem,
                                       ngram_range=(1, 3))
    # tokenize and build coded vocabulary
    tfidf_matrix = tfidf_vectorizer.fit_transform(titles)
    # print(tfidf_matrix)
    print(tfidf_matrix.shape)

    # vocabulary
    terms = tfidf_vectorizer.get_feature_names()
    print(terms[:20])  # first 20 terms

    # nCategories
    # categories = df.groupby('category').size()
    # print(categories)

    # K-Means clustering
    num_clusters = 40
    km = KMeans(n_clusters=num_clusters)
    km.fit(tfidf_matrix)
    clusters = km.labels_.tolist()

    # new df with titles and clusters
    frame = pd.DataFrame({'title': titles, 'cluster': clusters}, index=[clusters], columns=['title', 'cluster'])
    print(tabulate(frame.head(), headers='keys', tablefmt='psql'))
    print(frame.head().to_latex(index=False))  # convert table to latex format
    frame.to_csv("clusters.csv", index=False)    # save titles per cluster

    # new two vocabularies: stemmed and tokenized
    totalvocab_stemmed = []
    totalvocab_tokenized = []
    for i in titles:
        allwords_stemmed = tokenize_and_stem(i)  # for each item in 'titles', tokenize/stem
        totalvocab_stemmed.extend(allwords_stemmed)  # extend the 'totalvocab_stemmed' list

        allwords_tokenized = tokenize_only(i)
        totalvocab_tokenized.extend(allwords_tokenized)

    vocab_frame = pd.DataFrame({'words': totalvocab_tokenized}, index=totalvocab_stemmed)
    print(tabulate(vocab_frame.head(), headers='keys', tablefmt='psql'))
    print(vocab_frame.head().to_latex(index=False))  # convert table to latex format
    print('There are ' + str(vocab_frame.shape[0]) + ' items in vocab_frame')

    print("Top terms per cluster:")
    # sort cluster centers by proximity to centroid
    order_centroids = km.cluster_centers_.argsort()[:, ::-1]

    with open('top_terms_per_cluster.txt', 'w') as out_file:    # top terms per cluster
        for i in range(num_clusters):
            print("Cluster {} words:".format(i), end='', file=out_file)
            for ind in order_centroids[i, :10]:  # replace 10 with n words per cluster
                print(' {}'.format(vocab_frame.loc[terms[ind].split(' ')].values.tolist()[0][0]), end=',',
                      file=out_file)

            print(file=out_file)
            print(file=out_file)

            print("Cluster {} titles:".format(i), end='', file=out_file)
            for title in frame.loc[i]['title'].values.tolist():
                print(' {},'.format(title), end='', file=out_file)

            print(file=out_file)
            print(file=out_file)

    # Evaluation with silhouette coefficient
    silhouette_coefficient = silhouette_score(tfidf_matrix, labels=km.predict(tfidf_matrix))
    print(silhouette_coefficient)
