import bz2
import json
import os
import shutil
import zipfile


def uncompress(path_to_zip_file):
    if not os.path.isdir("./30/01/"):
        if os.path.isfile(path_to_zip_file):
            with zipfile.ZipFile(path_to_zip_file, 'r') as zip_ref:
                zip_ref.extractall(".")
                shutil.rmtree("./__MACOSX")
    else:
        filesList = list()
        for (dirPath, dirNames, files) in os.walk("./30/01/"):
            for filename in files:
                filepath = os.path.join(dirPath, filename)
                if filepath.endswith(".bz2"):
                    zipFile = bz2.BZ2File(filepath)
                    data = zipFile.read()
                    newFilepath = filepath[:-4]
                    filesList.append(newFilepath)
                    open(newFilepath, "wb").write(data)

        return filesList


def readFiles(path_to_file):
    with open(path_to_file) as json_file:
        result = []
        for line in json_file.readlines():
            data = json.loads(line)
            # print(data)
            if "text" in data.keys() and data["user"]["lang"] == "es":
                user = data["user"]["screen_name"]
                if "retweeted_status" in data.keys():
                    tweet = data["retweeted_status"]["text"]
                else:
                    tweet = data["text"]

                result.append(tuple([tweet, user]))

        return result
