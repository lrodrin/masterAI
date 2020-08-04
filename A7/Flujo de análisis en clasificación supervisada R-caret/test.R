## Importing packages
library(tidyverse)
library(stringi)
library(tm)
library(irlba)
library(RColorBrewer)
library(wordcloud)
library(gridExtra)
library(caret)
library(doParallel)

# install.packages("caretEnsemble")
library(caretEnsemble)

## Reading in files
train <- read.csv("train.csv", stringsAsFactor = F, na.strings = c(""))
test <- read.csv("test.csv", stringsAsFactor = F, na.strings = c(""))

## Dimensions of data
dim(train)
dim(test)

# Top 6 rows for training data
head(train)

# Top 6 rows for testing data
head(test)

complete_df <- bind_rows(train, test)
glimpse(complete_df)

complete_df$target <- as.factor(ifelse(complete_df$target == 0, "No", "Yes"))

summary(complete_df)

head(unique(complete_df$keyword))
head(unique(complete_df$location))

# Dropping id variable
complete_df$id <- NULL

missing_count <- colSums(sapply(complete_df, is.na))
missing_count

complete_df$TextLength <- nchar(complete_df$text)
summary(complete_df$TextLength)

ggplot(complete_df, aes(x = target, y = TextLength, fill = target)) +
  theme_bw() +
  geom_boxplot() +
  labs(x = "Target Labels", y = "Length of Text",
       title = "Distribution of Text Lengths with Target Labels")

# Create document corpus with tweet text
myCorpus <- Corpus(VectorSource(complete_df$text))

# Take a look at a specific tweet and see how it transforms.
inspect(myCorpus[[400]])

# Removing Links
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)  
myCorpus <- tm_map(myCorpus, content_transformer(removeURL))
inspect(myCorpus[[400]])

# Convert to Lowercase
myCorpus <- tm_map(myCorpus, content_transformer(stri_trans_tolower))
inspect(myCorpus[[400]])

# Removing Usernames
removeUsername <- function(x) gsub("@[^[:space:]]*", "", x)  
myCorpus <- tm_map(myCorpus, content_transformer(removeUsername))
inspect(myCorpus[[400]])

removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*", "", x)   
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))
inspect(myCorpus[[400]])

myStopWords <- c((stopwords('english')), 
                 c("really", "tweets", "saw", "just", "feel", "may", "us", "rt", "every", "one",
                   "amp", "like", "will", "got", "new", "can", "still", "back", "top", "much",
                   "near", "im", "see", "via", "get", "now", "come", "oil", "let", "god", "want",
                   "pm", "last", "hope", "since", "everyone", "food", "content", "always", "th",
                   "full", "found", "dont", "look", "cant", "mh", "lol", "set", "old", "service",
                   "city", "home", "live", "night", "news", "say", "video", "people", "ill", 
                   "way",  "please", "years", "take", "homes", "read", "man", "next", "cross", 
                   "boy", "bad", "ass"))

myCorpus <- tm_map(myCorpus, removeWords, myStopWords) 
inspect(myCorpus[[400]])

removeSingle <- function(x) gsub(" . ", " ", x)   
myCorpus <- tm_map(myCorpus, content_transformer(removeSingle))
inspect(myCorpus[[400]])

myCorpus <- tm_map(myCorpus, stripWhitespace)
inspect(myCorpus[[400]])

# Term Document Matrix for training data
train_tdm <- TermDocumentMatrix(myCorpus[1:7613], control= list(wordLengths= c(1, Inf)))

# Term Document Matrix for test data
test_tdm <- TermDocumentMatrix(myCorpus[7614:10876], control= list(wordLengths= c(1, Inf)))

train_tdm
test_tdm

gc()

# Most frequent terms in training data
(freq.terms <- findFreqTerms(train_tdm, lowfreq = 60))
train.term.freq <- rowSums(as.matrix(train_tdm))
train.term.freq <- subset(train.term.freq, train.term.freq > 60)
freq_train_df <- data.frame(term = names(train.term.freq), freq= train.term.freq)

# Most frequent terms in test data
(freq.terms <- findFreqTerms(test_tdm, lowfreq = 60))
test.term.freq <- rowSums(as.matrix(test_tdm))
test.term.freq <- subset(test.term.freq, test.term.freq > 60)
freq_test_df <- data.frame(term = names(test.term.freq), freq= test.term.freq)

p1=ggplot(freq_train_df, aes(reorder(term, freq),freq)) + theme_bw() + geom_bar(stat = "identity")  + coord_flip() + 
  labs(list(title="frequent terms in train data", x="Terms", y="Term Counts")) + theme(axis.text.y = element_text(size=7))


p2=ggplot(freq_test_df, aes(reorder(term, freq),freq)) + theme_bw() + geom_bar(stat = "identity")  + coord_flip() + 
  labs(list(title="frequent terms in test data", x="Terms", y="Term Counts")) + theme(axis.text.y = element_text(size=7))

grid.arrange(p1,p2,ncol=2)

word.freq <- sort(rowSums(as.matrix((train_tdm))), decreasing= F)
pal <- brewer.pal(8, "Dark2")
wordcloud(words = names(word.freq), freq = word.freq, min.freq = 2, random.order = F, colors = pal, max.words = 150)


word.freq <- sort(rowSums(as.matrix(test_tdm)), decreasing= F)
pal <- brewer.pal(8, "Dark2")
wordcloud(words = names(word.freq), freq = word.freq, min.freq = 2, random.order = F, colors = pal, max.words = 150)

# Free-up space befor we move further
# rm(train, test, missing_count, train_tdm, test_tdm, freq_train_df, freq_test_df, 
   # freq.terms, train.term.freq, test.term.freq, p1, p2, word.freq)

complete.tdm <- TermDocumentMatrix(myCorpus, control= list(wordLengths= c(4, Inf)))

inspect(complete.tdm)

# Transpose our matrix to get our document term matrix
complete.term.matrix <- as.matrix(t(complete.tdm))
complete.term.matrix[1:10, 1:20]
dim(complete.term.matrix)

# Fixing incomplete cases
incomplete.cases <- which(!complete.cases(complete.term.matrix))
complete.term.matrix[incomplete.cases,] <- rep(0.0, ncol(complete.term.matrix))

complete_irlba <- irlba(t(complete.term.matrix), nv = 150, maxit = 600)
complete_irlba$v

# Setup a feature data frame with labels.
complete.svd <- data.frame(target = complete_df$target, textlength = complete_df$TextLength, 
                           complete_irlba$v)


# Separating train & test data frame
train.df <- complete.svd[1:7613, ]
test.df <- complete.svd[7614:10876, -1]

# Checking the dimensions
dim(train.df)
dim(test.df)

gc()

names(train.df) <- make.names(names(train.df))
names(test.df) <- make.names(names(test.df))