from pyspark import SparkConf, SparkContext

from methods import uncompress

# Configura Spark
conf = SparkConf()
sc = SparkContext(conf=conf)
sc.setLogLevel("ERROR")

path_to_zip_file = "./ficheros-práctica-evaluable-spark.zip"
files_path = uncompress(path_to_zip_file)  # Crea una lista con la ruta a cada fichero
rddFiles = sc.parallelize(files_path)  # Crea un RDD con las rutas de los ficheros
print(rddFiles.collect())
