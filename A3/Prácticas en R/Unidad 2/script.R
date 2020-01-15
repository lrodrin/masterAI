#1. Carga los datos en R. Nombra las columnas para identificar major el tablero, 
#como si se visitarán de izquierda a derecha y de arriba a abajo.
#Comprueba si hay valores faltantes.
data <- read.table("tic-tac-toe.data.txt", header=FALSE, sep=",")
names(data) <- c("top-left-square", "top-middle-square", "top-right-square",
"middle-left-square", "middle-middle-square", "middle-right-square", "bottom-left-square", 
"bottom-middle-square", "bottom-right-square", "Class")
any(is.na(data))

#2. Lee la sección "data splitting" de la web de “caret”. A continuación parte los
#datos en 70% para entrenamiento y 30% de test manteniendo la proporción original de 
#clases.
library(caret)
inTraining <- createDataPartition(data$Class, p=.7, list=FALSE)
data_training <- data[ inTraining,]
data_testing  <- data[-inTraining,]

#3.
#train_control <- trainControl(method="boot", number=100)
#model <- train(Class~., data=data_training, trControl=train_control, method="nb")
#print(model)
library(naivebayes)
set.seed(1)
naive_bayes_via_caret <- train(Class ~ ., 
                               data = data_training, 
                               method = "naive_bayes", 
                               usepoisson = TRUE)

naive_bayes_via_caret