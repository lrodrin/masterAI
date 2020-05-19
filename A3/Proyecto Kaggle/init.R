library(data.table)
library(caret)

##loading data
data <- as.data.frame(fread("data.csv", header = T, stringsAsFactors = T))

cat("splitting data to train and test......\n")
train <- subset(data, !is.na(data$shot_made_flag))
test <- subset(data, is.na(data$shot_made_flag))

##shot_distance
train$shot_distance[train$shot_distance > 40] <- 40

##minutes_remaining and seconds_remaining
train$time_remaining <- train$minutes_remaining * 60 + train$seconds_remaining;
train$time_remaining <- as.integer(train$time_remaining)

#normalize shot_distance and time_remaining
myNormalize <- function (target) {
  (target - min(target))/(max(target) - min(target))
}
train$shot_distance <- myNormalize(train$shot_distance)
train$time_remaining <- myNormalize(train$time_remaining)

##shot_made_flag
train$shot_made_flag <- as.factor(train$shot_made_flag)
train$shot_made_flag <- factor(train$shot_made_flag, levels = c("1", "0"))

##season - levels: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 97 98 99
train$season <- str_split_fixed(train$season, "-", 2)[, 2]
train$season <- as.integer(train$season)
train$season <- as.factor(train$season)

##dropping unneeded variables
drops <- c("game_event_id", "game_id", "loc_x", "loc_y", "lat", "lon",
           "minutes_remaining", "seconds_remaining", "shot_distance",
           "shot_zone_area", "shot_zone_basic", "shot_zone_range",
           "team_id", "team_name", "game_date", "matchup", "shot_id")

train <- train[ , !(names(train) %in% drops)]
train <- train[order(train$shot_made_flag), ] # order by shot_made_flag 