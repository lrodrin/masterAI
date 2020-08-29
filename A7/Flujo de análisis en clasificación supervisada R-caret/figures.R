library(syuzhet)
library(ggcorrplot)

cl <- makePSOCKcluster(4, setup_strategy="sequential")
registerDoParallel(cl)

emocion.df <- get_nrc_sentiment(char_v = gsub("_", " ", train$keyword), language = "english", cl=cl)
emocion.df <- emocion.df %>% data.frame(target = train$target)
emocion.df$target <- as.numeric(emocion.df$target)

cor(emocion.df) %>% 
  ggcorrplot(lab = TRUE, 
             title = "Matriz de correlación entre los \nsentimientos de keyword y target",
             legend.title = "correlation")

stopCluster(cl)


location.freq <- table(unlist(train %>% select(location)))
location.freq[which(location.freq>10)]
barplot(location.freq[which(location.freq>10)], las = 2,  
        main = "Frequency of Location")

ggplot(complete_df[complete.cases(complete_df), ], aes(x = target, y = TextLength, fill = target)) +
  theme_bw() +
  geom_boxplot() +
  labs(y = "longitud del texto",
       title = "Distribución de longitudes text con target")

ggplot(freq_train_df, aes(reorder(term, freq), freq)) + theme_bw() + 
  geom_bar(stat = "identity")  + 
  coord_flip() + 
  theme(axis.text.y = element_text(size=7))