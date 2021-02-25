import re

from pyspark import SparkConf, SparkContext
from methods import *

# Configura Spark
conf = SparkConf()
sc = SparkContext(conf=conf)
sc.setLogLevel("ERROR")

# Crea una lista con la ruta a cada fichero
path_to_zip_file = "./ficheros-práctica-evaluable-spark.zip"
workDir = "./30/01/"

if not os.path.isdir(workDir):
    unzip(path_to_zip_file)

filesList = unbz2(workDir)

# Crea un RDD con las rutas de los ficheros
rddF = sc.parallelize(filesList)

# Crea RDD con los tuits
rddF2 = rddF.map(lambda x: readFiles(x))
rddF3 = rddF2.flatMap(lambda xs: [(x[0], x[1]) for x in xs])
# print(rddF3.collect())

# El usuario que más ha twitteado es
userCount = rddF3.map(lambda x: (x[0], 1)).reduceByKey(lambda x, y: x + y)
print(userCount.max(key=lambda x: x[1]))

# quitaNoAlfa and rmSpaces
rddF3Clean = rddF3.flatMap(lambda x: x[1].split(",")) \
    .map(quitaNoAlfa) \
    .map(rmSpaces)

# La palabra que más veces aparece en los tweets es
wordsCount = rddF3Clean.flatMap(lambda x: x.split(" ")).map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y)
print(wordsCount.max(key=lambda x: x[1]))

# remove stopwords
stopwords = ['como', 'pero', 'o', 'al', 'mas', 'esta', 'le', 'cuando', 'eso', 'su', 'porque', 'd', 'del', 'los', 'mi',
             'si', 'las', 'una', 'q', 'ya', 'yo', 'tu', 'el', 'ella', 'a', 'ante', 'bajo', 'cabe', 'con', 'contra',
             'de', 'desde', 'en', 'entre', 'hacia', 'hasta', 'para', 'por', 'segun', 'sin', 'so', 'sobre', 'tras',
             'que', 'la', 'no', 'y', 'el', 'me', 'es', 'te', 'se', 'un', 'lo']

rddF4 = rddF3Clean.flatMap(lambda x: x.split(" ")) \
    .filter(lambda x: x and x not in stopwords)

# La segunda palabra que más veces aparece en los tweets es
words2Count = rddF4.flatMap(lambda x: x.split(" ")).map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y)
print(words2Count.sortBy(lambda x: x[1], ascending=False).take(2))  # first and second

# filter users that write hashtags
rddF5 = rddF3.filter(lambda x: '#' in x[1])

# alcance
hashtags = rddF5.flatMap(lambda x: x[1].split(","))  # hashtags
hashtagsCount = hashtags.flatMap(lambda x: x.split(" ")).map(lambda x: (x.lower(), 1)).reduceByKey(lambda x, y: x + y) \
    .filter(lambda x: '#' in x[0])

rddF6 = hashtagsCount.sortBy(lambda x: x[1], ascending=False)
rddF7 = rddF5.flatMapValues(sacaHashtags)
print(rddF6.collect())
print(rddF7.collect())

rdd = sc.parallelize([("ff", 45), ("cuandomedrogo", 8), ("fb", 7)])
rdd2 = sc.parallelize([("ff", "AraceliMasArte"), ("ff", "Ositoosito147"), ("fb", "Ositoosito147")])
print(rdd.join(rdd2).collect())
# Gives [('red', (20, 40)), ('red', (20, 50)), ('red', (30, 40)), ('red', (30, 50))]
