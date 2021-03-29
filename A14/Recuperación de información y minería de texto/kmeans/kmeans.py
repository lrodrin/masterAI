import csv
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.feature_extraction.text import TfidfVectorizer

data = pd.read_csv("books.csv", usecols=[1, 3])
print(data.shape)
print(list(data.columns))

categories = []
titles = []
with open("books.csv", encoding="utf-8") as csvfobj:  # csvfobj=object
    readCSV = csv.reader(csvfobj, delimiter=',')  # as each field is separated by ','
    # if file is not in the same project, add file path
    # Reader object creates matrix
    next(readCSV, None)  # skip the headers
    title = []
    # to iterate through file row by row
    for row in readCSV:
        category = row[1]
        title = row[3]

        # adding to the list
        categories.append(category)
        titles.append(title)

print(categories)
print(titles)

tfidfvect = TfidfVectorizer(stop_words='english')
X = tfidfvect.fit_transform(titles)

first_vector = X[0]

dataframe = pd.DataFrame(first_vector.T.todense(), index=tfidfvect.get_feature_names(), columns=["tfidf"])
dataframe.sort_values(by=["tfidf"], ascending=False)

num = 3
kmeans = KMeans(n_clusters = num, init = 'k-means++', max_iter = 500, n_init = 1)
kmeans.fit(X)
print(kmeans.cluster_centers_) #This will print cluster centroids as tf-idf vectors

centroids= kmeans.cluster_centers_
data = pd.read_csv("books.csv", usecols=[0, 2])
plt.scatter(data['category_c'], data['title_c'], c=kmeans.labels_.astype(float), s=50, alpha=0.5)
plt.scatter(centroids[:, 0], centroids[:, 1], c='red', s=50)
plt.show()

X = tfidfvect.transform(["Data Structures and Algorithms"])
labels = kmeans.predict(X)
print(labels)

# https://iq.opengenus.org/implement-document-clustering-python/

# per trobar K https://medium.com/pursuitnotes/k-means-clustering-model-in-6-steps-with-python-35b532cfa8ad