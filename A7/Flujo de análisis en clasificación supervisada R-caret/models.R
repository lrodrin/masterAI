library(caret)
library(doParallel)

partitions <- 5
reteats <- 3

set.seed(123)
cv.folds <- createMultiFolds(train.df$target, k=5, times=3)
cv.cntrl <- trainControl(method = "repeatecv", number = 5, repeats = 3,
                         index = cv.folds, allowParallel = TRUE, returnResamp="final",
                         verboseIter=FALSE)
gc()

# GLMNET
cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

set.seed(123)
model_glmnet <- train(target ~ ., data=train.df,
                      method="glmnet",
                      metric="Accuracy",
                      trControl=cv.cntrl,
                      tuneLenght=15)
model_glmnet
stopCluster(cl)

# RF
cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

set.seed(123)
cv.grid <- expand.grid(mtry=c(3, 4, 5, 7))
model_rf <- train(target ~ ., data=train.df,
                      method="rf",
                      metric="Accuracy",
                      trControl=cv.cntrl,
                      tuneGrid=cv.grid)
model_rf
stopCluster(cl)

# GBM
library(gbm)

cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

cv.grid <- expand.grid(interaction.depth=c(1, 2),
                       n.trees=100,
                       shrinkage=c(0.001, 0.01, 0.1),
                       n.minobsinnode=c(2, 5, 25))

model_gbm <- train(target ~ ., data=train.df,
                  method="gbm",
                  metric="Accuracy",
                  trControl=cv.cntrl,
                  tuneGrid=cv.grid,
                  distribution="adaboost",
                  verbose=FALSE)
model_gbm
stopCluster(cl)

# KNN
cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

cv.grid <- expand.grid(k=1:3)

model_knn <- train(target ~ ., data=train.df,
                   method="knn",
                   metric="Accuracy",
                   trControl=cv.cntrl,
                   tuneGrid=cv.grid)
model_knn
stopCluster(cl)

# NB
cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

model_nb <- train(target ~ ., data=train.df,
                      method="nb",
                      metric="Accuracy",
                      trControl=cv.cntrl,
                      tuneLenght=15)
model_nb
stopCluster(cl)

# SVM
cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

cv.grid <- expand.grid(sigma=c(0.001, 0.01, 0.1, 0.5, 1),
                       C=c(1, 20, 50, 100))

model_svm <- train(target ~ ., data=train.df,
                      method="svmRadial",
                      metric="Accuracy",
                      trControl=cv.cntrl,
                      tuneLenght=15)
model_svm
stopCluster(cl)

#

models <- list(KNN=model_knn, NB=model_nb, logistic=model_glmnet,
               RF=model_rf, boosting=model_gbm, SVMRadial=model_svm)

resamps <- resamples(models)
summary(resamps)

# predict on test with SVMRadial
pred_svm <- predict(model_svm, test.df, type="raw")

# submission
submission <- read.csv("sample_submission.csv")
submission$target <- ifelse(pred_svm=="No", 0, 1)
head(submission)
write.csv(submission, "submission.csv", row.names=FALSE)
