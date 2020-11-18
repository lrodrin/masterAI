library(xts)
library(ggplot2)
library(forecast)
library(lubridate)

data <- read.csv("Demanda_2015.csv", header = FALSE, sep = ",")
sum(is.na(data))
colnames(data) <- c("date", "time", "demand")
data$date <- as.Date(data$date, format = "%d/%m/%Y")
data <- cbind(datetime = paste(data$date, data$time), data)

data$datetime <- strptime(data$datetime, format = "%Y-%m-%d %H:%M")
data$datetime <- as.Date(data$datetime, format = "%Y-%m-%d %H:%M")
data$date <- NULL
data$time <- NULL

train <- subset(data, datetime <= strptime("2015-08-31 23:50:00", format = "%Y-%m-%d %H:%M"))
test <- subset(data, datetime >= strptime("2015-09-01 00:00:00", format = "%Y-%m-%d %H:%M"))

train <- data[data$datetime <= "2015-08-31 23:50:00", ]
test <- data[data$datetime >= "2015-09-01 00:00:00", ]

sum(complete.cases(data))
sum(complete.cases(train)) + sum(complete.cases(test))

ts <- ts(train$demand, frequency = 12, start = decimal_date(as.POSIXct("2015-01-01 00:00:00")))
ts

demandts <- xts(train$demand, train$datetime)
plot(demandts, main = 'Energy demand evolution', xlab = 'Date', ylab = 'Demand (GWh)')

ggplot(data = train, aes(x = datetime, y = demand)) +
  geom_line(color = "#00AFBB", size = 0.5) + 
  ggtitle("Consumo eléctrico, 2015") +
  xlab("Mes") +
  ylab("Consumo en MW")