import json

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.feature_extraction.text import TfidfVectorizer

# books dataset
books = open("../books/books2.json", "r")
dict_books = json.load(books)

# create books df
df = pd.DataFrame.from_dict(dict_books)
print(df)

# remove categories that only appear once
uniqueCategories = ["Academic", "Adult Fiction", "Crime", "Cultural", "Erotica", "Novels", "Paranormal", "Parenting",
                    "Short Stories", "Suspense"]

df = df[~df['category'].isin(uniqueCategories)]

# save df to csv
df.to_csv("books2.csv", index=False, sep=",")

data = pd.read_csv("books2.csv")
# remove null values data
data = data.dropna()

tfidf = TfidfVectorizer(
    min_df=5,
    max_df=0.95,
    max_features=8000,
    stop_words='english'
)
tfidf.fit(data['title'])
text = tfidf.transform(data['title'])

clusters = KMeans(n_clusters=5, init = 'k-means++', max_iter = 500, n_init = 1).fit_predict(text)

# def plot_tsne_pca(data, labels):
#     max_label = max(labels)
#     max_items = np.random.choice(range(data.shape[0]), size=3000)
#
#     pca = PCA(n_components=2).fit_transform(data[max_items, :].todense())
#     tsne = TSNE().fit_transform(PCA(n_components=50).fit_transform(data[max_items, :].todense()))
#
#     idx = np.random.choice(range(pca.shape[0]), size=300)
#     label_subset = labels[max_items]
#     label_subset = [cm.hsv(i / max_label) for i in label_subset[idx]]
#
#     f, ax = plt.subplots(1, 2, figsize=(14, 6))
#
#     ax[0].scatter(pca[idx, 0], pca[idx, 1], c=label_subset)
#     ax[0].set_title('PCA Cluster Plot')
#
#     ax[1].scatter(tsne[idx, 0], tsne[idx, 1], c=label_subset)
#     ax[1].set_title('TSNE Cluster Plot')
#     plt.show()
#
#
# plot_tsne_pca(text, clusters)


def get_top_keywords(data, clusters, labels, n_terms):
    df = pd.DataFrame(data.todense()).groupby(clusters).mean()

    for i, r in df.iterrows():
        print('\nCluster {}'.format(i))
        print(','.join([labels[t] for t in np.argsort(r)[-n_terms:]]))


get_top_keywords(text, clusters, tfidf.get_feature_names(), 10)

# Start with one review:
text2 = df.description[0]

# Create and generate a word cloud image:
from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator
wordcloud = WordCloud().generate(text2)

# Display the generated image:
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis("off")
plt.show()

# test with diferent number of clusters
cls = KMeans(n_clusters=40, random_state=0)
cls.fit(text)

# predict cluster labels for new dataset
cls.predict(text)

# to get cluster labels for the dataset used while
# training the model (used for models that does not
# support prediction on new dataset).
print(cls.labels_)

# reduce the features to 2D
pca = PCA(n_components=2, random_state=0)
reduced_features = pca.fit_transform(text.toarray())

# reduce the cluster centers to 2D
reduced_cluster_centers = pca.transform(cls.cluster_centers_)

plt.scatter(reduced_features[:,0], reduced_features[:,1], c=cls.predict(text))
plt.scatter(reduced_cluster_centers[:, 0], reduced_cluster_centers[:,1], marker='x', s=150, c='b')
plt.show()

from sklearn.metrics import silhouette_score
print(silhouette_score(text, labels=cls.predict(text)))

# https://sanjayasubedi.com.np/nlp/nlp-with-python-document-clustering/
# https://www.datacamp.com/community/tutorials/wordcloud-python