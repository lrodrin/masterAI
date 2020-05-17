library(tidyverse)
library(gridExtra)
library(lubridate)
library(stringr)
library(ggplot2)
library(dplyr)

data <- read_csv("data.csv")
data

# eliminiación de columnas redundantes
# shot_id denota el identificador de cada instancia por lo que puede borrarse (25)
# team_id y team_name mismo valor en todas las filas (20, 21)
# opponent y matchup dan la misma información y solo necesitamos el oponente (23) eliminamos matchup
data <- data[, -c(20, 21, 23, 25)]
data
summary(data)
head(data)
tail(data)

# Hay algunos NA en la columna shot_made_flag. Eliminanoms todas las filas con valores NA
any(is.na(data))
data <- na.omit(data)
any(is.na(data))

# Shot type As we see, most points in the visualization correspond to jump shots.
ggplot() + 
  
  # We use a different alpha value for jump shots to improve the visualization
  geom_point(data=data %>% filter(combined_shot_type=="Jump Shot"),
             aes(x=lon, y=lat), colour="grey", alpha=0.3) +
  geom_point(data=data %>% filter(combined_shot_type!="Jump Shot"),
             aes(x=lon, y=lat, colour=combined_shot_type), alpha=0.8) +
  labs(title="Shot type") +
  ylim(c(33.7, 34.0883)) +
  theme_void() +
  theme(legend.title=element_blank(),
        plot.title=element_text(hjust=0.5)) 


# accuracy by season As we see, the accuracy begins to decrease badly from the 2013-14 season. 
# Why didn’t you retire before, Kobe?
data %>%
  group_by(season) %>%
  summarise(Accuracy=mean(shot_made_flag)) %>%
  ggplot(aes(x=season, y=Accuracy, group=1)) +
  geom_line(aes(colour=Accuracy)) +
  geom_point(aes(colour=Accuracy), size=3) +
  scale_colour_gradient(low="orangered", high="chartreuse3") +
  labs(title="Accuracy by season", x="Season") +
  theme(legend.position="none",
        plot.title=element_text(hjust=0.5),
        axis.text.x=element_text(angle=45, hjust=1)) 


# accuracy by opponent

data %>%
  group_by(opponent) %>%
  summarise(Accuracy=mean(shot_made_flag)) %>%
  mutate(Conference=c("Eastern", "Eastern", "Eastern", "Eastern", "Eastern",
                      "Eastern", "Western", "Western", "Eastern", "Western",
                      "Western", "Eastern", "Western", "Western", "Eastern",
                      "Eastern", "Western", "Eastern", "Western", "Western",
                      "Eastern", "Western", "Eastern", "Eastern", "Western",
                      "Western", "Western", "Western", "Western", "Eastern",
                      "Western", "Western", "Eastern" )) %>%
  ggplot(aes(x=reorder(opponent, -Accuracy), y=Accuracy)) + 
  geom_bar(aes(fill=Conference), stat="identity") +
  labs(title="Accuracy by opponent", x="Opponent") +
  theme(plot.title=element_text(hjust=0.5),
        axis.text.x=element_text(angle=45, hjust=1)) 

# combinar minutes_remaining y seconds_remaining en una misma columna
data <- unite(data, time_remaining, c(9, 13),  sep = ":", remove = TRUE)
# convertimos a segundos la columna time_remaining
data$time_remaining <- ms(data$time_remaining)
data$time_remaining <- as.integer(data$time_remaining)
head(data)

# action_type, combined_shot_type, shot_type representan cómo el jugador disparó una pelota.

# parece estar compuesto de dos partes: año de temporada e ID de temporada. 
# Aquí solo necesitamos una identificación de temporada. Modifiquemos los datos.
data$season <- str_split_fixed(data$season, "-", 2)[, 2]
data$season <- as.integer(data$season)
data$season <- as.factor(data$season)

# cast
data$action_type <- as.factor(data$action_type)
# data$action_type <- as.numeric(data$action_type)
data$combined_shot_type <- as.factor(data$combined_shot_type)
# data$combined_shot_type <- as.numeric(data$combined_shot_type)
data$game_event_id <- as.integer(data$game_event_id)
data$game_id <- as.integer(data$game_id)
data$loc_x <- as.integer(data$loc_x)
data$loc_y <- as.integer(data$loc_y)
data$period <- as.integer(data$period)
data$shot_distance <- as.integer(data$shot_distance)
data$shot_made_flag <- as.integer(data$shot_made_flag)
data$shot_type <- as.factor(data$shot_type)
# data$shot_type <- as.numeric(data$shot_type)
data$shot_zone_area <- as.factor(data$shot_zone_area)
# data$shot_zone_area <- as.numeric(data$shot_zone_area)
data$shot_zone_basic <- as.factor(data$shot_zone_basic)
# data$shot_zone_basic <- as.numeric(data$shot_zone_basic)
data$shot_zone_range <- as.factor(data$shot_zone_range)
# data$shot_zone_range <- as.numeric(data$shot_zone_range)
data$game_date <- as.factor(data$game_date)
# data$game_date <- as.numeric(data$game_date)
data$opponent <- as.factor(data$opponent)
# data$opponent <- as.numeric(data$opponent)

train<-subset(data, !is.na(data$shot_made_flag))
library(MASS)
dfl <- lda(shot_made_flag ~ ., train)