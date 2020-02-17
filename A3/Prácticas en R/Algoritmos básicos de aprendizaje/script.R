library(lattice)
library(ggplot2)
library(caret)
glass <- read.table("glass.data", header = FALSE, sep = ",")
head(glass, 10)

# Add column names
names(glass) <- c("Id number", "RI", "Na", "Mg", "Al", "Si", "K", "Ca", "Ba", "Fe",
                 "Type of glass")

# Make valid column names 
colnames(glass) <- make.names(colnames(glass))

# Check for NA values
any(is.na(glass))

# 
set.seed(123)
inTraining <- createDataPartition(glass$Type.of.glass, p = .7, list = FALSE)
training <- glass[ inTraining,]
testing  <- glass[-inTraining,]

# Specifiy the type of resampling
fitControl <- trainControl(method = "repeatedcv", 
                           number = 5, 
                           repeats = 1,
                           classProbs = TRUE)

# OneR
# kNN con k=1, k=3 y con peso por distancia (tres configuraciones en total)
# Multilayer Perceptrón con una sola capa oculta y 3, 5 y 7 unidades ocultas en la misma (tres configuraciones en total)

