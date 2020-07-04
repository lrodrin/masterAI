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

preProcess(BreastCancer, method = "scale")

set.seed(101)
data <- BreastCancer[, c("Cl.thickness", "Cell.size",
                         "Cell.shape", "Marg.adhesion",
                         "Epith.c.size", "Bare.nuclei",
                         "Bl.cromatin", "Normal.nucleoli",
                         "Mitoses")]
km_clusters <- kmeans(x = data, centers = 2, nstart = 20)


fviz_cluster(km_clusters, data = data,
             palette = c("#00AFBB","#2E9FDF"),
             ggtheme = theme_minimal(),
             main = "Partitioning Clustering Plot")


fviz_nbclust(x = data, FUNcluster = kmeans, method = "wss", k.max = 15, 
             diss = get_dist(data, method = "euclidean"), nstart = 20)