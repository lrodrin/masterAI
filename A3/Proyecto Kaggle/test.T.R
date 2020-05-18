library(xgboost)
library(data.table)
library(Matrix)
library(lattice)
library(ggplot2)
library(caret)

# load the data
completeData <- as.data.frame(fread("data.csv", header = T, stringsAsFactors = T))

# Data cleaning
completeData$shot_distance[completeData$shot_distance>45] <- 45
dropped_features <- c("seconds_remaining", "minutes_remaining", "team_name", "team_id", "game_event_id",
                      "game_id", "matchup", "lon", "lat", "game_date")
cat_features <- c("action_type", "combined_shot_type", "period", "season", "shot_type",
                  "shot_zone_area", "shot_zone_basic", "shot_zone_range",
                  "opponent")
for(col in cat_features){
  completeData[,col] <- as.character(completeData[,col])
}


################## Feature engineering #####################
############################################################
completeData$time_remaining <- completeData$minutes_remaining*60+completeData$seconds_remaining;
completeData$last5secs <- (completeData$time_remaining < 5) * 1
completeData$home <- grepl('vs',completeData$matchup) * 1
completeData$month <- substr(completeData$game_date, 6, 7)
completeData$year <- substr(completeData$game_date, 1, 4)


# One-hot encoding
# trainM<-data.matrix(train, rownames.force = NA)
ohe_features <- c('action_type', 'combined_shot_type', 'period', 'season', 'shot_type',
                  'shot_zone_area','shot_zone_basic','shot_zone_range', 'month', 'year',
                  'opponent')
dummies <- dummyVars(as.formula(paste0('~ ',paste(ohe_features, collapse=" + "))), data=completeData) #based on cat_features
df_ohe <- as.data.frame(predict(dummies, newdata=completeData))
names(df_ohe) <- make.names(colnames(df_ohe))
completeData <- cbind(completeData[,!names(completeData) %in% ohe_features], df_ohe)


###########################################################
###########################################################

# split data into train and test set
train<-subset(completeData, !is.na(completeData$shot_made_flag))
test<-subset(completeData, is.na(completeData$shot_made_flag))

# remove id as it does not provide any predictive power
test.id <- test$shot_id
train$shot_id <- NULL
test$shot_id <- NULL

train <- train[,!names(train) %in% dropped_features]
test <- test[,!names(test) %in% dropped_features]

library(ggplot2)
library(randomForest)
trControl <- trainControl(method="cv",number=5,verboseIter=TRUE)
rf <- train(shot_made_flag ~ ., data=train, method="rf",metric="logLoss")
