import re

from pyspark import SparkConf, SparkContext
from methods import *

# Configura Spark
conf = SparkConf()
sc = SparkContext(conf=conf)
sc.setLogLevel("ERROR")

# Crea una lista con la ruta a cada fichero
path_to_zip_file = "./ficheros-práctica-evaluable-spark-actualizados.zip"
workDir = "./30/"

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
print("El usuario que más ha twitteado es {}".format(userCount.max(key=lambda x: x[1])))

# quitaNoAlfa and rmSpaces
rddF3Clean = rddF3.flatMap(lambda x: x[1].split(",")) \
    .map(quitaNoAlfa) \
    .map(rmSpaces)

# La palabra que más veces aparece en los tweets es
wordsCount = rddF3Clean.flatMap(lambda x: x.split(" ")).map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y)
print("La palabra que más veces aparece en los tweets es {}".format(wordsCount.max(key=lambda x: x[1])))

# Remove stopwords
stopwords = ['como', 'pero', 'o', 'al', 'mas', 'esta', 'le', 'cuando', 'eso', 'su', 'porque', 'd', 'del', 'los', 'mi',
             'si', 'las', 'una', 'q', 'ya', 'yo', 'tu', 'el', 'ella', 'a', 'ante', 'bajo', 'cabe', 'con', 'contra',
             'de', 'desde', 'en', 'entre', 'hacia', 'hasta', 'para', 'por', 'segun', 'sin', 'so', 'sobre', 'tras',
             'que', 'la', 'no', 'y', 'el', 'me', 'es', 'te', 'se', 'un', 'lo']

rddF4 = rddF3Clean.flatMap(lambda x: x.split(" ")) \
    .filter(lambda x: x and x not in stopwords)

# La segunda palabra que más veces aparece en los tweets es
words2Count = rddF4.flatMap(lambda x: x.split(" ")).map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y)
print("Las palabras que más veces aparecen en los tweets son {}".format(
    words2Count.sortBy(lambda x: x[1], ascending=False).take(2)))  # first and second

# Filter users that write hashtags
rddF5 = rddF3.filter(lambda x: '#' in x[1])

# alcance for each hashtag
hashtags = rddF5.flatMap(lambda x: x[1].split(","))
hashtagsCount = hashtags.flatMap(lambda x: x.split(" ")).map(lambda x: (x.lower(), 1)) \
    .reduceByKey(lambda x, y: x + y) \
    .filter(lambda x: '#' in x[0]) \
    .sortBy(lambda x: x[1], ascending=False) \
    .map(lambda x: (x[0].replace("#", ""), x[1]))

# [..., ('denisse_alonso', 'bestwishes'), ('denisse_alonso', 'alwaysonmymind'), ('raquelita_jg', 'dormire'), ...]
rddF6 = rddF5.flatMapValues(sacaHashtags).map(lambda x: (x[1], x[0]))
# print(hashtagsCount.collect())
# print(rddF6.collect())

# Join hashtagsCount with rddF6
rddFJoin = hashtagsCount.join(rddF6)
# print(rddFJoin.collect())

# El usuario cuyos hashtags utilizados sumen el mayor alcance es
print("El usuario cuyos hashtags utilizados sumen el mayor alcance es {}".format(
    rddFJoin.map(lambda x: (x[1][1], x[1][0])).reduceByKey(lambda x1, x2: x1 + x2).sortBy(lambda x: x[1], ascending=False).take(1)))

# hashtag con alcance igual a 1
rddF7 = hashtagsCount.filter(lambda x: x[1] == 1)
# print(rddF7.collect())

# Join rddF7 with rddF6
rddFJoin = rddF7.join(rddF6)
# print(rddFJoin.collect())

# El usuario que más hashtags inútiles han creado es
print("El usuario que más hashtags inútiles han creado es {}".format(
    rddFJoin.map(lambda x: (x[1][1], 1)).groupByKey().map(lambda p: (p[0], sum(p[1]))).sortBy(lambda x: x[1], ascending=False).take(1)))

# Join hashtagsCount with rddF6
rddFJoin = hashtagsCount.join(rddF6).reduceByKey(lambda x, y: x)
# print(rddFJoin.collect())

# El usuario que ha creado (utilizado por primera vez) hashtags con mayor impacto es
print("El usuario que ha creado (utilizado por primera vez) hashtags con mayor impacto es {}".format(
    rddFJoin.map(lambda x: (x[1][1], x[1][0])).reduceByKey(lambda x1, x2: x1 + x2).sortBy(lambda x: x[1], ascending=False).take(1)))
