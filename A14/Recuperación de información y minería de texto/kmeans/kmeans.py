import json
import re
import nltk
import pandas as pd
import matplotlib.pyplot as plt

from nltk.stem.snowball import SnowballStemmer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.cluster import KMeans
from sklearn.manifold import MDS

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


def vocab(text):
    vocab_stemmed = []
    vocab_tokenized = []
    for i in text:
        allwords_stemmed = tokenize_and_stem(i)  # for each item in 'text', tokenize/stem
        vocab_stemmed.extend(allwords_stemmed)  # extend the 'vocab_stemmed' list

        allwords_tokenized = tokenize_only(i)
        vocab_tokenized.extend(allwords_tokenized)

    return vocab_stemmed, vocab_tokenized


def top_terms(model, nclusters, df_vocab, frame):
    # sort cluster centers by proximity to centroid
    order_centroids = model.cluster_centers_.argsort()[:, ::-1]

    for i in range(nclusters):
        print("Cluster {} words:".format(i), end='')

        for ind in order_centroids[i, :20]:  # replace 20 with n words per cluster
            print(' {}'.format(df_vocab.loc[terms[ind].split(' ')].values.tolist()[0][0]), end=',')
        print()
        print()

        print("Cluster {} titles:".format(i), end='')
        for title in frame.loc[i]['title'].values.tolist():
            print(' {},'.format(title), end='')
        print()
        print()


if __name__ == '__main__':
    # create df
    books = open("../books/books.json", "r")
    dict_books = json.load(books)
    df = pd.DataFrame.from_dict(dict_books)

    # remove null values from df
    df = df.dropna()

    # order df by rating
    df = df.sort_values("rating")
    print(df)

    titles = df["title"].to_list()
    synopses = df["description"].to_list()
    ranks = df["rating"].to_list()
    # print(titles[:10])

    # stopwords, stemming, and tokenizing
    # load nltk's English stopwords and SnowballStemmer
    stopwords = nltk.corpus.stopwords.words('english')
    stemmer = SnowballStemmer("english")
    # print(stopwords)

    totalvocab_stemmed, totalvocab_tokenized = vocab(synopses)
    vocab_frame = pd.DataFrame({'words': totalvocab_tokenized}, index=totalvocab_stemmed)
    print('There are ' + str(vocab_frame.shape[0]) + ' items in vocabulary frame')

    # Tf-idf and document similarity
    # define vectorizer parameters
    tfidf_vectorizer = TfidfVectorizer(max_df=0.8, max_features=200000, min_df=0.2, stop_words='english', use_idf=True,
                                       tokenizer=tokenize_and_stem, ngram_range=(1, 3))

    tfidf_matrix = tfidf_vectorizer.fit_transform(synopses)  # fit the vectorizer to synopses
    print(tfidf_matrix.shape)

    terms = tfidf_vectorizer.get_feature_names()

    dist = 1 - cosine_similarity(tfidf_matrix)
    # print(dist)

    # K-Means clustering
    num_clusters = 5
    kmeans = KMeans(n_clusters=num_clusters)
    kmeans.fit(tfidf_matrix)
    clusters = kmeans.labels_.tolist()

    books = {'title': titles, 'rank': ranks, 'synopsis': synopses, 'cluster': clusters}
    df_clusters = pd.DataFrame(books, index=[clusters], columns=['rank', 'title', 'cluster'])
    print(df_clusters['cluster'].value_counts())  # number of books per cluster (clusters from 0 to 4))

    print("Top terms per cluster:")
    top_terms(kmeans, num_clusters, vocab_frame, df_clusters)

    # PLOT
    # set up colors per clusters using a dict
    cluster_colors = {0: '#1b9e77', 1: '#d95f02', 2: '#7570b3', 3: '#e7298a', 4: '#66a61e'}

    # set up cluster names using a dict
    cluster_names = {0: 'world, new, life',
                     1: 'time, books, makes',
                     2: 'years, lives, work',
                     3: 'only, family, just',
                     4: 'loved, story, ways'}

    MDS()

    # convert two components as we're plotting points in a two-dimensional plane
    # "precomputed" because we provide a distance matrix
    # we will also specify `random_state` so the plot is reproducible.
    mds = MDS(n_components=2, dissimilarity="precomputed", random_state=1)

    pos = mds.fit_transform(dist)  # shape (n_components, n_samples)

    xs, ys = pos[:, 0], pos[:, 1]

    # create data frame that has the result of the MDS plus the cluster numbers and titles
    df_plot = pd.DataFrame(dict(x=xs, y=ys, label=clusters, title=titles))

    # group by cluster
    groups = df_plot.groupby('label')

    # set up plot
    fig, ax = plt.subplots(figsize=(17, 9))  # set size
    ax.margins(0.05)  # Optional, just adds 5% padding to the autoscaling

    # iterate through groups to layer the plot
    # note that I use the cluster_name and cluster_color dicts with the 'name' lookup to return the appropriate color/label
    for name, group in groups:
        ax.plot(group.x, group.y, marker='o', linestyle='', ms=12,
                label=cluster_names[name], color=cluster_colors[name],
                mec='none')
        ax.set_aspect('auto')
        ax.tick_params(
            axis='x',  # changes apply to the x-axis
            which='both',  # both major and minor ticks are affected
            bottom='off',  # ticks along the bottom edge are off
            top='off',  # ticks along the top edge are off
            labelbottom='off')
        ax.tick_params(
            axis='y',  # changes apply to the y-axis
            which='both',  # both major and minor ticks are affected
            left='off',  # ticks along the bottom edge are off
            top='off',  # ticks along the top edge are off
            labelleft='off')

    ax.legend(numpoints=1)  # show legend with only 1 point

    plt.show()  # show the plot
    # plt.savefig('clusters.png', dpi=200)
    plt.close()

# http://brandonrose.org/clustering
