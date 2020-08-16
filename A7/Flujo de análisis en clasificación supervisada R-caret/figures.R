library(syuzhet)
library(ggcorrplot)

cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

emocion.df <- get_nrc_sentiment(char_v = gsub("_", " ", train$keyword), language = "english", cl=cl)
emocion.df <- emocion.df %>% data.frame(target = train$target)
emocion.df$target <- as.numeric(emocion.df$target)

cor(emocion.df) %>% 
  ggcorrplot(lab = TRUE, 
             title = "Correlation matrix between keyword sentiments and target",
             legend.title = "correlation")

stopCluster(cl)


location.freq <- table(unlist(train %>% select(location)))
location.freq[which(location.freq>10)]
barplot(location.freq[which(location.freq>10)], las = 2,  
        main = "Frequency of Location")


train %>% select(text) %>% unique() %>% head(10)
count(train %>% select(text) %>% unique())

text.freq <- table(unlist(train %>% select(text)))
text.freq[which(text.freq > 10)]
barplot(text.freq[which(text.freq>10)], las = 2,  
        ylab = "Frequency")
