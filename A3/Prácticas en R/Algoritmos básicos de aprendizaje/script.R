library(caret)
library(rJava)
library(RWeka)
library(ggplot2)

glass <- read.table("glass.data", header = FALSE, sep = ",")

# Add column names
names(glass) <- c("Id number", "RI", "Na", "Mg", "Al", "Si", "K", "Ca", "Ba", "Fe",
                 "Type of glass")

# Make valid column names 
colnames(glass) <- make.names(colnames(glass))

# Delete Id number column
glass <- subset(glass, select = -Id.number)

# Rename Type of glass to Class
colnames(glass)[10] <- "Class"

# Order for column Class
glass <- glass[order(glass$Class), ]

# Check for NA values
any(is.na(glass))

# Remove Class elements < 3
glass <- subset(glass , glass$Class < 3)

for (i in 1:146) {
  if (glass$Class[i] == 1){
    glass$Class[i] <- 'positive'
  }
  else {
    glass$Class[i] <- 'negative'
  }
}

# Change the type of class variable Class to factor
glass[,10]=as.factor(glass[,10])

# data splitting
set.seed(123)
inTraining <- createDataPartition(glass$Class, p = .7, list = FALSE)
training <- glass[ inTraining,]
str(training)
testing  <- glass[-inTraining,]
str(testing)
fitControl <- trainControl(method = "cv", 
                           number = 5,
                           classProbs = FALSE)

# OneR
oner <- train(Class ~ ., data = training,
              method = "OneR",
              trControl = fitControl)

onerPredict <- predict(oner, newdata = testing)
cm_oner <- confusionMatrix(onerPredict, testing$Class)

onerPredictProb <- predict(oner, newdata = testing, type = "prob")
onerPred <- prediction(onerPredictProb$positive, testing$Class)
onerPerf <- performance(onerPred, "tpr", "fpr")

# kNN with k=1, k=3
grid_knn <- expand.grid(k = seq(1, 3))

knn <- train(Class ~ ., data = training,
              method = "knn",
              trControl = fitControl,
              tuneGrid = grid_knn)
knn

knnPredict <- predict(knn, newdata = testing)
cm_knn <- confusionMatrix(knnPredict, testing$Class)

knnPredictProb <- predict(knn, newdata = testing, type = "prob")
knnPred <- prediction(knnPredictProb$positive, testing$Class)
knnPerf <- performance(knnPred, "tpr", "fpr")

# Multilayer Perceptrón
grid_mlp = expand.grid(layer1 = 3,
                       layer2 = 5,
                       layer3 = 7)

mlp <- train(Class ~., data = training,
             method = "mlpML",
             trControl = fitControl,
             tuneGrid = grid_mlp)
mlp

mlpPredict <- predict(mlp, newdata = testing)
cm_mlp <- confusionMatrix(mlpPredict,testing$Class)

mlpPredictProb <- predict(mlp, newdata = testing, type = "prob")
mlpPred <- prediction(mlpPredictProb$positive, testing$Class)
mlpPerf <- performance(mlpPred, "tpr", "fpr")

# ROC
plot(onerPerf, col = "orange", add = FALSE)
plot(knnPerf, col = "blue", add = TRUE)
plot(mlpPerf, col = "black", add = TRUE)
title(main = "CURVAS ROC")
legend("bottomright", legend = c("OnerR", "kNN", "MLP"),
       col = c("orange", "blue", "black"),
       lty = 1, lwd = 1)

