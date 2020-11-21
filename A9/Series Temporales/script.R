library(xts)
library(ggplot2)
library(forecast)
library(lubridate)
library(scales) 

data <- read.csv("Demanda_2015.csv", header = FALSE, sep = ",")
colnames(data) <- c("date", "time", "demand")
sum(is.na(data))

Sys.setlocale("LC_TIME", "English")
data <- cbind(datetime = paste(data$date, data$time), data)
data$datetime <- parse_date_time(data$datetime, "dmY HMS", truncated = 3, tz = "UTC")

data$date <- NULL
data$time <- NULL

# data$month <- as.factor(strftime(data$datetime, format = "%B", tz = "UTC"))
# data$yearday <- as.factor(strftime(data$datetime, format = "%m%d", tz = "UTC"))

ggplot(data = data, aes(x = datetime, y = demand)) +
  geom_line() + 
  scale_x_datetime(date_labels = "%b", breaks = "1 month", 
                   expand = c(0, 0)) +
  ggtitle("Consumo eléctrico, 2015") +
  xlab("Mes") +
  ylab("Demanda en MW")

ggplot(data = data, aes(x = datetime, y = demand)) +
  geom_line() + 
  geom_smooth(method = "loess", se = FALSE, span = 0.6) +
  scale_x_datetime(date_labels = "%b", breaks = "1 month", 
                   expand = c(0, 0)) +
  ggtitle("Consumo eléctrico, 2015") +
  xlab("Mes") +
  ylab("Demanda en MW")

data$month <- format(data$datetime, format = "%B")
ggplot(data, aes(x = datetime, y = demand)) +
  geom_line(aes(colour = month)) +
  geom_smooth(method = "loess", se = FALSE, span = 0.6) +
  scale_x_datetime(date_labels = "%b", breaks = "1 month", 
                   expand = c(0, 0)) +
  ggtitle("Consumo eléctrico, 2015") +
  xlab("Mes") +
  ylab("Demanda en MW") +
  theme(legend.position = "none")

data$month <- NULL

# time serie
ts <- ts(data$demand, frequency = 24*60/10)
acf(ts)
pacf(ts)
mstl(ts, lambda = "auto") %>% autoplot()

train <- data[data$datetime <= as.POSIXct("2015-08-31 23:50:00",
                                          tz = "UTC"), ]
test <- data[data$datetime >= as.POSIXct("2015-08-31 23:59:00",
                                         tz = "UCT"), ]
sum(is.na(data))
sum(complete.cases(data))
sum(complete.cases(train)) + sum(complete.cases(test))

prevision_demanda_ts <- data %>% filter(as.Date(data$datetime) >= "2015-01-01 00:00:00	",
                                as.Date(data$datetime) <= "2015-12-31 23:50:00") %>%
  select(demand) %>%
  msts(c(24, 168))
Acf(prevision_demanda_ts)

demanda_ts <- msts(data$demand, seasonal.periods = c(24, 169, 24*365.25),
                   start = decimal_date(as.POSIXct("2015-01-01 00:00:00")))

Acf(demanda_ts)

library(tsoutliers) #Cargamos la librería
outliers <- tso(demanda_ts) 
plot(outliers)

ggplot(data, aes(month, demand)) + 
  geom_boxplot() + 
  xlab("Month") + 
  ylab("Demand (MWh)") + 
  ggtitle("Demand per month")