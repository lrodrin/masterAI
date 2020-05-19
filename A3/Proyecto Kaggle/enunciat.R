library(data.table)
library(MASS)

data <- as.data.frame(fread("data.csv", header = TRUE, stringsAsFactors = TRUE))

train <- subset(data, !is.na(data$shot_made_flag))
test <- subset(data, is.na(data$shot_made_flag))

model <- lda(shot_made_flag ~ ., train)