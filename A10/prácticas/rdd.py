# coding=utf-8
from pyspark import SparkContext as sc
from time import sleep

# La variable sc
locals()  # Muestra las variables definidas
type(sc)  # Indica el tipo de la variable sc
dir(sc)  # Lista los métodos disponibles en el objeto sc

# Crear RDD
preposiciones = ['a', 'ante', 'bajo', 'cabe', 'con', 'contra', 'de', 'desde', 'en', 'entre', 'hacia', 'hasta', 'para',
                 'por', 'segun', 'sin', 'so', 'sobre', 'tras']
rddPreposiciones = sc.parallelize(preposiciones)  # Crea un RDD
type(rddPreposiciones)  # RDD

# Examinar RDD
rddPreposiciones.collect()  # Devuelve una lista de Python

# Transformar RDD - Map
rddPreposiciones.map(len).collect()  # Transforma el RDD de preposiciones (cadenas) en un RDD de longitudes (enteros) y muestra el resultado

# Transformar RDD - Map - Funciones definidas
def aMayusculas(s):
    return s.capitalize()  # La indentación es importante en Python

rddPreposiciones.map(aMayusculas).collect()  # Transforma el RDD con la función definida y muestra el resultado

# Transformar RDD - Filter
def esCorta(s):
    return len(s) <= 3

rddPreposiciones.filter(esCorta).collect()

# Transformar RDD - FlatMap
rddLetras = rddPreposiciones.flatMap(list)  # List es una función de Python que transforma una cadena en una secuencia de caracteres
rddLetras.collect()

# Apunte Python
f = lambda x: x + 2  # Un solo parámetro de entrada al que se suma dos
f(3)  # 5
rddPreposiciones.map(lambda s: s.capitalize()).collect()  # Equivalente a lo hecho anteriormente con la función aMayusculas
rddPreposiciones.map(lambda p: (len(p), aMayusculas(p))).collect()  # Devuelve una tupla de (entero, cadena)
rddPreposiciones.map(lambda p: (len(p), p.capitalize())).collect()  # Exactamente lo mismo pero usando funciones dentro de una lambda

# Explorar RDD
rddPreposiciones.first()  # Obtiene el primer elemento
rddPreposiciones.take(5)  # Obtiene 5 elementos

# Cómputos
rddPreposiciones.count()  # Número de elementos en el rddPreposiciones
rddLetras.count()  # Número de elementos en el rddLetras
rddPreposiciones.map(len).sum()  # Número de letras total en todas las preposiciones
rddPreposiciones.max()  # Devuelve el mayor elemento (alfabéticamente)
rddPreposiciones.map(len).max()  # Devuelve el número de caracteres de la preposición más larga
max(rddPreposiciones.map(lambda p: (len(p), p)).collect())

# Explorar RDD
def pr(s):
    print s.encode('utf-8')

rddPreposiciones.foreach(pr)  # Aplica la función a cada elemento. En este caso imprime cada elemento. Se ejecuta en el momento (es una acción)

# Lazy evaluation
def funcion_costosa(s):
    sleep(0.5)
    return s.capitalize()

rddMayusculas = rddPreposiciones.map(funcion_costosa)  # Inmediato
rddMayusculas.collect()  # Ahora es cuando tarda
rddMayusculas.toDebugString()  # Describe el linaje de operaciones necesario para construir el RDD

# Reduce
longitudes = rddPreposiciones.map(len)
longitudes.reduce(max)
longitudes.reduce(lambda x, y: max(x, y))  # Equivalente a lo anterior

# Claves
rddPreposiciones.map(lambda x: (x[0], 1)).groupByKey().map(lambda (p, c): (p, sum(c))).collect()  # Con groupByKey
rddPreposiciones.map(lambda x: (x[0], 1)).reduceByKey(lambda c1, c2: c1 + c2).collect()  # Con reduceByKey

# Cache
rddPreposiciones.cache()  # Indica a Spark que mantenga el RDD en memoria
rddPreposiciones.persist()  # Permite indicar dónde queremos que guarde el RDD (memoria, disco...)
rddPreposiciones.unpersist()  # Dice a Spark que se desentienda del RDD
