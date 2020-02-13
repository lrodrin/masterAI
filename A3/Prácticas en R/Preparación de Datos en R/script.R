# Exercise 1
titanic <- read.csv("titanic.csv", header=TRUE, sep=",")
head(titanic, 1)
titanic <- subset(titanic, select=-X)
titanic
head(titanic)
summary(titanic)
plot(titanic)

# Exercise 2
cars <- read.csv("cars.csv", header=TRUE, sep=",")
cars <- subset(cars, select=-X)
cars
plot(cars$dist, cars$speed, main="CARS", col.main = "blue", xlab="Distance", ylab="Speed")
hist(cars$dist, main="Histogram of CARS distance", col.main = "blue", xlab="Distance", col="red")
hist(cars$speed, main="Histogram of CARS speed", col.main = "blue", xlab="Speed", col="red")

# Exercise 3
new_cars <- data.frame(speed=c(21, 34), dist=c(47, 87))
tail(cars)
cars <- rbind(cars, new_cars)
tail(cars)
cars <- cars[order(cars$speed), ]
cars

# Exercise 4
airquality <- read.csv("airquality.csv",header=TRUE, sep=",")
head(airquality, 2)
nrow(airquality)
airquality[40,1]
airquality_tmp <- airquality[complete.cases(airquality$Ozone), ]
mean(airquality_tmp$Ozone)
solarSubset <- subset(airquality_tmp , airquality_tmp$Ozone > 31 | airquality_tmp$Temp > 90)
solarSubset_tmp <- solarSubset[complete.cases(solarSubset$Solar.R), ]
mean(solarSubset_tmp$Solar.R)

# Exercise 5

# Exercise 6

# Exercise 7
cor(airquality)
cor(cars)



