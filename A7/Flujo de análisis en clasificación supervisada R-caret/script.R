library(caret)
library(mlbench)
library(tidyverse)
library(tm)
library(SnowballC)

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

# 6. Create document term matrix
dtm_location <- DocumentTermMatrix(corpus_location)
dtm_location

# 7. Reduce sparsity
dtm_location <- removeSparseTerms(dtm_location, 0.9975)
dtm_location

# 8. Convert to data frame
bag_of_words_location <- as.data.frame(as.matrix(dtm_location))
colnames(bag_of_words_location) <- paste0(colnames(bag_of_words_location), "_location")
str(bag_of_words_location, list.len=10)

## text
length(unique(train$text))
length(unique(test$text))
# We notice that the unique values of text in train and test aren’t the same. Hence, we cannot simply convert 
# text to a categorical variable.
# Convert text to a bag of words.

# 1. Create a corpus
corpus_text <- Corpus(VectorSource(train_and_test$text))
corpus_text[[33]]$content

# Removing Links
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)  
corpus_text <- tm_map(corpus_text, content_transformer(removeURL))

# Removing Usernames
removeUsername <- function(x) gsub("@[^[:space:]]*", "", x)  
corpus_text <- tm_map(corpus_text, content_transformer(removeUsername))

# 2. Convert to lowercase
corpus_text <- tm_map(corpus_text, tolower)
corpus_text[[33]]$content

# 3. Remove punctuation
corpus_text <- tm_map(corpus_text, removePunctuation)
corpus_text[[33]]$content

# 4. Remove stopwords
corpus_text <- tm_map(corpus_text, removeWords, stopwords("english"))
corpus_text[[33]]$content

# 5. Stemming (using Porter’s stemming algorithm)
corpus_text <- tm_map(corpus_text, stemDocument)
corpus_text[[33]]$content

# 6. Create document term matrix
dtm_text <- DocumentTermMatrix(corpus_text)
dtm_text

# 7. Reduce sparsity
dtm_text <- removeSparseTerms(dtm_text, 0.9975)
dtm_text

# 8. Convert to data frame
bag_of_words_text <- as.data.frame(as.matrix(dtm_text))
colnames(bag_of_words_text) <- paste0(colnames(bag_of_words_text), "_text")
str(bag_of_words_text, list.len=10)

## Putting Together
bag_of_words <- cbind(bag_of_words_location, bag_of_words_text)

train_processed <- bag_of_words[1:7613, ] # Rows 1 to 7613 were obtained from `train`.
test_processed <- bag_of_words[7614:10876, ] # Rows 7614 to 10876 were obtained from `test`.

train_processed$id <- train$id
train_processed$keyword <- train$keyword
train_processed$target <- train$target

test_processed$id <- test$id
test_processed$keyword <- test$keyword