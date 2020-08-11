# Máster -> Detección de anomalías
# Laura Rodríguez Navas

###########################################################################
# UNIVARIATE STATISTICAL OUTLIERS -> IQR 
###########################################################################
source("!Outliers_A3_Funciones_a_cargar_en_cada_sesion.R")

# Siga las instrucciones indicadas en el fichero INSTRUCCIONES.txt


# Vamos a trabajar con los siguientes objetos:

# mydata.numeric: frame de datos
# indice.columna: Índice de una columna de datos de mydata.numeric
# nombre.mydata:  Nombre del frame para que aparezca en los plots

# En este script los estableceremos a la base de datos mtcars, columna 1 y nombre "mtcars"

mydata.numeric  = mtcars[,-c(8:11)]  # mtcars[1:7]
indice.columna  = 1
nombre.mydata   = "mtcars"

# ------------------------------------------------------------------------

# Ahora creamos los siguientes objetos:

# mydata.numeric.scaled -> Debe contener los valores normalizados demydata.numeric. Para ello, usad la función scale
# columna -> Contendrá la columna de datos correspondiente a indice.columna. Basta realizar una selección con corchetes de mydata.numeric
# nombre.columna -> Debe contener el nombre de la columna. Para ello, aplicamos la función names sobre mydata.numeric
# columna.scaled -> Debe contener los valores normalizados de la anterior


mydata.numeric.scaled = scale(mydata.numeric)
columna         = mydata.numeric[, indice.columna]
nombre.columna  = names(mydata.numeric)[indice.columna]
columna.scaled  = mydata.numeric.scaled[, indice.columna]


###########################################################################
###########################################################################
# Parte primera. Cómputo de los outliers IQR
###########################################################################
###########################################################################


###########################################################################
# Calcular los outliers según la regla IQR. Directamente sin funciones propias
###########################################################################

# Transparencia 82


# ------------------------------------------------------------------------------------

# Calculamos las siguientes variables:

# cuartil.primero -> primer cuartil, 
# cuartil.tercero -> tercer cuartil
# iqr             -> distancia IQR

# Para ello, usamos las siguientes funciones:
# quantile(columna, x) para obtener los cuartiles
#    x=0.25 para el primer cuartil, 0.5 para la mediana y 0.75 para el tercero
# IQR para obtener la distancia intercuartil 
#    (o bien reste directamente el cuartil tercero y el primero)

# Calculamos las siguientes variables -los extremos que delimitan los outliers-

# extremo.superior.outlier.normal  = cuartil tercero + 1.5 IQR
# extremo.inferior.outlier.normal  = cuartil primero - 1.5 IQR
# extremo.superior.outlier.extremo = cuartil tercero + 3 IQR
# extremo.inferior.outlier.extremo = cuartil primero - 3 IQR

# Construimos sendos vectores: 

# vector.es.outlier.normal 
# vector.es.outlier.extremo

# Son vectores de valores lógicos TRUE/FALSE que nos dicen 
# si cada registro es o no un outlier con respecto a la columna fijada
# Para ello, basta comparar con el operador > o el operador < la columna con alguno de los valores extremos anteriores

# El resultado debe ser el siguiente:
# [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
# [18] FALSE FALSE  TRUE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE


# COMPLETAR

cuartil.primero <- quantile(columna, 0.25) 
cuartil.tercero <- quantile(columna, 0.75)
iqr <- IQR(columna)

cuartil.primero
cuartil.tercero
iqr

extremo.superior.outlier.normal = cuartil.tercero + 1.5 * iqr
extremo.inferior.outlier.normal = cuartil.primero - 1.5 * iqr
extremo.superior.outlier.extremo = cuartil.tercero + 3 * iqr
extremo.inferior.outlier.extremo = cuartil.primero - 3 * iqr

extremo.superior.outlier.normal
extremo.inferior.outlier.normal
extremo.superior.outlier.extremo
extremo.inferior.outlier.extremo

vector.es.outlier.normal = columna > extremo.superior.outlier.normal |
  columna < extremo.inferior.outlier.normal

vector.es.outlier.extremo = columna > extremo.superior.outlier.extremo |
  columna < extremo.inferior.outlier.extremo

vector.es.outlier.normal
vector.es.outlier.extremo


###########################################################################
# Índices y valores de los outliers
###########################################################################

# Construimos las siguientes variables:

# claves.outliers.normales     -> Vector con las claves (identificador numérico de fila) de los valores que son outliers. Para obtenerlo, usad which sobre vector.es.outlier.normal
# data.frame.outliers.normales -> data frame obtenido con la selección del data frame original de las filas que son outliers. Puede usarse o bien vector.es.outlier.normal o bien claves.outliers.normales
#                                 Este dataframe contiene los datos de todas las columnas de aquellas filas que son outliers.                                  
# nombres.outliers.normales    -> vector con los nombres de fila de los outliers. Para obtenerlo, usad row.names sobre el data frame anterior
# valores.outliers.normales    -> vector con los datos de los outliers. Se muestra sólo el valor de la columna que se fijó al inicio del script 
# Idem con los extremos

# Aplicando la selección dada por vector.es.outlier.normal:

#    [1] 20
#                    mpg cyl disp hp drat    wt qsec
     #Toyota Corolla 33.9   4 71.1 65 4.22 1.835 19.9
#    [1] "Toyota Corolla"
#    [1] 33.9

# Aplicando la selección dada por vector.es.outlier.extremo:
# Ninguno



# COMPLETAR

claves.outliers.normales <- which(vector.es.outlier.normal == TRUE)
claves.outliers.normales

data.frame.outliers.normales <- as.data.frame(mydata.numeric[claves.outliers.normales,])
data.frame.outliers.normales

nombres.outliers.normales <- row.names(mydata.numeric)[vector.es.outlier.normal==TRUE]
nombres.outliers.normales

valores.outliers.normales <- columna[vector.es.outlier.normal]
valores.outliers.normales

claves.outliers.extremos <- which(vector.es.outlier.extremo == TRUE)
claves.outliers.extremos

data.frame.outliers.extremos <- as.data.frame(mydata.numeric[claves.outliers.extremos,])
data.frame.outliers.extremos

nombres.outliers.extremos <- row.names(mydata.numeric)[vector.es.outlier.extremo==TRUE]
nombres.outliers.extremos

valores.outliers.extremos <- columna[vector.es.outlier.extremo]
valores.outliers.extremos

###########################################################################
# Desviación de los outliers con respecto a la media de la columna
###########################################################################

# Construimos la variable:

# valores.normalizados.outliers.normales -> Contiene los valores normalizados de los outliers. 
# Usad columna.scaled y (o bien vector.es.outlier.normal o bien claves.outliers.normales)

# Toyota Corolla 
# 2.291272 


# COMPLETAR

valores.normalizados.outliers.normales <- columna.scaled[vector.es.outlier.normal]
valores.normalizados.outliers.normales


###########################################################################
# Plot
###########################################################################

# Mostramos en un plot los valores de los registros (los outliers se muestran en color rojo)
# Para ello, llamamos a la siguiente función:
# MiPlot_Univariate_Outliers (columna de datos, indices -claves numéricas- de outliers , nombre de columna)
# Lo hacemos con los outliers normales y con los extremos


# COMPLETAR

MiPlot_Univariate_Outliers(mydata.numeric, claves.outliers.normales, nombres.outliers.normales)
MiPlot_Univariate_Outliers(mydata.numeric, claves.outliers.extremos, as.character(nombres.outliers.extremos))


###########################################################################
# BoxPlot
###########################################################################


# Vemos el diagrama de caja 

# Para ello, llamarémos a la función boxplot, pero no muestra el outlier en la columna mpg :-(
# boxplot(columna, xlab=nombre.columna, main=nombre.mydata, las = 1)   # las = 1 all axis labels horizontal, range = 3 for exteme outliers

# Para resolverlo, vemos el diagrama de caja con ggplot geom_boxplot
# Para ello, llamamos a la siguiente función
# MiBoxPlot_IQR_Univariate_Outliers = function (datos, indice.de.columna, coef = 1.5)

# Llamamos a la misma función pero con los datos normalizados
# Lo hacemos para resaltar que el Boxplot es el mismo ya que el poder de la normalización es que no afecta a la posición relativa de los datos 


# COMPLETAR
boxplot(columna, xlab=nombre.columna, data=mydata.numeric, las = 1, range = 3) 

MiBoxPlot_IQR_Univariate_Outliers(mydata.numeric, indice.columna, coef = 1.5)
MiBoxPlot_IQR_Univariate_Outliers(mydata.numeric.scaled, indice.columna, coef = 1.5)


###########################################################################
# Cómputo de los outliers IQR con funciones propias
###########################################################################

# En este apartado hacemos lo mismo que antes, pero llamando a funciones que están dentro de !Outliers_A3_Funciones.R :

# vector_es_outlier_IQR      -> devuelve un vector TRUE/FALSE
# vector.claves.outliers.IQR -> devuelve los índices de los outliers


vector.es.outlier.normal  = vector_es_outlier_IQR(mydata.numeric, indice.columna)
vector.es.outlier.extremo = vector_es_outlier_IQR(mydata.numeric, indice.columna, 3)

valores.outliers.normales = columna[vector.es.outlier.normal]
valores.outliers.extremos = columna[vector.es.outlier.extremo]

claves.outliers.normales = vector_claves_outliers_IQR (mydata.numeric, indice.columna)
claves.outliers.extremos = vector_claves_outliers_IQR (mydata.numeric, indice.columna, 3)

claves.outliers.normales
valores.outliers.normales
claves.outliers.extremos
valores.outliers.extremos