library(caret)

# Creating stratified folds for 5-fold cross validation repeated 
# 3 times (i.e., create 30 random stratified samples)
set.seed(1985)
cv.folds <- createMultiFolds(train.df$target, k = 5, times = 3)

cv.cntrl <- trainControl(method = "repeatedcv", number = 5, repeats = 3, 
                         index = cv.folds, summaryFunction = twoClassSummary, classProbs = T,
                         allowParallel = TRUE, savePredictions = TRUE)


gc()

num_folds <- trainControl(method = "cv", number = 5)
parameter_grid <- expand.grid(k = 1:3) # Explore values of `k` between 1 and 5.

set.seed(1985)
grid_search <- train(
  target ~ .,  # Use all variables in `train_processed` except `id`.
  data = train.df, 
  method = "knn",
  trControl = num_folds, 
  tuneGrid = parameter_grid
)

grid_search

# Stop parallel computing
stopCluster(cl)