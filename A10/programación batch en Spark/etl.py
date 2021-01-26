import bz2
import json
import os
import re

from pyspark.sql import SparkSession


def uncompress(filesPath):
    filesList = list()
    for (dirPath, dirNames, files) in os.walk(filesPath):
        for filename in files:
            filepath = os.path.join(dirPath, filename)
            if filepath.endswith(".bz2"):
                zipfile = bz2.BZ2File(filepath)
                data = zipfile.read()
                newFilepath = filepath[:-4]
                filesList.append(newFilepath)
                open(newFilepath, "wb").write(data)
    return filesList


def createTupleList():
    tupleList = list()
    for file in files:
        with open(file, 'r') as f:
            for line in f.readlines():
                j = json.loads(line)
                if "user" in j and j["user"]["lang"] == "es":  # exists user and user use spanish
                    username = j["user"]["screen_name"]
                    date = j["created_at"]
                    tweet = j["text"]
                    tupleList.append((username, date, tweet))
    return tupleList


def quitaNoAlfa(s):
    return re.sub(r'([^\s\wñáéíóú]|_)+', '', s.lower())


def quitaEspacios(s):
    return ' '.join(s).split()


def quitaStopWords(s):
    stopwords = ['como', 'pero', 'o', 'al', 'mas', 'esta', 'le', 'cuando', 'eso', 'su', 'porque', 'd', 'del', 'los',
                 'mi', 'si', 'las', 'una', 'q', 'ya', 'yo', 'tu', 'el', 'ella', 'a', 'ante', 'bajo', 'cabe', 'con',
                 'contra', 'de', 'desde', 'en', 'entre', 'hacia', 'hasta', 'para', 'por', 'segun', 'sin', 'so',
                 'sobre', 'tras', 'que', 'la', 'no', 'y', 'el', 'me', 'es', 'te', 'se', 'un', 'lo']
    if s not in stopwords:
        return s


if __name__ == '__main__':
    workDir = "./30/01/"
    files = uncompress(workDir)
    tuples = createTupleList()

    sc = SparkSession \
        .builder \
        .appName("My first ETL") \
        .getOrCreate()

    # RDD
    rddDF = sc.sparkContext.parallelize(tuples).toDF(["user", "date", "text"])

    # Usuario que más ha twitteado
    users = rddDF.select("user")
    usersCount = users.rdd.flatMap(lambda x: x[0].split(" ")) \
        .map(lambda x: (x, 1)) \
        .reduceByKey(lambda x, y: x + y) \
        .toDF(["word", "count"]).sort("count", ascending=False)
    usersCount.show(5)

    # Clean tweets
    tweets = rddDF.select("text")
    tweets.rdd.map(quitaNoAlfa)

    # Palabra que más veces aparece en los tweets
    wordsCount = tweets.rdd.flatMap(lambda x: x[0].split(" ")) \
        .map(lambda x: (x, 1)) \
        .reduceByKey(lambda x, y: x + y) \
        .toDF(["word", "count"]).sort("count", ascending=False)
    wordsCount.show(5)

    # La segunda palabra que más veces aparece en los tweets
    tweets_without_stopwords = tweets.rdd.flatMap(lambda x: x[0].split(" ")) \
        .filter(quitaStopWords)
    wordsCount_2 = tweets_without_stopwords.map(lambda x: (x, 1)) \
        .reduceByKey(lambda x, y: x + y) \
        .toDF(["word", "count"]).sort("count", ascending=False)
    wordsCount_2.show(5)
