# This R environment comes with all of CRAN preinstalled, as well as many other helpful packages
# The environment is defined by the kaggle/rstats docker image: https://github.com/kaggle/docker-rstats
# For example, here's several helpful packages to load in 

library(ggplot2) # Data visualization
library(readr) # CSV file I/O, e.g. the read_csv function

# Input data files are available in the "../input/" directory.
# For example, running this (by clicking run or pressing Shift+Enter) will list the files in the input directory

system("ls ../input")

# Any results you write to the current directory are saved as output.
library(dplyr)
library(rpart)
data_kb<-read.csv("data.csv",head=T,sep=",")
data_kb$shot_made_flag2<-factor(data_kb$shot_made_flag)
data_kb$playoffs2<-factor(data_kb$playoffs)
data_kb$shot<-1
#data_kb$team_id<-NULL
#data_kb$team_name<-NULL

#Decomposing game_date int Year, Month and day
data_kb$Data_list<-strsplit(as.character(data_kb$game_date),split = "-")
n<-length(data_kb$action_type)
data_kb$Year<-0
data_kb$Month<-0
data_kb$Day<-0
for(i in 1:n) {
  data_kb$Year[i] <- as.numeric(data_kb$Data_list[[i]][1])
  data_kb$Month[i] <- as.numeric(data_kb$Data_list[[i]][2])
  data_kb$Day[i] <- as.numeric(data_kb$Data_list[[i]][3])
}
data_kb$Data_list<-NULL
data_kb$game_date<-NULL
data_kb$time_remaining<-data_kb$minutes_remaining*60+data_kb$seconds_remaining

#Splitting data into train and test
train_kb<-data_kb[!is.na(data_kb$shot_made_flag),]
test_kb<-data_kb[is.na(data_kb$shot_made_flag),]

fit<-glm(shot_made_flag2~time_remaining+combined_shot_type+playoffs2+
           shot_zone_area+shot_zone_basic+Year+shot_type+opponent,
         data=train_kb,family = binomial(link = "logit"))

anova(fit)

predictions<-predict(fit,test_kb,type = "response")

predictions<-data.frame("shot_id"=test_kb$shot_id,"shot_made_flag"=predictions)


write.csv(predictions,"predictions.csv",quote=F,row.names=F)