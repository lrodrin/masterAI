import bz2
import json
import os
import shutil
import zipfile


def unzip(path_to_zip_file):
    if os.path.isfile(path_to_zip_file):
        zip_ref = zipfile.ZipFile(path_to_zip_file, "r")
        zip_ref.extractall(".")
        shutil.rmtree("./__MACOSX")


def unbz2(path):
    filesList = list()
    for (dirPath, dirNames, files) in os.walk(path):
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
    json_file = open(path_to_file, "r")
    result = []
    for line in json_file.readlines():
        data = json.loads(line)
        # print(data)
        if "text" in data.keys() and data["user"]["lang"] == "es":
            user = data["user"]["screen_name"]
            tweet = data["text"]
            result.append(tuple([tweet, user]))

    return result
