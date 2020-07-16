# Máster -> Deteccián de anomalías
# Laura Rodriguez Navas

###########################################################################
# MULTIVARIATE STATISTICAL OUTLIERS -> LOF 
###########################################################################

# Los outliers son respecto a un conjunto de variables.


#####################################################################
# Lectura de valores y Preprocesamiento
#####################################################################


# Tanto LOF como clustering usan distancias entre registros, por lo que habrá
# que trabajar sobre los datos previamente normalizados

# Construimos las siguientes variables:

# mis.datos.numericos -> Contendrá las columnas numéricas de iris, es decir, iris [1:4]
# mis.datos.numericos.normalizados -> Contendrá los datos normalizados
# Asignamos como nombres de filas de mis.datos.numericos.normalizados los mismos nombres de filas que mis.datos.numericos

# Ampliación: Utilice la función is.numeric y sapply para construir automáticamente un data frame
# con las columnas numéricas de otro data frame.


mis.datos.originales = iris
mis.datos.numericos  = mis.datos.originales[,1:4]
mis.datos.numericos  = mis.datos.originales[,sapply(mis.datos.originales, is.numeric)]
mis.datos.numericos.normalizados = scale(mis.datos.numericos)
rownames(mis.datos.numericos.normalizados) = rownames(mis.datos.numericos)


###########################################################################

# Transparencia 106

# Para comprobar que el método de Mahalanobis no es aplicable, 
# obtenga las variables is.MCD.outlier y numero.de.outliers.MCD 
# tal y como se hizo en el script anterior (hay que tener cargada la librería mvoutlier)
# Observe que hay un número muy elevado de outliers (50) y además con valores de Petal.Length y Petal.Width
# muy similares. Realmente no son outliers sino que forman un grupo homogéneo.


# COMPLETAR
alpha.value = 0.05
alpha.value.penalizado = 1 - (1 - alpha.value) ^ (1 / nrow(mis.datos.numericos))

set.seed(12)

X11()

mvoutlier.plot = uni.plot(mis.datos.numericos, symb=FALSE, alpha = alpha.value.penalizado)

is.MCD.outlier = mvoutlier.plot$outliers
is.MCD.outlier 

numero.de.outliers.MCD = sum(is.MCD.outlier)
numero.de.outliers.MCD


# Ejecute también lo siguiente:

X11()
corr.plot(mis.datos.numericos[,1], mis.datos.numericos[,3]) 


# El gráfico nos muestra un gráfico de dispersión al cruzar las variables 1 y 3.
# Vemos que hay dos grupos bien definidos de datos.
# Los puntos que hay entre ellos deberían ser marcados como outliers
# Usando la distancia de Mahalanobis clásica (azul) el elipsoide
# contiene a ambos grupos por lo que los puntos que hubiese entre ellos no serían outliers
# Usando la distancia de Mahalanobis construida con la estimación robusta de la matriz de covarianzas
# y las correspondientes medias, el elipsoide (rojo) se construye con el grupo de datos
# más numeroso y todos los datos del otro grupo se marcan como outliers :-(

# También podemos mostrar un BiPlot llamando a la función MiBiplot sobre mis.datos.numericos
# El gráfico mostrado es una simplificación ya que ahora estamos mostrando las cuatro variables conjuntamente 
# en un gráfico 2 dimensional (Transparencia 72)
# Podemos apreciar que hay dos nubes de puntos bien separadas.

# Así pues, el método de detección de outliers usando la distancia de Mahalanobis no es adecuado


MiBiplot(mis.datos.numericos)


###########################################################################
###########################################################################
# DISTANCE BASED OUTLIERS (LOF)
###########################################################################
###########################################################################

# Transparencia 124

numero.de.vecinos.lof = 5

# Establecemos el número de vecinos a considerar numero.de.vecinos.lof = 5 y llamamos a la función lofactor
# pasándole como primer parámetro el conjunto de datos normalizados y como parámetro k el valor de numero.de.vecinos.lof
# Esta función devuelve un vector con los scores de LOF de todos los registros
# Lo llamamos lof.scores
# [1] 1.0036218 1.0244637 1.0198058 1.0394019 ......

# Hacemos un plot de los resultados (basta llamar a la función plot sobre lof.scores) 
# para ver los scores obtenidos por LOF.
# Podemos apreciar que hay 4 valores de lof notablemente míos altos que el resto
# Así pues, establecemos la variable siguiente:
# numero.de.outliers = 4

# Ordenamos los lof.scores y obtenemos los índices de los registros ordenados según el lof.score
# indices.de.lof.outliers.ordenados
# [1]  42 118 132 110 107  16  61  23  ......

# Seleccionamos los 4 primeros y los almacenamos en indices.de.lof.top.outliers
# [1]  42 118 132 110 

# Construimos un vector is.lof.outlier de TRUE/FALSE que nos dice si cada registro de los datos
# originales es o no un outlier. Para ello, debemos usar la función rownames sobre el dataset
# y el operador %in% sobre indices.de.lof.top.outliers
# is.lof.outlier
# [1] FALSE FALSE FALSE FALSE FALSE ......

# Mostramos un Biplot de los outliers llamando a la función MiBiPlot_Multivariate_Outliers
# MiBiPlot_Multivariate_Outliers = function (datos, vectorTFoutliers, titulo)


# Tal vez, el dato más interesante sea el 42 ya que no parece que sea un outlier univariante
# (luego lo comprobaremos)


# COMPLETAR

lof.scores = lofactor(mis.datos.numericos.normalizados, numero.de.vecinos.lof)
lof.scores

plot(lof.scores)

numero.de.outliers = 4

indices.de.lof.outliers.ordenados = order(lof.scores, decreasing = TRUE)
indices.de.lof.outliers.ordenados

indices.de.lof.top.outliers = indices.de.lof.outliers.ordenados[1:4]
indices.de.lof.top.outliers

is.lof.outlier = c(1:nrow(mis.datos.originales)) %in% indices.de.lof.top.outliers
is.lof.outlier

MiBiPlot_Multivariate_Outliers(mis.datos.numericos, is.lof.outlier, "")

# Comparamos con los outliers en una sola dimensión que habríamos obtenido con el método IQR 
# Construimos las variables:

# vector.claves.outliers.IQR.en.alguna.columna: Contiene los índices de los que son outliers en alguna columna
#   Hay que llamar a la función vector_claves_outliers_IQR_en_alguna_columna
# vector.es.outlier.IQR.en.alguna.columna: Vector de T/F indicando si cada dato es outlier o no según el criterio IQR
#   Hay que llamar a la función vector_es_outlier_IQR_en_alguna_columna

# Debe salir lo siguiente:
# vector.claves.outliers.IQR.en.alguna.columna
# [1] 16 33 34 61

# Mostramos el Biplot usando el vector de T/F vector.es.outlier.IQR.en.alguna.columna

# Construimos la variable
# indices.de.outliers.multivariantes.LOF.pero.no.1variantes: Contiene los outliers LOF que no son outliers IQR
#   Para ello, usamos setdiff y vemos que el resultado es el mismo conjunto de outliers LOF
#   es decir, que ningún outlier LOF es outlier IQR

# indices.de.outliers.multivariantes.LOF.pero.no.1variantes
# [1]  42 118 132 110


# COMPLETAR

vector.claves.outliers.IQR.en.alguna.columna = vector_claves_outliers_IQR_en_alguna_columna(
  mis.datos.numericos, coef = 1.5)
vector.claves.outliers.IQR.en.alguna.columna

MiBoxPlot_juntos(mis.datos.numericos, vector.claves.outliers.IQR.en.alguna.columna)

indices.de.outliers.multivariantes.LOF = which(is.lof.outlier == TRUE)
indices.de.outliers.multivariantes.LOF.pero.no.1variantes = setdiff(
  indices.de.outliers.multivariantes.LOF, vector.claves.outliers.IQR.en.alguna.columna)
indices.de.outliers.multivariantes.LOF.pero.no.1variantes
