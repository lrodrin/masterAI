import bz2
import json
import os

from pyspark.sql import SparkSession


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
                newfilepath = filepath[:-4]  # assuming the filepath ends with .bz2
                filesList.append(newfilepath)
                open(newfilepath, "wb").write(data)  # write a uncompressed file

    return filesList


if __name__ == '__main__':
    workDir = "./30/01/"
    files = uncompress(workDir)  # list of JSON files

    tupleList = list()
    for file in files:
        with open("./30/01/00.json", 'r') as f:
            for line in f.readlines():
                j = json.loads(line)
                if "user" in j and j["user"]["lang"] == "es":
                    user = j["user"]["screen_name"]
                    date = j["created_at"]
                    tweet = j["text"]
                    tupleList.append((user, date, tweet))

    sc = SparkSession \
        .builder \
        .appName("My first ETL") \
        .getOrCreate()

    data = sc.sparkContext.parallelize(tupleList)
    print(data.collect())

    # Usuario que más ha twitteado
    # Palabra que más veces aparece en los tweets
    # La segunda palabra que más veces aparece en los tweets
