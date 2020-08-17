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


porqué primero intentaremos averiguar la longitud del texto de los tweets agregando una nueva característica (TextLength).

```{r}
complete_df$TextLength <- nchar(complete_df$text)
summary(complete_df$TextLength)
```
Existe una gran variación en la longitud de los textos tweets. La longitud mínima es 5 y la longitud máxima es 169. Veamos si los tweets más cortos están hablando de un desastre real o no. Usando **complete_df[complete.cases(complete_df), ]** omitiremos los 3263 valores perdidos de la variable **target**.

```{r fig.align='center', out.width='70%'}
ggplot(complete_df[complete.cases(complete_df), ], aes(x = target, y = TextLength, fill = target)) +
  theme_bw() +
  geom_boxplot() +
  labs(y = "longitud del texto",
       title = "Distribución de longitudes text con target")
```