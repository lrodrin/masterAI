library(ggplot2)
library(forcats)

df1 <- data.frame(x = rep(c("[1,2]", "[3, 4]", "[5]", "[6]", "[7, 8]", "[9, 10]"), 
                          c(10, 9, 9, 10, 9, 13)))

ggplot(df1, aes(fct_inorder(x))) + 
  geom_bar() +
  ggtitle("Histograma de 6 intervalos o bloques de igual frecuencia") +
  xlab("Clase") +
  ylab("Frecuencia") +
  ylim(c(0, 15))

df2 <- data.frame(x = rep(c("[1, 2, 3]", "[4, 5]", "[6, 7]", "[8, 9, 10]"), 
                          c(14, 14, 18, 15)))

ggplot(df2, aes(fct_inorder(x))) + 
  geom_bar() + 
  ggtitle("Histograma de 4 intervalos o bloques de igual frecuencia") +
  xlab("Clase") +
  ylab("Frecuencia") +
  ylim(c(0, 20))



df3 <- data.frame(x = rep(c("[1]", "[2, 3, 4]", "[5, 6, 7]", "[8]", "[9]", "[10]"), 
                          c(7, 4, 8, 1, 9, 4)))

ggplot(df3, aes(fct_inorder(x))) + 
  geom_bar() +
  ggtitle("Histograma de 6 intervalos o bloques minimizando la varianza") +
  xlab("Clase") +
  ylab("Frecuencia") +
  ylim(c(0, 15)) 