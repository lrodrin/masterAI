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
userCount = rddF3.map(lambda x: (x[1], 1)).reduceByKey(lambda x, y: x+y)
print(userCount.max(key=lambda x: x[1]))




