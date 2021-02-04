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
userCount = rddF3.map(lambda x: (x[1], 1)).reduceByKey(lambda x, y: x + y)
print(userCount.max(key=lambda x: x[1]))

# quitaNoAlfa and rmSpaces
rddF3Clean = rddF3.flatMap(lambda x: x[0].split(",")) \
    .map(quitaNoAlfa) \
    .map(rmSpaces)

# La palabra que más veces aparece en los tweets es
wordsCount = rddF3Clean.flatMap(lambda x: x.split(" ")).map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y)
print(wordsCount.max(key=lambda x: x[1]))

# remove stopwords
stopwords = ['como', 'pero', 'o', 'al', 'mas', 'esta', 'le', 'cuando', 'eso', 'su', 'porque', 'd', 'del', 'los', 'mi', 'si', 'las', 'una', 'q', 'ya', 'yo', 'tu', 'el', 'ella', 'a', 'ante', 'bajo', 'cabe', 'con', 'contra', 'de', 'desde', 'en', 'entre', 'hacia', 'hasta', 'para', 'por', 'segun', 'sin', 'so', 'sobre', 'tras', 'que', 'la', 'no', 'y', 'el', 'me', 'es', 'te', 'se', 'un', 'lo']
rddF4 = rddF3Clean.flatMap(lambda x: x.split(" ")) \
    .filter(lambda x: x and x not in stopwords)

# La segunda palabra que más veces aparece en los tweets es
words2Count = rddF4.flatMap(lambda x: x.split(" ")).map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y)
print(words2Count.sortBy(lambda x: x[1], ascending=False).take(2)) # first and second

