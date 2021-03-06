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

# Make valid column names 
colnames(data) <- make.names(colnames(data))

# Check for missing values
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
# Specifiy the type of resampling
fitControl <- trainControl(method="repeatedcv", 
                           number=10, 
                           repeats=1,
                           classProbs=TRUE)
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
                          "SVM (linear kernel)"=svm))
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

# Calculate AUC value for all the models
library(AUC)
auc(roc(nbPredict, data_testing$Class))
auc(roc(dtPredict, data_testing$Class))
auc(roc(nnPredict, data_testing$Class))
auc(roc(knnPredict, data_testing$Class))
auc(roc(svmPredict, data_testing$Class))

#5. Plot the ROC curves of the models
library(ROCR)

# a) Calculate again the predictions on the test set but now setting the type parameter of the 
# predict function to "prob"

# Model Naive Bayes
nbPredictProb <- predict(nb, newdata=data_testing, type = "prob")
head(nbPredictProb)

# Model Decision Tree
dtPredictProb <- predict(dt, newdata=data_testing, type = "prob")
head(dtPredictProb)

# Model Neural Network
nnPredictProb <- predict(nn, newdata=data_testing, type = "prob")
head(nnPredictProb)

# Model Nearest Neighbour
knnPredictProb <- predict(knn, newdata=data_testing, type = "prob")
head(knnPredictProb)

# Model SVM (linear kernel)
svmPredictProb <- predict(svm, newdata=data_testing, type = "prob")
head(svmPredictProb)

# b) Construct a "prediction" object for each classifier using the vector of estimated 
# probabilities for the positive class as the first parameter, and the vector of actual class 
# labels as the second parameter.

# Model Naive Bayes
nbPred <- prediction(nbPredictProb$positive, data_testing$Class)   

# Model Decision Tree
dtPred <- prediction(dtPredictProb$positive, data_testing$Class)   

# Model Neural Network
nnPred <- prediction(nnPredictProb$positive, data_testing$Class)   

# Model Nearest Neighbour
knnPred <- prediction(knnPredictProb$positive, data_testing$Class)   

# Model SVM (linear kernel)
svmPred <- prediction(svmPredictProb$positive, data_testing$Class)   

# c) Calculate the measures we want to plot on the y-axis (TPR) and on the x-axis (FPR) by 
# using the performance function.

# Model Naive Bayes
nbPerf <- performance(nbPred,"tpr","fpr")

# Model Decision Tree
dtPerf <- performance(dtPred,"tpr","fpr")

# Model Neural Network
nnPerf <- performance(nnPred,"tpr","fpr")

# Model Nearest Neighbour
knnPerf <- performance(knnPred,"tpr","fpr")

# Model SVM (linear kernel)
svmPerf <- performance(svmPred,"tpr","fpr")

# d) Draw all the curves in the same plot.
plot(nbPerf, col="orange", add=FALSE, main="Curvas ROC")
plot(dtPerf, col="blue", add=TRUE, main="Curvas ROC")
plot(nnPerf, col="red", add=TRUE, main="Curvas ROC")
plot(knnPerf, col="green", add=TRUE, main="Curvas ROC")
plot(svmPerf, col="magenta", add=TRUE, main="Curvas ROC")
legend("bottomright", legend = c("NB","DT", "NN", "kNN", "SVM"), 
       col = c("orange", "blue", "red", "green", "magenta"), 
       lty = 1, lwd = 1)