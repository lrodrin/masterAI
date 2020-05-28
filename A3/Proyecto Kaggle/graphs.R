library(tidyverse)
library(ggplot2)

##load data
tmp_data <- read_csv("data.csv")

##remove NA
tmp_data <- na.omit(tmp_data)
any(is.na(data))

##shot_type
ggplot() + 
  geom_point(data=data %>% filter(combined_shot_type=="Jump Shot"),
             aes(x=lon, y=lat), colour="grey", alpha=0.3) +
  geom_point(data=data %>% filter(combined_shot_type!="Jump Shot"),
             aes(x=lon, y=lat, colour=combined_shot_type), alpha=0.8) +
  labs(title="Shot type") +
  ylim(c(33.7, 34.0883)) +
  theme_void() +
  theme(legend.title=element_blank(),
        plot.title=element_text(hjust=0.5)) 

##accuracy by season
tmp_data %>%
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

##accuracy by opponent
tmp_data %>%
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

# Accuracy by shot distance
tmp_data %>%
  group_by(shot_distance) %>%
  summarise(Accuracy=mean(shot_made_flag)) %>%
  ggplot(aes(x=shot_distance, y=Accuracy)) + 
  geom_line(aes(colour=Accuracy)) +
  geom_point(aes(colour=Accuracy), size=2) +
  scale_colour_gradient(low="orangered", high="chartreuse3") +
  labs(title="Accuracy by shot distance", x="Shot distance (ft.)") +
  xlim(c(0,45)) +
  theme_bw() +
  theme(legend.position="none",
        plot.title=element_text(hjust=0.5)) 

# Target class distribution
qplot(factor(shot_made_flag), data = tmp_data, geom = "bar",
      fill = factor(shot_made_flag, levels = c(0, 1))) +
  scale_fill_manual(values = c("darkblue", "darkgreen")) +
  labs(fill = "levels") + xlab("shot_made_flag") +
  ylab("count") + ggtitle("Distribución de la clase") +
  theme_bw() + theme(plot.title = element_text(hjust = 0.5))

# Outliers shot distance
qplot(factor(shot_made_flag), shot_distance,  data = data, geom = "boxplot") +
  xlab("shot_made_flag") + ylab("shot_distance")

# Shot zone range
p1 <- ggplot(tmp_data, aes(x=lon, y=lat)) +
  geom_point(aes(color=shot_zone_range)) +
  labs(title="Shot zone range") +
  ylim(c(33.7, 34.0883)) +
  theme_void() +
  theme(legend.position="none",
        plot.title=element_text(hjust=0.5)) 

# Frequency for each shot zone range
p2 <- ggplot(tmp_data, aes(x=fct_infreq(shot_zone_range))) + 
  geom_bar(aes(fill=shot_zone_range)) +
  labs(y="Frequency") +
  theme_bw() +
  theme(axis.title.x=element_blank(), 
        legend.position="none")

# Subplot
library("gridExtra")
grid.arrange(p1, p2, layout_matrix=cbind(c(1,2)))










