

data <- read.csv("Demanda_2015.csv", header = FALSE, sep = ",")

colnames(data) <- c("date", "time", "demand")

data$date <- as.Date(data$date, format = "%d/%m/%Y")

data["datetime"] <- paste(data$date, data$time)
data$datetime <- as.POSIXct(data$datetime, tz = "", "%Y-%m-%d %H:%M")

data$date <- NULL
data$time <- NULL

data <- data[data$datetime >= '2015-01-01 00:00:00' & data$datetime <= '2015-12-31 23:50:00', ]

library(ggplot2)

ggplot(data = data, aes(x = datetime, y = demand)) +
  geom_line(color = "#00AFBB", size = 0.5) + 
  ggtitle('Consumo eléctrico, enero-diciembre 2015') +
  ylab('Consumption in MW')