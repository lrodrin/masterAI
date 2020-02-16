library(ggplot2)
queratocono <- read.csv("Queratocono.csv", header=TRUE, sep=",")
any(is.na(queratocono))
queratocono <- queratocono[order(queratocono$na), ]
plot(queratocono)

# 1
qplot(K1, K2, data = queratocono) +
  geom_point() + 
  geom_smooth(method = "loess") +
  xlab("K1") + ylab("K2")
  
qplot(K1, K2, data = queratocono) +
  geom_point() +
  geom_smooth(method = lm) +
  xlab("K1") + ylab("K2")

# 2
qplot(K1, K2, data = queratocono, colour = factor(na)) +
  geom_point() +
  geom_smooth(method = lm) +
  xlab("K1") + ylab("K2") +
  ggtitle("Relation between K1 and K2") +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

# 3
qplot(K1, K1.salida, data = queratocono) +
  geom_point() + 
  xlab("K1") + ylab("K1.salida")

# 4
qplot(factor(grosor), data = queratocono, geom = "bar", fill = factor(na, levels = c(2, 1))) +
  guides(fill = guide_legend(reverse = TRUE)) +
  scale_fill_manual(values = c("#00BFC4", "#F8766D")) +
  labs(fill = "factor(na)") +
  ylab("count")

# 5
qplot(K1, K2, data = queratocono, colour = factor(grosor), facets = diam ~ na, 
      size = I(1/3)) +
      geom_point() + 
      scale_shape_manual(values = 0:7) +
      xlab("K1") + ylab("K2")

# 6
qplot(factor(grosor), K1, data = queratocono, geom = "boxplot") +
  xlab("factor(grosor)") + ylab("K1")

qplot(factor(grosor), K2, data = queratocono, geom = "boxplot") +
  xlab("factor(grosor)") + ylab("K2")