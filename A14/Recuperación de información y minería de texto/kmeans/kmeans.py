import json
import re
import nltk
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from nltk.stem.snowball import SnowballStemmer
from sklearn.decomposition import PCA
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from tabulate import tabulate

# configurations
plt.rcParams['figure.figsize'] = (16, 9)
plt.style.use('ggplot')
pd.set_option('display.max_columns', None)


def tokenize_and_stem(text):
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
    # first tokenize by sentence, then by word to ensure that punctuation is caught as it's own token
    tokens = [word.lower() for sent in nltk.sent_tokenize(text) for word in nltk.word_tokenize(sent)]
    filtered_tokens = []
    # filter out any tokens not containing letters (e.g., numeric tokens, raw punctuation)
    for token in tokens:
        if re.search('[a-zA-Z]', token):
            filtered_tokens.append(token)
    return filtered_tokens


if __name__ == '__main__':
    # create df
    books = open("../books/books.json", "r")
    dict_books = json.load(books)
    df = pd.DataFrame.from_dict(dict_books)

    # remove null values in df
    df = df.dropna()

    # print df as table
    print(tabulate(df.head(), headers='keys', tablefmt='psql'))
    print(df.head().to_latex(index=False))  # convert table to latex format

    # select titles and their values
    titles = df["title"].to_list()  # another use-case is use the descriptions
    print(titles[:10])  # first 10 titles

    # stopwords, stemming, and tokenizing
    # nltk's English stopwords as variable called 'stopwords'
    stopwords = nltk.corpus.stopwords.words('english')
    # nltk's SnowballStemmer as variabled 'stemmer'
    stemmer = SnowballStemmer("english")
    print(stopwords[:10])   # first 10 stopwords

    # tf-idf matrix
    # define vectorizer parameters
    tfidf_vectorizer = TfidfVectorizer(max_features=200000, stop_words=stopwords, use_idf=True,
                                       tokenizer=tokenize_and_stem, ngram_range=(1, 3))
    tfidf_matrix = tfidf_vectorizer.fit_transform(titles)  # fit the vectorizer to titles
    # print(tfidf_matrix)
    print(tfidf_matrix.shape)

    # nCategories
    categories = df.groupby('category').size()
    # print(categories)

    # K-Means clustering
    num_clusters = 40
    km = KMeans(n_clusters=num_clusters)
    km.fit(tfidf_matrix)
    clusters = km.labels_.tolist()

    # new df with titles and clusters
    new_df = pd.DataFrame({'title': titles, 'cluster': clusters}, index=[clusters], columns=['title', 'cluster'])
    print(tabulate(new_df.head(), headers='keys', tablefmt='psql'))
    print(new_df.head().to_latex(index=False))  # convert table to latex format

    # # terms is just a list of the features used in the tf-idf matrix
    # terms = tfidf_vectorizer.get_feature_names()

    #
    # totalvocab_stemmed = []
    # totalvocab_tokenized = []
    # for i in titles:
    #     allwords_stemmed = tokenize_and_stem(i)  # for each item in 'titles', tokenize/stem
    #     totalvocab_stemmed.extend(allwords_stemmed)  # extend the 'totalvocab_stemmed' list
    #
    #     allwords_tokenized = tokenize_only(i)
    #     totalvocab_tokenized.extend(allwords_tokenized)
    #
    # vocab_frame = pd.DataFrame({'words': totalvocab_tokenized}, index=totalvocab_stemmed)
    # print('There are ' + str(vocab_frame.shape[0]) + ' items in vocab_frame')
    #
    # # print("Top terms per cluster:")
    # # sort cluster centers by proximity to centroid
    # order_centroids = km.cluster_centers_.argsort()[:, ::-1]
    #
    # for i in range(num_clusters):
    #     print("Cluster {} words:".format(i), end='')
    #
    #     for ind in order_centroids[i, :10]:  # replace 10 with n words per cluster
    #         print(' {}'.format(vocab_frame.loc[terms[ind].split(' ')].values.tolist()[0][0]), end=',')
    #     print()
    #     print()
    #
    #     print("Cluster {} titles:".format(i), end='')
    #     for title in frame.loc[i]['title'].values.tolist():
    #         print(' {},'.format(title), end='')
    #     print()
    #     print()

# http://brandonrose.org/clustering

    # Evaluation
    # TODO evaluation https://sanjayasubedi.com.np/nlp/nlp-with-python-document-clustering/