x <- list()
x[[1]] <- c(1, 0, 1)
x[[2]] <- c(1, 1, 0)
x[[3]] <- c(0, 1, 1)
x[[4]] <- c(0, 1, 1)

# (1,0,1) (1,1,0) (0,1,1) (0,1,1)

y <- list()
y[[1]] <- c(1, 1, 0)
y[[2]] <- c(1, 1, 0)
y[[3]] <- c(1, 1, 1)
y[[4]] <- c(0, 1, 0)

# (1,1,0) (1,1,0) (1,1,1) (0,1,0)

truth = do.call(rbind, x)
response = do.call(rbind, y)
MultilabelSubset01(truth, response)
