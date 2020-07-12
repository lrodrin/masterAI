library(mlbench)
library(lattice)
library(ggplot2)
library(caret)
library(factoextra)

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
BreastCancer.scale <- preProcess(BreastCancer[, 1:9], method=c("scale"))
BreastCancer.features <- predict(BreastCancer.scale, BreastCancer[, 1:9])
str(BreastCancer.features)


set.seed(101)
km_clusters <- kmeans(BreastCancer.features[, c("Cell.size", "Cell.shape")], centers = 2, nstart = 20)
km_clusters

require("cluster")
sil <- silhouette(km_clusters$cluster, dist(BreastCancer.features))
fviz_silhouette(sil)

library(corrplot)
corrplot(cor(BreastCancer.features), method = "number",type = "lower")

km_clusters <- kmeans(BreastCancer.features[, c(2, 3)], 2, nstart = 20)
km_clusters

tablaResultados <- table(km_clusters$cluster, BreastCancer$Class)

tablaResultados
# Podemos apreciar que el segundo cluster engloba a un mayor número de ejemplos malignos que benignos.
# También se puede apreciar que el primer cluster engloba a más ejemplso benignos que malignos.
# sin embargo, el cluster nº 1 también alberga ejemplos del tipo maligno. 
# Se puede concluir por tanto que los resultados son bastante mejorables, 

aggregate(BreastCancer, by = list(cluster = km_clusters$cluster), mean)

# plot
fviz_cluster(km_clusters, data = BreastCancer.features[, c("Cell.size", "Cell.shape")],
             ggtheme = theme_minimal(),
             main = "Partitioning Clustering Plot")

# ggplot(BreastCancer, aes(Cell.size, Cell.shape, color = Class)) + geom_point()
ggplot(BreastCancer, aes(Cell.size, Cell.shape, color = as.factor(km_clusters$cluster))) + geom_point()

table(BreastCancer$Class, clusters)

fviz_cluster(km_clusters, data = BreastCancer.features)
fviz_cluster(km_clusters, data = BreastCancer.features,
             palette = c("#00AFBB","#2E9FDF"),
             ggtheme = theme_minimal(),
             main = "Partitioning Clustering Plot")

fviz_nbclust(BreastCancer.features, km_clusters, method = "gap_stat")

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

table(BreastCancer$Class, km_clusters$cluster)


ggplot(BreastCancer, aes(Mitoses, Epith.c.size, color = Class)) + geom_point()