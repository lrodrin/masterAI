#1. Carga los datos en R. Nombra las columnas para identificar major el tablero, 
#como si se visitarán de izquierda a derecha y de arriba a abajo.
data <- read.table("tic-tac-toe.data.txt", header=FALSE, sep=",")
names(data) <- c("top-left-square", "top-middle-square", "top-right-square",
"middle-left-square", "middle-middle-square", "middle-right-square", "bottom-left-square", 
"bottom-middle-square", "bottom-right-square", "Class")

#Comprueba si hay valores faltantes.
any(is.na(data))

#2. Lee la sección "data splitting" de la web de “caret”. A continuación parte los
#datos en 70% para entrenamiento y 30% de test manteniendo la proporción original de 
#clases.
library(caret)
set.seed(998)
inTraining <- createDataPartition(data$Class, p=.7, list=FALSE)
data_training <- data[ inTraining,]
data_testing  <- data[-inTraining,]

#3.
fitControl <- trainControl(method = "cv", 
                           number = 10, 
                           repeats = 1)
# Naive Bayes
library(naivebayes)
set.seed(825)
nb <- train(Class ~ ., data = data_training, 
            method = "naive_bayes",
            trControl = fitControl)

# Decision Tree
library(rpart)
set.seed(825)
dt <- train(Class ~ ., data = data_training, 
            method = "rpart",
            trControl = fitControl,
            tuneLength = 10)

# Neural Network
library(nnet)
set.seed(825)
nn <- train(Class ~ ., data = data_training, 
            method = "nnet",
            trControl = fitControl)

# Nearest Neighbour
library(snn)
set.seed(825)
snn <- train(Class ~ ., data = data_training, 
             method = "snn",
             trControl = fitControl)

# SVM (linear kernel)
library(kernlab)
set.seed(825)
svm <- train(Class ~ ., data = data_training, 
            method = "svmLinear",
            trControl = fitControl)

resamps <- resamples(list(NB = nb,
                          NN = nn,
                          KNN = snn,
                          SVM = svm))
resamps
summary(resamps)







