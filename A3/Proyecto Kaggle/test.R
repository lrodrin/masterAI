library(e1071)
input <- read.csv("data.csv", sep = "," ,stringsAsFactors = FALSE)
cat("splitting data to train and test......\n")
train <- input[!is.na(input$shot_made_flag),]
test <- input[is.na(input$shot_made_flag),]
cat("precessing the train data......\n")
train$shot_made_flag <- as.factor(train$shot_made_flag)
train$shot_made_flag <- factor(train$shot_made_flag, levels = c("1", "0"))

#handle with the train features
train$shot_distance[train$shot_distance>40] <- 40
train$time_remaining <- train$minutes_remaining*60+train$seconds_remaining;

#normalize function
myNormalize <- function (target) {
  (target - min(target))/(max(target) - min(target))
}
train$shot_distance <- myNormalize(train$shot_distance)
train$time_remaining <- myNormalize(train$time_remaining)

train_dat <- data.frame(train$shot_distance, train$time_remaining, train$shot_made_flag)
colnames(dat) <- c("shot_distance", "time_remaining", "shot_made_flag")

#handle with the test features
test$shot_distance[test$shot_distance>40] <- 40
test$time_remaining <- test$minutes_remaining*60+test$seconds_remaining;
test$shot_distance <- myNormalize(test$shot_distance)
test$time_remaining <- myNormalize(test$time_remaining)

test_dat <- data.frame(test$shot_distance, test$time_remaining, test$shot_made_flag)
colnames(test_dat) <- c("shot_distance", "time_remaining", "shot_made_flag")

#build svm model by train data
wts=c(1,1)
names(wts)=c(1,0)
model <- svm(shot_made_flag~., data=dat, kernel="radial",  gamma=1, cost=1, class.weights=wts)

#show accuracy by train data
pred_train <- predict(model, test_dat[,-3])
table(train_data[,3], pred_train)

#svm model predict the test data
newdata <- data.frame(test_dat[,-3])
pred_test <- predict(model, newdata)
submission <- data.frame(shot_id=test$shot_id, shot_made_flag=pred_test)
cat("Saving the submission file\n");
write.csv(submission, "svm.csv", row.names = F)

