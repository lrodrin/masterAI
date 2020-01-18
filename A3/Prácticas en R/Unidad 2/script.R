# 1.
data <- read.table("tic-tac-toe.data.txt", header=FALSE, sep=",")
names(data) <- c("top-left-square", 
                 "top-middle-square", 
                 "top-right-square", 
                 "middle-left-square", 
                 "middle-middle-square", 
                 "middle-right-square", 
                 "bottom-left-square", 
                 "bottom-middle-square",
                 "bottom-right-square", 
                 "Class")
# make valid Column Names 
colnames(data) <- make.names(colnames(data))

# check for missing values
any(is.na(data))

# 2.
library(lattice)
library(ggplot2)
library(caret)
set.seed(825)
inTraining <- createDataPartition(data$Class, p=.7, list=FALSE)
data_training <- data[ inTraining,]
data_testing  <- data[-inTraining,]

#3.
# specifiy the type of resampling
fitControl <- trainControl(method="repeatedcv", 
                           number=10, 
                           repeats=1)
# Model Naive Bayes
library(e1071)
library(naivebayes)
set.seed(825)
nb <- train(Class ~ ., 
            data=data_training, 
            method="naive_bayes",
            trControl=fitControl)
nb

# Model Decision Tree
library(rpart)
set.seed(825)
dt <- train(Class ~ ., 
            data=data_training, 
            method="rpart2",
            trControl=fitControl)
dt

# Model Neural Network
library(nnet)
set.seed(825)
nn <- train(Class ~ ., 
            data=data_training, 
            method="nnet",
            trControl=fitControl)
nn

# Model Nearest Neighbour
set.seed(825)
knn <- train(Class ~ ., 
             data=data_training, 
             method="knn",
             trControl=fitControl)
knn

# Model SVM (linear kernel)
library(kernlab)
set.seed(825)
svm <- train(Class ~ ., 
             data=data_training, 
             method="svmLinear",
             trControl=fitControl)
svm

# Collecting the training resampling results
resamps <- resamples(list("Naive Bayes"=nb,
                          "Decision Tree"=dt,
                          "Neural Network"=nn,
                          "Nearest Neighbour"=knn,
                          "SVM (linear kernel)" = svm))
summary(resamps)

#4.
# Model Naive Bayes
nbPredict <- predict(nb, newdata=data_testing)
confusionMatrix(nbPredict, data_testing$Class)

# Model Decision Tree
dtPredict <- predict(dt, newdata=data_testing)
confusionMatrix(dtPredict, data_testing$Class)

# Model Neural Network
nnPredict <- predict(nn, newdata=data_testing)
confusionMatrix(nnPredict, data_testing$Class)

# Model Nearest Neighbour
knnPredict <- predict(knn, newdata=data_testing)
confusionMatrix(knnPredict, data_testing$Class)

# Model SVM (linear kernel)
svmPredict <- predict(svm, newdata=data_testing)
confusionMatrix(svmPredict, data_testing$Class)

# Collecting the testing resampling results
postResample(nbPredict, data_testing$Class)
postResample(dtPredict, data_testing$Class)
postResample(nnPredict, data_testing$Class)
postResample(knnPredict, data_testing$Class)
postResample(svmPredict, data_testing$Class)

# Calculate AUC value
library(AUC)

#5.
#a)
#b)
#c)