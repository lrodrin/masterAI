#predict

library(data.table)
data <- as.data.frame(fread("data.csv", header = TRUE, stringsAsFactors = TRUE))

##dropping unneeded variables
drops <- c("game_event_id", "game_id", "loc_x", "loc_y", "lat", "lon",
           "shot_zone_area", "shot_zone_basic", "shot_zone_range",
           "team_id", "team_name", "game_date", "matchup",
           "minutes_remaining", "seconds_remaining")

cat("splitting data to train and test......\n")
train <- data[!is.na(data$shot_made_flag),]
test <- data[is.na(data$shot_made_flag),]


cat("precessing the train data......\n")
train$shot_made_flag <- as.factor(train$shot_made_flag)
outliers <- boxplot(train$shot_distance, plot=FALSE)$out
min(outliers)

#handle with the train features
train$shot_distance[train$shot_distance > 40] <- 40
train$time_remaining <- train$minutes_remaining * 60 + train$seconds_remaining
train <- train[ , !(names(train) %in% drops)]

#normalize function
myNormalize <- function (target) {
  (target - min(target))/(max(target) - min(target))
}
train$shot_distance <- myNormalize(train$shot_distance)
train$time_remaining <- myNormalize(train$time_remaining)
train_dat <- data.frame(train$shot_distance, train$time_remaining, train$shot_made_flag)
colnames(train_dat) <- c("shot_distance", "time_remaining", "shot_made_flag")

#handle with the test features
test$shot_distance[test$shot_distance > 40] <- 40
test$time_remaining <- test$minutes_remaining * 60 + test$seconds_remaining
test <- test[ , !(names(test) %in% drops)]

test$shot_distance <- myNormalize(test$shot_distance)
test$time_remaining <- myNormalize(test$time_remaining)
test_dat <- data.frame(test$shot_distance, test$time_remaining, test$shot_made_flag)
colnames(test_dat) <- c("shot_distance", "time_remaining", "shot_made_flag")

#build model by train data
model <- glm(shot_made_flag~., data=train_dat, family = binomial(link = "logit"))

#anova(model)

# show accuracy by train data
# predict generates a vector of probabilities that we threshold at 0.5
newdata <- data.frame(train_dat[,-3])
pred <- predict(model, newdata, type = 'response')

newdf <- data.frame(shot_id=train$shot_id, shot_made_flag=pred)
newdf$shot_made_flag <- myNormalize(newdf$shot_made_flag)
preds_th <- ifelse(as.numeric(pred) > 0.5,1,0)

# make the Confusion Matrix
cm <- table(newdf$shot_made_flag, preds_th)
accuracy <- (cm[1,1] + cm[2,2]) / (cm[1,1] + cm[2,2] + cm[1,2] + cm[2,1])

#model predict the test data
newdata <- data.frame(test_dat[,-3])
pred <- predict(model, newdata)
submission <- data.frame(shot_id=test$shot_id, shot_made_flag=pred)
submission$shot_made_flag <- myNormalize(submission$shot_made_flag)

cat("saving the submission file\n");
write.csv(submission, "glm.csv", row.names = FALSE)
