import sys, os, bz2, json, sys

# lee todos los archivos de un directorio y los descomprime del formato bz2.
path = "./files/30/01/"
for(dirpath, dirnames, files)in os.walk(path):
    for filename in files:
        filepath = os.path.join(dirpath, filename)
        zipfile = bz2.BZ2File(filepath) # open the file
        data = zipfile.read() # get the decompressed data
        # data es una cadena de texto con el contenido del archivo
        # en este ejemplo se guarda el contenido a otro fichero
        newfilepath = filepath[:-4] # assuming the filepath ends with .bz2
        open(newfilepath, 'wb').write(data) # write a uncompressed file
        
with open('./files/sample.json','r') as f:
    line = f.readline()
    while line:
        j = json.loads(line)
        # print j # si imprimimos la variable vemos su estructura.
        print j["user"]["screen_name"].encode("utf-8") # para referirnos a un usuario usaremos su Screen Name.
        line = f.readline()
