# Máster -> Detección de anomalías
# Juan Carlos Cubero. Universidad de Granada

###########################################################################
# MULTIVARIATE STATISTICAL OUTLIERS. CLUSTERING OUTLIERS 
###########################################################################

# Los outliers son respecto a un conjunto de variables.


#####################################################################
# Lectura de valores y Preprocesamiento
#####################################################################

# Trabajamos sobre las columnas numéricas de iris [1:4]
# Este conjunto de datos está disponible en R
# Tanto LOF como clustering usan distancias entre registros, por lo que habrá
# que trabajar sobre los datos previamente normalizados

# Construimos los siguiente conjuntos:

# mis.datos.numericos -> con las columnas 1:4 de iris
# mis.datos.numericos.normalizados -> con los valores normalizados
# a Los rownames de mis.datos.numericos.normalizados les asignamos los rownames de mis.datos.numericos

# Establecemos la variable numero.de.outliers a 5 y numero.de.clusters a 3


mis.datos.numericos   = iris[,1:4]
#mis.datos.numericos   = mis.datos.originales[,sapply(mis.datos.originales, is.numeric)]
mis.datos.numericos.normalizados           = scale(mis.datos.numericos)
rownames(mis.datos.numericos.normalizados) = rownames(mis.datos.numericos)

numero.de.outliers   = 5
numero.de.clusters   = 3

set.seed(2)  # Para establecer la semilla para la primera iteración de kmeans


###########################################################################
# Cómputo de los outliers según la distancia euclídea de cada dato 
# al centroide de su cluster
# El centroide podrá ser cualquiera (podrá provenir de un k-means 
# o ser un medoide, por ejemplo)
###########################################################################



###########################################################################
# k-Means

# Construimos el modelo kmeans (modelo.kmeans) con los datos normalizados. 
# Para ello, usamos la función de R llamada "kmeans"

# A partir del resultado de kmeans, accedemos a:

# a) $cluster para obtener 
#   los índices de asignación de cada dato al cluster correspondiente 
#   El resultado lo guardamos en la variable indices.clustering.iris
#   Por ejemplo, si el dato con índice 69 está asignado al tercer cluster,
#   en el vector indices.clustering.iris habrá un 3 en la componente número 69

# b) $centers para obtener los datos de los centroides.
#   Los datos están normalizados por lo que los centroides también lo están.
#   El resultado lo guardamos en la variable centroides.normalizados.iris


# indices.clustering.iris
# 1   2   3   4   ... 69  70  71 ...
# 1   1   1   1   ... 3   3   2  ...

# centroides.normalizados.iris
#    Sepal.Length Sepal.Width Petal.Length Petal.Width
# 1  -1.01119138  0.85041372   -1.3006301  -1.2507035
# 2   1.13217737  0.08812645    0.9928284   1.0141287
# 3  -0.05005221 -0.88042696    0.3465767   0.2805873



# COMPLETAR



# -------------------------------------------------------------------------

# Calculamos la distancia euclídea de cada dato a su centroide (con los valores normalizados)
# Para ello, usad la siguiente función:

distancias_a_centroides = function (datos.normalizados, 
                                    indices.asignacion.clustering, 
                                    datos.centroides.normalizados){
  
  sqrt(rowSums(   (datos.normalizados - datos.centroides.normalizados[indices.asignacion.clustering,])^2   ))
}

# dist.centroides.iris
# 1          2          3             ......
# 0.21224719 0.99271979 0.64980753    ......

# Ordenamos dichas distancias a través de la función order y obtenemos
# los índices correspondientes. Nos quedamos con los primeros
# (tantos como diga la variable numero.de.outliers)

# top.outliers.iris
# [1]  42  16 132 118  61



# COMPLETAR



