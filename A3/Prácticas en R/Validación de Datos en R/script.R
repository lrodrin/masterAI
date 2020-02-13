library(ggplot2)
queratocono <- read.csv("Queratocono.csv", header=TRUE, sep=",")
any(is.na(queratocono))
head(queratocono)

# 1
qplot(queratocono$K1, queratocono$K2, data = queratocono, xlab = "K1", ylab = "K2") +
  geom_point() + 
  geom_smooth()
  
qplot(queratocono$K1, queratocono$K2, data = queratocono, xlab = "K1", ylab = "K2") +
  geom_point() +
  geom_smooth(method = lm)

# 2
qplot(queratocono$K1, queratocono$K2, data = queratocono, xlab = "K1", ylab = "K2", color=factor(na)) +
  geom_point() +
  geom_smooth(method = lm)

# 3

# 4

