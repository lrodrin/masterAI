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
#- **Primera regla. Los hombres de la tripulación que no sobrevivieron fueron 670, un 30% del total de las personas 
#que iban a bordo. La proporción de hombres que no sobrevivieron y que eran de la tripulación es muy alta, un 99.5%. 
#La probabilidad de que esta regla sea cierta es muy alta, ya que el valor de la métrica lift es superior a 1.**
  
#- **Segunda regla. Los hombres adultos de la tripulación que no sobrevivieron fueron 670, un 30% del total de las 
#personas que iban a bordo. Teniendo en cuenta la primera regla y esta, podemos afirmar que todos los hombres de la 
#tripulación que murieron fueron adultos. Por eso el valor de las métricas de confianza y lift tienen el mismo valor 
#que en la regla anterior.** 
  
#- **Tercera regla. Los hombres que formaron parte de la tripulación fueron 862, un 39% del total de las personas 
#que iban a bordo. La proporción de hombres que eran de la tripulación es muy alta, un 97.5%. La probabilidad de que 
#esta regla sea cierta es muy alta, ya que el valor de la métrica lift es superior a 1. Teniendo en cuenta esto, 
#podríamos afirmar que la mayoría de personas de la tripulación fueron hombres.**

#Extraemos reglas de asociación con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.9
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child no pueden aparecer en ningun sitio de la regla y el resto de valores puede aparecer en ambos lugares (antecedente y consecuente)
rules <- apriori(titanic.raw, parameter=list(support=0.1, confidence=0.9), appearance = list(none = c("Age=Adult", "Age=Child"),default="both"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qué reglas son más interesantes y por qué.
#- **Primera regla. No es interesante. Ya la hemos descrito en el apartado anterior (tercera regla).**
  
#- **Segunda regla. Los hombres que no sobrevivieron fueron 1364, un 61% del total de las personas que iban a bordo. 
#La proporción de hombres que no sobrevivieron es muy alta, un 91.5%. La probabilidad de que esta regla sea cierta es
#muy alta, ya que el valor de la métrica lift es superior a 1. Esta regla es muy interesante porqué nos indica que 
#más del 50% del total de las personas que iban a bordo que murieron fueron hombres.**
  
#- **Tercera regla. No es interesante. Ya la hemos descrito en el apartado anterior (primera regla).**
  
#**Combinando las reglas podemos observar que solo sobrevivieron 192 hombres de la tripulación, de un total de 832. 
#Muy pocos pudieron sobrevivir, la mayoría de los hombres que murieron pertenecían a la tripulación.**

#Extraemos reglas de asociación con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.9
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child solo pueden aparecer en el antecedente. En el consecuente sólo si sobrevivieron o no
rules <- apriori(titanic.raw, parameter=list(support=0.01, confidence=0.3), appearance = list(lhs = c("Age=Adult", "Age=Child"), rhs = c("Survived=No", "Survived=Yes"),default="none"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qué reglas son más interesantes y por qué.

#- **Primera regla. Todas las personas que iban a bordo y que sobrevivieron fueron 711, un 32% del total. La 
#proporción de personas que sobrevivieron es muy baja. Muy pocas personas sobrevivieron, solo un 32% del total. La 
#probabilidad de que esta regla sea cierta es total, ya que el valor de la métrica lift es 1.**
  
#- **Segunda regla. Todas las personas que iban a bordo y que no sobrevivieron fueron 1490, un 68% del total. La 
#proporción de personas que no sobrevivieron es muy alta, un 68%. La mayoría de las personas a bordo murió. La 
#probabilidad de que esta regla sea cierta es total, ya que el valor de la métrica lift es 1.**
  
#**Si sumamos el total de personas que sobrevivieron (711) de la primera regla, con el total de personas que murieron
#de la segunda regla (1490), el resultado es el total de personas que iban a bordo en el Titanic (2201).**
  
#- **Tercera regla y Cuarta regla. Los niños que sobrevivieron fueron 57, un 2.6% del total de las personas que iban 
#a bordo. Y los niños que no sobrevivieron fueron 52, un 2.4% del total de las personas que iban a bordo. La 
#proporción de los niños que sobrevivieron y la proporción de los que no sobrevivieron es muy parecida. Y es más 
#probable que sobrevivieran ya que el valor de la métrica lift en este caso es superior a 1.**
  
#- **Quinta regla y Sexta regla. Los adultos que sobrevivieron fueron 654, un 29.7% del total de las personas que iban
#a bordo. Y los adultos que no sobrevivieron fueron 1438, un 65.3% del total de las personas que iban a bordo. La 
#proporción de adultos que no sobrevivieron es mucho mayor (68.7%) que la proporción de los adultos que sobrevivieron
#(31.2%).**
  
#**Es muy interesante observar que la proporción de los niños que sobrevivieron y los que no, está muy equilibrada. 
#En cambio, en el caso de los adultos no fue así. La mayoría murió.**

#Buscamos la regla "Sex=Female" THEN "Survived=Yes" para ver cuantas mujeres sobrevivieron
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), appearance = list(lhs = c("Sex=Female"), rhs = c("Survived=Yes"),default="none"))
inspect(rules)

#Me quedo sólo con los valores de soporte, confianza y lift
soporte <- quality(rules)$support
confianza <- quality(rules)$confidence
lift <- quality(rules)$lift
soporte
confianza
lift

###Alumno: Describa los resultados obtenidos, qué reglas son más interesantes y por qué.
#**Solo se ha encontrado una regla. La regla muestra que las mujeres que sobrevivieron fueron 344, un 15.6% del 
#total de las personas que iban a bordo. Parecen pocas, pero eso se debe a que había pocas mujeres a bordo. Pero 
#muchas de ellas sobrevivieron, ya que la regla presenta valores de confianza (73%) y lift muy altos.**


#Guardar en la variable "numSobreviven" el numero de mujeres de tercerca clase que sobrevivieron al hundimiento del Titanic.
#Para ello, buscar la regla de asociación específica suponiendo que el consecuente incluye el item Survived=Yes.
###Alumno: Describa los resultados obtenidos, qué regla o reglas son más interesantes y por qué.

#####INSERTAR EL CÓDIGO AQUÍ######
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                 appearance = list(lhs = c("Class=3rd", "Sex=Female"), rhs = c("Survived=Yes"),default="none"))
inspect(rules)
numSobreviven <- quality(rules)$count[3]
numSobreviven
##################################


#Sumar el numero de mujeres de cada clase que no sobrevivieron al hundimiento del titanic. Comprobar que la suma es igual al numero de mujeres que no sobrevivieron al hundimiento del Titanic.
#Para ello, buscar las reglas de asociación específicas suponiendo que el consecuente incluye el item Survived=No.
#La variable sumaMujeresMuertas (obtenida de la suma de los resultados de las reglas específicas) tiene que ser igual a la variable
#numMujeresMuertas obtenida a partir de la regla de asociación específica.
###Alumno: Describa claramente el procedimiento seguido y explique con claridad los resultados alcanzados
#####INSERTAR EL CÓDIGO AQUÍ######
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                 appearance = list(lhs = c("Class=3rd", "Sex=Female"), 
                                   rhs = c("Survived=No"),default="none"))
inspect(rules)

rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                 appearance = list(lhs = c("Class=1st", "Sex=Female"), 
                                   rhs = c("Survived=No"),default="none"))
inspect(rules)

rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                 appearance = list(lhs = c("Class=2nd", "Sex=Female"), 
                                   rhs = c("Survived=No"),default="none"))
inspect(rules)
numMujeresMuertas <- quality(rules)$count[1]
numMujeresMuertas
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

