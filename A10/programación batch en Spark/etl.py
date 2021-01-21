import bz2
import json
import os
import tokenize

from pyspark.ml.feature import Tokenizer, StopWordsRemover
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, concat_ws, lower, regexp_replace


def uncompress(filesPath):
    """
    Lee todos los archivos de un directorio y los descomprime del formato bz2
    """
    filesList = list()

    for (dirPath, dirNames, files) in os.walk(filesPath):
        for filename in files:
            filepath = os.path.join(dirPath, filename)
            if filepath.endswith(".bz2"):
                zipfile = bz2.BZ2File(filepath)  # open the file
                data = zipfile.read()  # get the decompressed data
                newFilepath = filepath[:-4]  # assuming the filepath ends with .bz2
                filesList.append(newFilepath)
                open(newFilepath, "wb").write(data)  # write a uncompressed file

    return filesList


def clean_text(s):
    s = lower(s)
    s = regexp_replace(s, "^rt ", "")
    s = regexp_replace(s, "[^a-zA-Z0-9\\s]", "")
    return s


def untokenize(s):
    return tokenize.untokenize(s)


if __name__ == '__main__':
    workDir = "./30/01/"
    files = uncompress(workDir)  # list of JSON files

    tupleList = list()
    for file in files:
        with open("./30/01/00.json", 'r') as f:
            for line in f.readlines():
                j = json.loads(line)
                if "user" in j:
                    if j["user"]["lang"] == "es":
                        user = j["user"]["screen_name"]
                        date = j["created_at"]
                        tweet = j["text"]
                        tupleList.append((user, date, tweet))

    sc = SparkSession \
        .builder \
        .appName("My first ETL") \
        .getOrCreate()

    # RDD
    rdd = sc.sparkContext.parallelize(tupleList).toDF(["user", "date", "text"])
    print(rdd.show(10, truncate=False))

    # Usuario que más ha twitteado
    users = rdd.select("user").groupBy("user").count()
    pandas_df = users.toPandas()
    pandas_df.to_json("./users.json")

    # Palabra que más veces aparece en los tweets
    tweets = rdd.select("text")
    wordsCount = tweets.rdd.flatMap(lambda x: x[0].split(" ")) \
        .map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y).toDF(["word", "count"]).sort("count", ascending=False)
    print(wordsCount.show(10, truncate=False))

    # Tokenize
    tokenizer = Tokenizer(inputCol="text", outputCol="vector")
    vector_df = tokenizer.transform(tweets).select("vector")
    print(vector_df.show(10, truncate=False))

    # Eliminar stopwords
    stopwords = ['como', 'pero', 'o', 'al', 'mas', 'esta', 'le', 'cuando', 'eso', 'su', 'porque', 'd', 'del', 'los',
                 'mi', 'si', 'las', 'una', 'q', 'ya', 'yo', 'tu', 'el', 'ella', 'a', 'ante', 'bajo', 'cabe', 'con',
                 'contra', 'de', 'desde', 'en', 'entre', 'hacia', 'hasta', 'para', 'por', 'segun', 'sin', 'so',
                 'sobre', 'tras', 'que', 'la', 'no', 'y', 'el', 'me', 'es', 'te', 'se', 'un', 'lo']

    remover = StopWordsRemover(inputCol="vector", outputCol="vector_no_stopw", stopWords=stopwords)
    vector_df_no_stopw = remover.transform(vector_df).select("vector_no_stopw")

    # Cambiamos tipo columna de array a string
    vector_df_no_stopw = vector_df_no_stopw.withColumn("vector_no_stopw", concat_ws(",", col("vector_no_stopw")))
    print(vector_df_no_stopw.show(10, truncate=False))

    # La segunda palabra que más veces aparece en los tweets
    wordsCount_2 = vector_df_no_stopw.rdd.flatMap(lambda x: x[0].split(",")) \
        .map(lambda x: (x, 1)).reduceByKey(lambda x, y: x + y).toDF(["word", "count"]).sort("count", ascending=False)
    print(wordsCount_2.show(10, truncate=False))
