#script_aminos_KB

library(ggplot2)
library(readr) 
library(dplyr)
library(rpart)

data_kb <- read.csv("data.csv", head = TRUE, sep = ",")

data_kb$shot_made_flag <- as.factor(data_kb$shot_made_flag)
data_kb$playoffs <- as.factor(data_kb$playoffs)

#decomposing game_date in year, month and day
data_kb$data_list <- strsplit(as.character(data_kb$game_date), split = "-")
n <- length(data_kb$action_type)
data_kb$year <- 0
data_kb$month <- 0
data_kb$day <- 0

for(i in 1:n) {
  data_kb$year[i] <- as.numeric(data_kb$data_list[[i]][1])
  data_kb$month[i] <- as.numeric(data_kb$data_list[[i]][2])
  data_kb$day[i] <- as.numeric(data_kb$data_list[[i]][3])
}

data_kb$data_list<-NULL
data_kb$game_date<-NULL
data_kb$time_remaining <- data_kb$minutes_remaining * 60 + data_kb$seconds_remaining

#splitting data into train and test
train_kb <- data_kb[!is.na(data_kb$shot_made_flag), ]
test_kb <- data_kb[is.na(data_kb$shot_made_flag), ]

#glm
model <- glm(shot_made_flag~time_remaining+combined_shot_type+playoffs+
            shot_zone_area+shot_zone_basic+year+shot_type+opponent,
            data = train_kb, family = binomial(link = "logit"))
# anova(model)

#prediction
pred <- predict(model, test_kb, type = "response")
pred <- data.frame("shot_id" = test_kb$shot_id, "shot_made_flag" = pred)
write.csv(pred, "glm.csv", quote = FALSE, row.names = FALSE)