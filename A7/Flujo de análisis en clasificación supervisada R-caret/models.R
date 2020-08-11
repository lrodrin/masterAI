# Creating stratified folds for 5-fold cross validation repeated 
# 3 times (i.e., create 30 random stratified samples)
set.seed(1985)
cv.folds <- createMultiFolds(train.df$target, k = 5, times = 3)

cv.cntrl <- trainControl(method = "repeatedcv", number = 5, repeats = 3, 
                         index = cv.folds, summaryFunction = twoClassSummary, classProbs = T,
                         allowParallel = TRUE, savePredictions = TRUE)


gc()

cl <- makeCluster(3)
registerDoParallel(cl)
getDoParWorkers()

set.seed(342)
modelo_knn <- train(target ~ ., data = train.df,
                    method = "knn",
                    metric = "Accuracy",
                    trControl = cv.cntrl)
modelo_knn

# Stop parallel computing
stopCluster(cl)