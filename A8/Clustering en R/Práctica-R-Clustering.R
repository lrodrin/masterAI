library(mlbench)
library(lattice)
library(ggplot2)
library(caret)


data(BreastCancer)
str(BreastCancer)

any(is.na(BreastCancer))
sum(is.na(BreastCancer))
BreastCancer <- na.omit(BreastCancer) 
any(is.na(BreastCancer))

for (i in 1:(ncol(BreastCancer) - 1))
  BreastCancer[, i] <- as.numeric(as.character(BreastCancer[, i]))

BreastCancer$Id <- NULL


# scale
preProcess(BreastCancer, method = "scale")

# center scale
preProcess(BreastCancer, method = c("center", "scale"))

# center scale YeoJohnson
preProcess(BreastCancer, method = c("center", "scale", "YeoJohnson"))

#range
preProcess(BreastCancer, method = "range")

# range YeoJohnson
preProcess(BreastCancer, method = c("range", "YeoJohnson"))

BreastCancer.features = BreastCancer[, 1:9]
str(BreastCancer.features)

set.seed(101)
km_clusters <- kmeans(BreastCancer.features[c("Cell.size", "Cell.shape")], centers = 2, nstart = 20)
km_clusters

clusters <- km_clusters$cluster

ggplot(BreastCancer, aes(Cell.size, Cell.shape, color = Class)) + geom_point()
ggplot(BreastCancer, aes(Cell.size, Cell.shape, color = as.factor(clusters))) + geom_point()

table(BreastCancer$Class, clusters)

library(factoextra)
fviz_cluster(km_clusters, data = BreastCancer.features,
             palette = c("#00AFBB","#2E9FDF"),
             ggtheme = theme_minimal(),
             main = "Partitioning Clustering Plot")

fviz_nbclust(x = BreastCancer.features, FUNcluster = kmeans, method = "wss", k.max = 10, 
             diss = get_dist(BreastCancer.features, method = "euclidean"), nstart = 20)

# A partir de 2 clusters la reducción en la suma total de cuadrados internos parece estabilizarse, indicando que K = 2 es una buena opción.

cor(BreastCancer.features, method = "pearson")

func <- function (var) { 
  new_data <- c("Cell.size", "Cell.size", var)
  set.seed(101)
  km_clusters <- kmeans(BreastCancer.features[new_data], centers = 2, nstart = 20)
  km_clusters
}
vars <- c("Cl.thickness", "Marg.adhesion", "Epith.c.size", "Bare.nuclei", "Bl.cromatin")
func(vars[1])
func(vars[2])
func(vars[3])
func(vars[4])
func(vars[5])

library(ggdendro)
dendrogram <- hclust(dist(BreastCancer.features, method = 'euclidean'), method = 'ward.D')
ggdendrogram(dendrogram, rotate = FALSE, labels = FALSE, theme_dendro = TRUE) + 
  labs(title = "Dendrograma")

agrupamientoJ <- hclust(dist(BreastCancer.features, method = 'euclidean'), method = 'ward.D')
clases_aj <- cutree(agrupamientoJ, k = 2)
BreastCancer.features$cluster <- clases_aj
clusters <- BreastCancer.features$cluster

ggplot(BreastCancer, aes(Cell.size, Cell.shape, color = Class)) + geom_point()
ggplot(BreastCancer, aes(Cell.size, Cell.shape, color = as.factor(clusters))) + geom_point()

table(BreastCancer$Class, clusters)
