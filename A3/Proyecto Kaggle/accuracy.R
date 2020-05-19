library(caret)
library(MASS)
library(randomForest)

data <- read.csv("data.csv", sep = "," , stringsAsFactors = FALSE)

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
myNormalize <- function (target) {
  (target - min(target))/(max(target) - min(target))
}
train$shot_distance <- myNormalize(train$shot_distance)
train$time_remaining <- myNormalize(train$time_remaining)

#create subset of train to predict
train_dat <- data.frame(train$shot_distance, train$time_remaining, train$shot_made_flag)
colnames(train_dat) <- c("shot_distance", "time_remaining", "shot_made_flag")
colnames(train_dat) <- make.names(colnames(train_dat))
train_dat <- train_dat[order(train_dat$shot_made_flag), ] # order by shot_made_flag 

#handle with the test features
test$shot_distance[test$shot_distance > 40] <- 40
test$time_remaining <- test$minutes_remaining*60 + test$seconds_remaining;
test$shot_distance <- myNormalize(test$shot_distance)
test$time_remaining <- myNormalize(test$time_remaining)

#create subset of test to predict
test_dat <- data.frame(test$shot_distance, test$time_remaining, test$shot_made_flag)
colnames(test_dat) <- c("shot_distance", "time_remaining", "shot_made_flag")
colnames(test_dat) <- make.names(colnames(test_dat))

#prediction
fitControl <- trainControl(method = "cv",
                           number = 5,
                           classProbs = FALSE)

#build model by train data
set.seed(123)
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="lda",
               trControl=fitControl)

set.seed(123)
model <- train(shot_made_flag ~ .,
            data=train_dat,
            method="naive_bayes",
            trControl=fitControl)
set.seed(123)
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="rpart2",
               trControl=fitControl)
set.seed(123)
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="nnet",
               trControl=fitControl)

set.seed(123)
grid_knn <- expand.grid(k = seq(1, 3))
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="knn",
               trControl=fitControl, tuneGrid = grid_knn)
set.seed(123)
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="svmLinear",
               trControl=fitControl)

set.seed(123)
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="OneR",
               trControl=fitControl)


set.seed(123)
grid_mlp = expand.grid(layer1 = 3, layer2 = 5, layer3 = 7)
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="mlpML",
               trControl=fitControl, tuneGrid = grid_mlp)

set.seed(123)
model <- train(shot_made_flag ~ .,
               data=train_dat,
               method="rf",
               trControl=fitControl)

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