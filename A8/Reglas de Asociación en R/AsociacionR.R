#Descarga el dataset Titanic de la siguiente URL http://www.rdatamining.com/data/titanic.raw.rdata?attredirects=0&d=1

#Cargamos el dataset. El path deberá ser especificado por el alumno.
load("./titanic.raw.rdata")

#Lo primero que haremos es comprobar que el dataset ha sido cargado correctamente, comprobando:
#-Numero de registros (observaciones)
#-Numero de variables
#-Tipo de variable
#-Numero de valores por cada variable
str(titanic.raw)

###Alumno: Describa cada una de las características antes indicadas (numero de registros, numero de variables, etc)
#-Numero de registros (observaciones): 2201.
#-Numero de variables: 4 (Class, Sex, Age y Survived).
#-Tipo de variable: nominal.
#-Numero de valores por cada variable: 4 para Class, 2 para Sex, 2 para Age y 2 para Survived.

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
#-Primera regla. Los hombres de de la tripulación que no sobrevivieron fueron 670, un 30% del total de las personas que iban a bordo
#La regla es cierta en un 99.5% y como la métrica lift es superior a 1, nos indica que los hombres de la tripulación 
#que no sobrevivieron aparecen en una cantidad superior a la esperada, es decir, existen muchas coocurrencias de 
#este conjunto de items en el conjunto de transacciones de la base de datos.

#-Segunda regla. Los hombres adultos de la tripulación que no sobrevivieron fueron 670, un 30% del total de las 
#personas que iban a bordo. Teniendo en cuenta la primera regla y esta, podemos afirmar que todos los hombres de la tripulación 
#que murieron fueron adultos. La regla también es cierta en un 99.5% y como la métrica lift también es superior a 1, 
#existen muchas coocurrencias de hombres adultos de la tripulación que no sobrevivieron en el conjunto de 
#transacciones de la base de datos.
  
#-Tercera regla. Los hombres de la tripulación fueron 862, un 39% total de las personas que iban a bordo. La regla 
#es cierta en un 97.4% y como la métrica lift vuelve a estar por encima de 1, indica que había muchos tripulantes 
#en el total de las personas que iban a bordo.

#Extraemos reglas de asociación con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.9
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child no pueden aparecer en ningun sitio de la regla y el resto de valores puede aparecer en ambos lugares (antecedente y consecuente)
rules <- apriori(titanic.raw, parameter=list(support=0.1, confidence=0.9), appearance = list(none = c("Age=Adult", "Age=Child"),default="both"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qué reglas son más interesantes y por qué.
#-Primera regla. Los hombres de la tripulación fueron 862, un 39% del total de las personas que iban a bordo. La regla 
#es cierta en un 97.4%.
#-Segunda regla. Los hombres que no sobrevivieron fueron 1364, un 61% del total de las personas que iban a bordo. La regla es 
#cierta en un 91.5%. Esta regla es muy interesante porqué nos indica que más del 50% del total de las personas que iban a bordo 
#que murieron fueron hombres.
#-Tercera regla. Los hombres de de la tripulación que no sobrevivieron fueron 670, un 30% del total de las personas que iban a bordo. La regla es cierta en un 99.5%.**
#Combinando las reglas podemos decir que solo sobrevivieron 192 hombres de la tripulación, de un total de 832. 
#Muy pocos sobrevivieron, la mayoria de los hombres que murireon pertenecían a la tripulación.

#Extraemos reglas de asociación con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.9
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child solo pueden aparecer en el antecedente. En el consecuente sólo si sobrevivieron o no
rules <- apriori(titanic.raw, parameter=list(support=0.01, confidence=0.3), appearance = list(lhs = c("Age=Adult", "Age=Child"), rhs = c("Survived=No", "Survived=Yes"),default="none"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qué reglas son más interesantes y por qué.

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
#numMujeresMuertas obtenida a partir de la regla de asociación específica.
###Alumno: Describa claramente el procedimiento seguido y explique con claridad los resultados alcanzados
#####INSERTAR EL CÓDIGO AQUÍ######


##################################





###Alumno: Para dar respuesta a las siguientes cuestiones que se plantean, es necesario buscar reglas específicas para el conocimiento que estamos buscando.
#Lea detenidamenta las cuestiones que se plantean y responde a ellas de manera clara y concisa.
#Explica de manera clara y concisa cómo has obtenido dichos resultados o cómo has llegado a dichas conclusiones.
###Alumno: Las cuestiones planteadas son:
#a) ¿Se cumplió la norma de los niños y las mujeres primero?
#b) ¿Tuvo mayor peso la clase a la que pertenecía el pasajero?
#c) ¿Podemos saber si la tripulación se comportó heroicamente?
#####INSERTAR EL CÓDIGO AQUÍ######



##################################




###Alumno: Obtener las reglas de mayor longitud (las que incluyan un mayor numero de variables). Utilizar diferentes umbrales de soporte y confianza y mostrar qué reglas son las de mauyor longitud para los diferentes umbrales.
#####INSERTAR EL CÓDIGO AQUÍ######



##################################

