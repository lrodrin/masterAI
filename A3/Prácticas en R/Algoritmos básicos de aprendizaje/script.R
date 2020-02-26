library(lattice)
library(ggplot2)
library(caret)
library(RWeka)
glass <- read.table("glass.data", header = FALSE, sep = ",")
head(glass, 10)

# Add column names
names(glass) <- c("Id number", "RI", "Na", "Mg", "Al", "Si", "K", "Ca", "Ba", "Fe",
                 "Type of glass")

# Make valid column names 
colnames(glass) <- make.names(colnames(glass))

# Check for NA values
any(is.na(glass))

# Delete Id number column
glass$Id.number <- NULL

# 
set.seed(123)
inTraining <- createDataPartition(glass$Type.of.glass, p = .7, list = FALSE)
training <- glass[ inTraining,]
str(training)
testing  <- glass[-inTraining,]
str(testing)

# Specifiy the type of resampling
fitControl <- trainControl(method = "repeatedcv", 
                           number = 5, 
                           repeats = 1,
                           classProbs = TRUE)

# OneR
set.seed(123)
oner <- train(Type.of.glass ~ ., data = training,
              method = "OneR",
              trControl = fitControl)
oner

onerPredict <- predict(oner, newdata = testing)
confusionMatrix(onerPredict, testing$Type.of.glass)

# kNN con k=1, k=3
set.seed(123)
# Multilayer Perceptrón
set.seed(123)
