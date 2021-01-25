from pyspark import SparkConf, SparkContext
from time import sleep

conf = SparkConf().setMaster("local").setAppName("My App")
sc = SparkContext(conf = conf)

# La variable sc
print(locals())  # Muestra las variables definidas
print(type(sc))  # Indica el tipo de la variable sc
print(dir(sc))  # Lista los métodos disponibles en el objeto sc

# Crear RDD
preposiciones = ['a', 'ante', 'bajo', 'cabe', 'con', 'contra', 'de', 'desde', 'en', 'entre', 'hacia', 'hasta', 'para',
                 'por', 'segun', 'sin', 'so', 'sobre', 'tras']
rddPreposiciones = sc.parallelize(preposiciones)  # Crea un RDD
print(type(rddPreposiciones))  # RDD

# Examinar RDD
print(rddPreposiciones.collect())  # Devuelve una lista de Python

# Transformar RDD - Map
print(rddPreposiciones.map(len).collect())  # Transforma el RDD de preposiciones (cadenas) en un RDD de longitudes (enteros) y muestra el resultado

# Transformar RDD - Map - Funciones definidas
def aMayusculas(s):
    return s.capitalize()  # La indentación es importante en Python

print(rddPreposiciones.map(aMayusculas).collect())  # Transforma el RDD con la función definida y muestra el resultado

# Transformar RDD - Filter
def esCorta(s):
    return len(s) <= 3

print(rddPreposiciones.filter(esCorta).collect())

# Transformar RDD - FlatMap
rddLetras = rddPreposiciones.flatMap(list)  # List es una función de Python que transforma una cadena en una secuencia de caracteres
print(rddLetras.collect())

# Apunte Python
f = lambda x: x + 2  # Un solo parámetro de entrada al que se suma dos
print(f(3))  # 5
print(rddPreposiciones.map(lambda s: s.capitalize()).collect())  # Equivalente a lo hecho anteriormente con la función aMayusculas
print(rddPreposiciones.map(lambda p: (len(p), aMayusculas(p))).collect())  # Devuelve una tupla de (entero, cadena)
print(rddPreposiciones.map(lambda p: (len(p), p.capitalize())).collect())  # Exactamente lo mismo pero usando funciones dentro de una lambda

# Explorar RDD
print(rddPreposiciones.first())  # Obtiene el primer elemento
print(rddPreposiciones.take(5))  # Obtiene 5 elementos

# Cómputos
print(rddPreposiciones.count())  # Número de elementos en el rddPreposiciones
print(rddLetras.count())  # Número de elementos en el rddLetras
print(rddPreposiciones.map(len).sum())  # Número de letras total en todas las preposiciones
print(rddPreposiciones.max())  # Devuelve el mayor elemento (alfabéticamente)
print(rddPreposiciones.map(len).max())  # Devuelve el número de caracteres de la preposición más larga
print(max(rddPreposiciones.map(lambda p: (len(p), p)).collect()))

# Explorar RDD
def pr(s):
    print(s.encode('utf-8'))

rddPreposiciones.foreach(pr)  # Aplica la función a cada elemento. En este caso imprime cada elemento. Se ejecuta en el momento (es una acción)

# Lazy evaluation
def funcion_costosa(s):
    sleep(0.5)
    return s.capitalize()

rddMayusculas = rddPreposiciones.map(funcion_costosa)  # Inmediato
# print(rddMayusculas.collect())  # Ahora es cuando tarda
print(rddMayusculas.toDebugString())  # Describe el linaje de operaciones necesario para construir el RDD

# Reduce
longitudes = rddPreposiciones.map(len)
print(longitudes.reduce(max))
print(longitudes.reduce(lambda x, y: max(x, y)))  # Equivalente a lo anterior

# Claves
print(rddPreposiciones.map(lambda x: (x[0], 1)).groupByKey().map(lambda p: (p[0], sum(p[1]))).collect())  # Con groupByKey
print(rddPreposiciones.map(lambda x: (x[0], 1)).reduceByKey(lambda c1, c2: c1 + c2).collect())  # Con reduceByKey

# Cache
rddPreposiciones.cache()  # Indica a Spark que mantenga el RDD en memoria
rddPreposiciones.persist()  # Permite indicar dónde queremos que guarde el RDD (memoria, disco...)
rddPreposiciones.unpersist()  # Dice a Spark que se desentienda del RDD
