import json
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.feature_extraction.text import TfidfVectorizer

# create df
books = open("../books/books.json", "r")
dict_books = json.load(books)
df = pd.DataFrame.from_dict(dict_books)

# remove null values from df
df = df.dropna()

# save df to csv
df.to_csv("books.csv", index=False, sep=",", encoding="utf-8")

# feature extraction
vec = TfidfVectorizer(stop_words='english')
vec.fit(df['title'])
features = vec.transform(df['title'])

# model training
cls = KMeans(n_clusters=40, random_state=0)
cls.fit(features)

# clusters = KMeans(n_clusters=5, init = 'k-means++', max_iter = 500, n_init = 1).fit_predict(text)
#

#
#
# def get_top_keywords(data, clusters, labels, n_terms):
#     df = pd.DataFrame(data.todense()).groupby(clusters).mean()
#
#     for i, r in df.iterrows():
#         print('\nCluster {}'.format(i))
#         print(','.join([labels[t] for t in np.argsort(r)[-n_terms:]]))
#
#
# get_top_keywords(text, clusters, tfidf.get_feature_names(), 10)
#
# # Start with one review:
# text2 = df.description[0]
#
# # Create and generate a word cloud image:
# from wordcloud import WordCloud, STOPWORDS, ImageColorGenerator
# wordcloud = WordCloud().generate(text2)
#
# # Display the generated image:
# plt.imshow(wordcloud, interpolation='bilinear')
# plt.axis("off")
# plt.show()
#

#
# # predict cluster labels for new dataset
# cls.predict(text)
#
# # to get cluster labels for the dataset used while
# # training the model (used for models that does not
# # support prediction on new dataset).
# print(cls.labels_)
#
# # reduce the features to 2D
# pca = PCA(n_components=2, random_state=0)
# reduced_features = pca.fit_transform(text.toarray())
#
# # reduce the cluster centers to 2D
# reduced_cluster_centers = pca.transform(cls.cluster_centers_)
#
# plt.scatter(reduced_features[:,0], reduced_features[:,1], c=cls.predict(text))
# plt.scatter(reduced_cluster_centers[:, 0], reduced_cluster_centers[:,1], marker='x', s=150, c='b')
# plt.show()
#
# from sklearn.metrics import silhouette_score
# print(silhouette_score(text, labels=cls.predict(text)))
#
# # https://sanjayasubedi.com.np/nlp/nlp-with-python-document-clustering/
# # https://www.datacamp.com/community/tutorials/wordcloud-python