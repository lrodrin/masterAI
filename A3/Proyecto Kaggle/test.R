library(e1071)
library(lattice)
library(ggplot2)
library(caret)
library(MASS)
library(randomForest)

data <- read.csv("data.csv", sep = "," , stringsAsFactors = FALSE)

##remove outliers
outliers <- boxplot.stats(data$shot_distance)$out  # outlier values.
data <- data[-which(data$shot_distance %in% outliers),]
outliers <- boxplot.stats(data$shot_distance)$out  # outlier values.


cat("splitting data to train and test......\n")
train <- subset(data, !is.na(data$shot_made_flag))
test <- subset(data, is.na(data$shot_made_flag))

cat("precessing the train data......\n")
train$shot_made_flag <- as.factor(train$shot_made_flag)
train$shot_made_flag <- factor(train$shot_made_flag, levels = c("1", "0"))

#handle with the train features
train$shot_distance[train$shot_distance > 40] <- 40
train$time_remaining <- train$minutes_remaining*60 + train$seconds_remaining

#normalize function
nnorm <- function (target) {
  (target - min(target))/(max(target) - min(target))
}
train$shot_distance <- nnorm(train$shot_distance)
train$time_remaining <- nnorm(train$time_remaining)

#create subset of train to predict
train_dat <- data.frame(train$shot_distance, train$time_remaining, train$shot_made_flag)
colnames(train_dat) <- c("shot_distance", "time_remaining", "shot_made_flag")
colnames(train_dat) <- make.names(colnames(train_dat))
train_dat <- train_dat[order(train_dat$shot_made_flag), ] # order by shot_made_flag 

#handle with the test features
test$shot_distance[test$shot_distance > 40] <- 40
test$time_remaining <- test$minutes_remaining*60 + test$seconds_remaining;
test$shot_distance <- nnorm(test$shot_distance)
test$time_remaining <- nnorm(test$time_remaining)

#create subset of test to predict
test_dat <- data.frame(test$shot_distance, test$time_remaining, test$shot_made_flag)
colnames(test_dat) <- c("shot_distance", "time_remaining", "shot_made_flag")
colnames(test_dat) <- make.names(colnames(test_dat))

#prediction
ctrl <- trainControl(method="cv",number=5, classProbs = FALSE)

#build model by train data
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="rf",
               trControl=ctrl)

#show accuracy by train data
nb_trainPred <- predict(model, train_dat)
accuracy <- (postResample(nb_trainPred, train_dat$shot_made_flag))[1]
trainig_error <- 100 - (accuracy*100)
paste("Accuracy =", accuracy, "Trainig_error =", trainig_error, "%")

#model predict the test data
newdata <- data.frame(test_dat[,-3])
nb_testPred <- predict(model, newdata)
submission <- data.frame(shot_id=test$shot_id, shot_made_flag=nb_testPred)
cat("Saving the submission file\n");
write.csv(submission, "rf.csv", row.names = FALSE)