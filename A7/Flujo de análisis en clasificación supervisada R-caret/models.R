library(caret)

source('data.R')

# Since this is a classification problem, let’s convert target to a categorical variable.
train_processed$target <- as.factor(train_processed$target)


## KNN
num_folds <- trainControl(method = "cv", number = 5)
parameter_grid <- expand.grid(k = 1:3) # Explore values of `k` between 1 and 3.

knn <- train(
  target ~ .,  # Use all variables in `train_processed` except `id`.
  data = train_processed, 
  method = "knn",
  trControl = num_folds, 
  tuneGrid = parameter_grid
)

knn

num_folds <- trainControl(method = "cv", number = 5)
parameter_grid <- expand.grid(.cp = seq(0, 0.01, 0.001)) # Explore values of `cp` between 0 and 0.01.

grid_search <- train(
  target ~ . - id, 
  data = train_processed, 
  method = "rpart", # CART algorithm
  trControl = num_folds
)

grid_search