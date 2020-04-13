#Descarga el dataset Titanic de la siguiente URL http://www.rdatamining.com/data/titanic.raw.rdata?attredirects=0&d=1

#Cargamos el dataset. El path debería ser especificado por el alumno.
load("./titanic.raw.rdata")

#Lo primero que haremos es comprobar que el dataset ha sido cargado correctamente, comprobando:
#-Numero de registros (observaciones)
#-Numero de variables
#-Tipo de variable
#-Numero de valores por cada variable
str(titanic.raw)

###Alumno: Describa cada una de las características antes indicadas (numero de registros, numero de variables, etc.)
#-Numero de registros (observaciones) = 2201
#-Numero de variables = 4
#-Tipo de variable = Nominal
#-Numero de valores por cada variable:
####-Variable Class = 4
####-Variable Sex = 2
####-Variable Age = 2
####-Variable Survived = 2

#Analizamos la distribución de los datos, comprobando cuantos registros existen para cada valor de cada variable
summary(titanic.raw)

#Vamos a trabajar con la libreria arules. Aquellos alumnos que no la tengan instalada, podrán hacerlo mediante el comando install.packages("arules")
library(arules)

#Extraemos reglas de asociación con el algoritmo Apriori y los valores por defecto (importante asegurarse que estos son los valores por defecto):
#-Soporte minimo: 0.1
#-Confianza minima: 0.8
#-Numero maximo de items (longitud maxima de regla): 10
rules <- apriori(titanic.raw, parameter = NULL, appearance = NULL, control = NULL)

#Mostramos todas las reglas obtenidas por el algoritmo
inspect(rules)
#Mostramos sólo las 3 mejores reglas en base a la métrica lift
inspect(head(sort(rules, by ="lift"),3))

###Alumno: Describa cada una de las reglas obtenidas, explicando su significado así como el significado de las métricas existentes para cada regla

#Extraemos reglas de asociación con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.9
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child no pueden aparecer en ningun sitio de la regla y el resto de valores puede aparecer en ambos lugares (antecedente y consecuente)
rules <- apriori(titanic.raw, parameter=list(support=0.1, confidence=0.9), appearance = list(none = c("Age=Adult", "Age=Child"),default="both"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qué reglas son más interesantes y por qué.

#Extraemos reglas de asociación con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.3
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child solo pueden aparecer en el antecedente. En el consecuente sólo si sobrevivieron o no
rules <- apriori(titanic.raw, parameter=list(support=0.01, confidence=0.3), appearance = list(lhs = c("Age=Adult", "Age=Child"), rhs = c("Survived=No", "Survived=Yes"),default="none"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qué reglas son més interesantes y por qué.

#Buscamos la regla "Sex=Female" THEN "Survived=Yes" para ver cuantas mujeres sobrevivieron
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), appearance = list(lhs = c("Sex=Female"), rhs = c("Survived=Yes"),default="none"))
inspect(rules)

#Me quedo sólo con los valores de soporte, confianza y lift
soporte <- quality(rules)$support
confianza <- quality(rules)$confidence
lift <- quality(rules)$lift

###Alumno: Describa los resultados obtenidos, qué reglas son más interesantes y por qué.


#Guardar en la variable "numSobreviven" el numero de mujeres de tercerca clase que sobrevivieron al hundimiento del Titanic.
#Para ello, buscar la regla de asociación específica suponiendo que el consecuente incluye el item Survived=Yes.
###Alumno: Describa los resultados obtenidos, qué regla o reglas son más interesantes y por qué.
#####INSERTAR EL CÓDIGO AQUÍ######


##################################





#Sumar el numero de mujeres de cada clase que no sobrevivieron al hundimiento del titanic. Comprobar que la suma es igual al numero de mujeres que no sobrevivieron al hundimiento del Titanic.
#Para ello, buscar las reglas de asociación específicas suponiendo que el consecuente incluye el item Survived=No.
#La variable sumaMujeresMuertas (obtenida de la suma de los resultados de las reglas específicas) tiene que ser igual a la variable
#numMujeresMuertas obtenida a partir de la regla de asociación específicas.
###Alumno: Describa claramente el procedimiento seguido y explique con claridad los resultados alcanzados
#####INSERTAR EL CÓDIGO AQUÍ######


##################################





###Alumno: Para dar respuesta a las siguientes cuestiones que se plantean, es necesario buscar reglas específicas para el conocimiento que estamos buscando.
#Lea detenidamenta las cuestiones que se plantean y responde a ellas de manera clara y concisa.
#Explica de manera clara y concisa cómo has obtenido dichos resultados o cómo has llegado a dichas conclusiones.
###Alumno: Las cuestiones planteadas son:
#a) ¿Se cumplirá la norma de los niños y las mujeres primero?
#b) ¿Tuvo mayor peso la clase a la que pertenecía el pasajero?
#c) ¿Podemos saber si la tripulaciónn se comportó heroicamente?
#####INSERTAR EL CÓDIGO AQUÍ######



##################################




###Alumno: Obtener las reglas de mayor longitud (las que incluyan un mayor numero de variables). Utilizar diferentes umbrales de soporte y confianza y mostrar qué reglas son las de mayor longitud para los diferentes umbrales.
#####INSERTAR EL CÓDIGO AQUÍ######



##################################