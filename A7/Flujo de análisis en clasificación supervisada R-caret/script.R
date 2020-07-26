library(tidyverse)
library(tm)

train <- read.csv("train.csv", na.strings=c("","NA"))
test <- read.csv("test.csv", na.strings=c("","NA"))

train$target <- as.factor(train$target)

# distribution of the target variable

ggplot(train, aes(x=target)) + 
  geom_bar(aes(fill=target))

sum(train$target == "0") / dim(train)[1] * 100 # 57%
sum(train$target == "1") / dim(train)[1] * 100 # 43%

# missing values
colSums(sapply(train, is.na))
colSums(sapply(test, is.na))

# correlations

cor(as.numeric(train$keyword), as.numeric(train$location))

# delete id variable
train$id <- NULL
test$id <- NULL

## keyword
length(unique(train$keyword))
length(unique(test$keyword))
# These are the same 222 unique values that are present in train. This makes it convenient to deal with this variable.
# Cnvert keyword to a categorical variable.
train$keyword <- as.factor(train$keyword)
test$keyword <- as.factor(test$keyword)
# Let’s verify that the factor levels of keyword in train and test match.
all.equal(levels(train$keyword), levels(test$keyword))

## location
length(unique(train$location))
length(unique(test$location))
# We notice that the unique values of location in train and test aren’t the same. Hence, we cannot simply convert 
# location to a categorical variable.
# Convert location to a bag of words.

# Let’s bind the rows of train and test (except the target variable) into a single data frame.
train_and_test <- rbind(train[, 1:3], test)
str(train_and_test)

# 1. Create a corpus
corpus_location <- Corpus(VectorSource(train_and_test$location))
corpus_location[[33]]$content

# 2. Convert to lowercase
corpus_location <- tm_map(corpus_location, tolower)
corpus_location[[33]]$content

# 3. Remove punctuation
corpus_location <- tm_map(corpus_location, removePunctuation)
corpus_location[[33]]$content

# 4. Remove stopwords
corpus_location <- tm_map(corpus_location, removeWords, stopwords("english"))
corpus_location[[33]]$content
 
# 5. Stemming (using Porter’s stemming algorithm)
corpus_location <- tm_map(corpus_location, stemDocument)
corpus_location[[33]]$content

## text
length(unique(train$text))
length(unique(test$text))
# We notice that the unique values of text in train and test aren’t the same. Hence, we cannot simply convert 
# text to a categorical variable.
# Convert text to a bag of words.