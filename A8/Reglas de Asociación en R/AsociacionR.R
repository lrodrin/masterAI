#Descarga el dataset Titanic de la siguiente URL http://www.rdatamining.com/data/titanic.raw.rdata?attredirects=0&d=1

#Cargamos el dataset. El path deber? ser especificado por el alumno.
load("./titanic.raw.rdata")

#Lo primero que haremos es comprobar que el dataset ha sido cargado correctamente, comprobando:
#-Numero de registros (observaciones)
#-Numero de variables
#-Tipo de variable
#-Numero de valores por cada variable
str(titanic.raw)

###Alumno: Describa cada una de las caracter?sticas antes indicadas (numero de registros, numero de variables, etc)
#-Numero de registros (observaciones): 2201.
#-Numero de variables: 4 (Class, Sex, Age y Survived).
#-Tipo de variable: nominal.
#-Numero de valores por cada variable: 4 para Class, 2 para Sex, 2 para Age y 2 para Survived.

#Analizamos la distribuci?n de los datos, comprobando cuantos registros existen para cada valor de cada variable
summary(titanic.raw)

#Vamos a trabajar con la libreria arules. Aquellos alumnos que no la tengan instalada, podr?n hacerlo mediante el comando install.packages("arules")
library(arules)

#Extraemos reglas de asociaci?n con el algoritmo Apriori y los valores por defecto (importante asegurarse que estos son los valores por defecto):
#-Soporte minimo: 0.1
#-Confianza minima: 0.8
#-Numero maximo de items (longitud maxima de regla): 10
rules <- apriori(titanic.raw, parameter = NULL, appearance = NULL, control = NULL)

#Mostramos todas las reglas obtenidas por el algoritmo
inspect(rules)
#Mostramos s?lo las 3 mejores reglas en base a la m?trica lift
inspect(head(sort(rules, by ="lift"),3))

###Alumno: Describa cada una de las reglas obtenidas, explicando su significado as? como el significado de las m?tricas existentes para cada regla
#- **Primera regla. Los hombres de la tripulaci?n que no sobrevivieron fueron 670, un 30% del total de las personas 
#que iban a bordo. La proporci?n de hombres que no sobrevivieron y que eran de la tripulaci?n es muy alta, un 99.5%. 
#La probabilidad de que esta regla sea cierta es muy alta, ya que el valor de la m?trica lift es superior a 1.**
  
#- **Segunda regla. Los hombres adultos de la tripulaci?n que no sobrevivieron fueron 670, un 30% del total de las 
#personas que iban a bordo. Teniendo en cuenta la primera regla y esta, podemos afirmar que todos los hombres de la 
#tripulaci?n que murieron fueron adultos. Por eso el valor de las m?tricas de confianza y lift tienen el mismo valor 
#que en la regla anterior.** 
  
#- **Tercera regla. Los hombres que formaron parte de la tripulaci?n fueron 862, un 39% del total de las personas 
#que iban a bordo. La proporci?n de hombres que eran de la tripulaci?n es muy alta, un 97.5%. La probabilidad de que 
#esta regla sea cierta es muy alta, ya que el valor de la m?trica lift es superior a 1. Teniendo en cuenta esto, 
#podr?amos afirmar que la mayor?a de personas de la tripulaci?n fueron hombres.**

#Extraemos reglas de asociaci?n con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.9
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child no pueden aparecer en ningun sitio de la regla y el resto de valores puede aparecer en ambos lugares (antecedente y consecuente)
rules <- apriori(titanic.raw, parameter=list(support=0.1, confidence=0.9), appearance = list(none = c("Age=Adult", "Age=Child"),default="both"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qu? reglas son m?s interesantes y por qu?.
#- **Primera regla. No es interesante. Ya la hemos descrito en el apartado anterior (tercera regla).**
  
#- **Segunda regla. Los hombres que no sobrevivieron fueron 1364, un 61% del total de las personas que iban a bordo. 
#La proporci?n de hombres que no sobrevivieron es muy alta, un 91.5%. La probabilidad de que esta regla sea cierta es
#muy alta, ya que el valor de la m?trica lift es superior a 1. Esta regla es muy interesante porqu? nos indica que 
#m?s del 50% del total de las personas que iban a bordo que murieron fueron hombres.**
  
#- **Tercera regla. No es interesante. Ya la hemos descrito en el apartado anterior (primera regla).**
  
#**Combinando las reglas podemos observar que solo sobrevivieron 192 hombres de la tripulaci?n, de un total de 832. 
#Muy pocos pudieron sobrevivir, la mayor?a de los hombres que murieron pertenec?an a la tripulaci?n.**

#Extraemos reglas de asociaci?n con el algoritmo Apriori y los siguientes valores:
#-Soporte minimo: 0.1
#-Confianza minima: 0.9
#-Numero maximo de items (longitud maxima de regla): 10
#-Los valores Age=Adult y Age=Child solo pueden aparecer en el antecedente. En el consecuente s?lo si sobrevivieron o no
rules <- apriori(titanic.raw, parameter=list(support=0.01, confidence=0.3), appearance = list(lhs = c("Age=Adult", "Age=Child"), rhs = c("Survived=No", "Survived=Yes"),default="none"))
inspect(rules)

###Alumno: Describa los resultados obtenidos, qu? reglas son m?s interesantes y por qu?.

#- **Primera regla. Todas las personas que iban a bordo y que sobrevivieron fueron 711, un 32% del total. La 
#proporci?n de personas que sobrevivieron es muy baja. Muy pocas personas sobrevivieron, solo un 32% del total. La 
#probabilidad de que esta regla sea cierta es total, ya que el valor de la m?trica lift es 1.**
  
#- **Segunda regla. Todas las personas que iban a bordo y que no sobrevivieron fueron 1490, un 68% del total. La 
#proporci?n de personas que no sobrevivieron es muy alta, un 68%. La mayor?a de las personas a bordo muri?. La 
#probabilidad de que esta regla sea cierta es total, ya que el valor de la m?trica lift es 1.**
  
#**Si sumamos el total de personas que sobrevivieron (711) de la primera regla, con el total de personas que murieron
#de la segunda regla (1490), el resultado es el total de personas que iban a bordo en el Titanic (2201).**
  
#- **Tercera regla y Cuarta regla. Los ni?os que sobrevivieron fueron 57, un 2.6% del total de las personas que iban 
#a bordo. Y los ni?os que no sobrevivieron fueron 52, un 2.4% del total de las personas que iban a bordo. La 
#proporci?n de los ni?os que sobrevivieron y la proporci?n de los que no sobrevivieron es muy parecida. Y es m?s 
#probable que sobrevivieran ya que el valor de la m?trica lift en este caso es superior a 1.**
  
#- **Quinta regla y Sexta regla. Los adultos que sobrevivieron fueron 654, un 29.7% del total de las personas que iban
#a bordo. Y los adultos que no sobrevivieron fueron 1438, un 65.3% del total de las personas que iban a bordo. La 
#proporci?n de adultos que no sobrevivieron es mucho mayor (68.7%) que la proporci?n de los adultos que sobrevivieron
#(31.2%).**
  
#**Es muy interesante observar que la proporci?n de los ni?os que sobrevivieron y los que no, est? muy equilibrada. 
#En cambio, en el caso de los adultos no fue as?. La mayor?a muri?.**

#Buscamos la regla "Sex=Female" THEN "Survived=Yes" para ver cuantas mujeres sobrevivieron
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), appearance = list(lhs = c("Sex=Female"), rhs = c("Survived=Yes"),default="none"))
inspect(rules)

#Me quedo s?lo con los valores de soporte, confianza y lift
soporte <- quality(rules)$support
confianza <- quality(rules)$confidence
lift <- quality(rules)$lift
soporte
confianza
lift

###Alumno: Describa los resultados obtenidos, qu? reglas son m?s interesantes y por qu?.
#**Solo se ha encontrado una regla. La regla muestra que las mujeres que sobrevivieron fueron 344, un 15.6% del 
#total de las personas que iban a bordo. Parecen pocas, pero eso se debe a que hab?a pocas mujeres a bordo. Pero 
#muchas de ellas sobrevivieron, ya que la regla presenta valores de confianza (73%) y lift muy altos.**

#Guardar en la variable "numSobreviven" el numero de mujeres de tercerca clase que sobrevivieron al hundimiento del Titanic.
#Para ello, buscar la regla de asociaci?n espec?fica suponiendo que el consecuente incluye el item Survived=Yes.
###Alumno: Describa los resultados obtenidos, qu? regla o reglas son m?s interesantes y por qu?.
##*Primera regla. No es interesante. Ya la hemos descrito en el apartado anterior.**
  
#**Segunda regla. No es muy interesante. Lo sería más si lo comparáramos con otro conjunto de 
#ítems. Que es el caso de la tercera regla.**
  
#**Tercera regla. Las mujeres de la tercera clase que sobrevivieron fueron 90, un 0.41% del total 
#de personas a bordo. Parecen pocas, pero eso se debe a que había pocas mujeres de la tercera 
#clase a bordo. Pero la mitad de ellas sobrevivieron, ya que la regla presenta valores de 
#confianza (50%) y el valor de la métrica lift es superior a 1.**

#####INSERTAR EL C?DIGO AQU?######
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                 appearance = list(lhs = c("Class=3rd", "Sex=Female"), rhs = c("Survived=Yes"),default="none"))
inspect(rules)
numSobreviven <- quality(rules)$count[3]
numSobreviven
##################################

#Sumar el numero de mujeres de cada clase que no sobrevivieron al hundimiento del titanic. Comprobar que la suma es igual al numero de mujeres que no sobrevivieron al hundimiento del Titanic.
#Para ello, buscar las reglas de asociaci?n espec?ficas suponiendo que el consecuente incluye el item Survived=No.
#La variable sumaMujeresMuertas (obtenida de la suma de los resultados de las reglas espec?ficas) tiene que ser igual a la variable
#numMujeresMuertas obtenida a partir de la regla de asociaci?n espec?fica.
###Alumno: Describa claramente el procedimiento seguido y explique con claridad los resultados alcanzados
#Primero buscamos la regla del numMujeresMuertas, fueron 126.
#Después buscamos las reglas para saber el número de las mujeres que murieron para cada variable Class 
#{"1st", "2nd", "3rd", "Crew"}.
# Guardamos esos valores en las siguientes variables: MujeresMuertas1st (4), MujeresMuertas2nd (13), 
#MujeresMuertas3rd (106) y MujeresMuertasCrew (3).
#Finalmente sumamos estos valores y comprobamos que su suma nos da el mismo valor que sumaMujeresMuertas.
#####INSERTAR EL C?DIGO AQU?######
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                 appearance = list(lhs = c("Sex=Female"), rhs = c("Survived=No"),default="none"))

numMujeresMuertas <- quality(rules)$count[1]
numMujeresMuertas

MujeresMuertas1st <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                             appearance = list(lhs = c("Class=1st", "Sex=Female"), 
                                               rhs = c("Survived=No"),default="none"))
inspect(MujeresMuertas1st)

MujeresMuertas2nd <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                             appearance = list(lhs = c("Class=2nd", "Sex=Female"), 
                                               rhs = c("Survived=No"),default="none"))
inspect(MujeresMuertas2nd)

MujeresMuertas3rd <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                             appearance = list(lhs = c("Class=3rd", "Sex=Female"), 
                                               rhs = c("Survived=No"),default="none"))
inspect(MujeresMuertas3rd)

MujeresMuertasCrew <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                              appearance = list(lhs = c("Class=Crew", "Sex=Female"), 
                                                rhs = c("Survived=No"),default="none"))
inspect(MujeresMuertasCrew)

MujeresMuertas1st <- quality(MujeresMuertas1st)$count[3]
MujeresMuertas2nd <- quality(MujeresMuertas2nd)$count[3]
MujeresMuertas3rd <- quality(MujeresMuertas3rd)$count[3]
MujeresMuertasCrew <- quality(MujeresMuertasCrew)$count[3]
sumaMujeresMuertas <- MujeresMuertas1st + MujeresMuertas2nd + MujeresMuertas3rd + 
  MujeresMuertasCrew
sumaMujeresMuertas
##################################

###Alumno: Para dar respuesta a las siguientes cuestiones que se plantean, es necesario buscar reglas espec?ficas para el conocimiento que estamos buscando.
#Lea detenidamenta las cuestiones que se plantean y responde a ellas de manera clara y concisa.
#Explica de manera clara y concisa c?mo has obtenido dichos resultados o c?mo has llegado a dichas conclusiones.
###Alumno: Las cuestiones planteadas son:
#a) ?Se cumpli? la norma de los ni?os y las mujeres primero? 
rules <- apriori(titanic.raw, parameter=list(support=0.01, confidence=0, minlen=3), 
                 appearance = list(lhs = c("Age=Adult", "Age=Child", "Sex=Male", "Sex=Female"), 
                                   rhs = c("Survived=No"),default="none"))
inspect(rules)
#**Sí. Como podemos observar, el número de niños y mujeres que no sobrevivieron fueron un total 
#de 144 (35 + 109). Muy pocos niños y muy pocas mujeres murieron en general. Acorde a eso, los 
#valores del soporte, confianza y lift son muy bajos. En cambio, sí que murieron muchos hombres, 
#un total de 1329. Un 60% de las personas que murieron y que iban a bordo fueron los hombres.**

#b) ?Tuvo mayor peso la clase a la que pertenec?a el pasajero?
rules <- apriori(titanic.raw, parameter=list(support=0, confidence=0, minlen=2), 
                 appearance = list(lhs = c("Class=Crew", "Class=1st", "Class=2nd", "Class=3rd"), 
                                   rhs = c("Survived=No"),default="none"))
inspect(rules)
#Sí. Se puede observar muy bien en estas cuatro reglas. Que representant la división por Class de 
#las personas que murieron a bordo. Vemos como las personas de la tripulación y de la tercera 
#clase son los que más número de muertos representan.

#c) ¿Podemos saber si la tripulaci?n se comport? heroicamente?
# Sí, por la regla anterior. Podemos observar que las personas que más no sobrevivieron fueron 
#los de la tripulacion

###Alumno: Obtener las reglas de mayor longitud (las que incluyan un mayor numero de variables). Utilizar diferentes umbrales de soporte y confianza y mostrar qu? reglas son las de mauyor longitud para los diferentes umbrales.
#####INSERTAR EL C?DIGO AQU?######
rules <- apriori(titanic.raw, parameter = list(support=0.5, confidence=0.9, target="rules"))
inspect(sort(rules, by ="count"))
##################################

