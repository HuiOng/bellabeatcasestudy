
install.packages("tidyverse")
install.packages("dplyr")
install.packages("ggplot2")
library(tidyverse)
library(dplyr)
library(ggplot2)

sleep_day <- read.csv("sleepDay_merged.csv")
daily_intensities <- read.csv("dailyIntensities_merged.csv")
daily_steps <- read.csv("dailySteps_merged.csv")
daily_activity <- read_csv("dailyActivity_merged.csv")
heartrate <- read_csv("heartrate_seconds_merged.csv")

head(sleep_day)
colnames(sleep_day)
colnames(daily_intensities)
colnames(daily_steps)

n_distinct(sleep_day$Id)
n_distinct(daily_intensities$Id)
n_distinct(daily_steps$Id)

daily_intensities %>%  
  select(SedentaryMinutes,
         LightlyActiveMinutes,
         FairlyActiveMinutes,
         VeryActiveMinutes) %>%
  summary()

sleep_day %>%  
  select(TotalSleepRecords,
         TotalMinutesAsleep,
         TotalTimeInBed) %>%
  summary()

combined_steps_activity <- merge(sleep_day, daily_activity, by="Id")

activity_summary <- 
  combined_steps_activity %>%
  drop_na()%>%
  group_by(Id) %>%
  summarise(average_timeinbed=mean(TotalTimeInBed),
            average_min_asleep=mean(TotalMinutesAsleep),
            min_calories=min(Calories),
            max_calories=max(Calories),
            average_calories=mean(Calories),
            average_steps=mean(TotalSteps),
            total_activeminutes=sum(VeryActiveMinutes+ FairlyActiveMinutes+LightlyActiveMinutes),
            sleep_hours=factor(case_when(TotalMinutesAsleep >=420 ~ "7 hours and above",
                                         TotalMinutesAsleep <420 & TotalMinutesAsleep >=240 ~ "4 to 7 hours",
                                         TotalMinutesAsleep <240 ~ "Less than 4 hours")))

# To plot number of sleep hours
activity_summary$sleep_hours <- factor(activity_summary$sleep_hours,levels = c("Less than 4 hours", "4 to 7 hours", "7 hours and above"))
ggplot(data = activity_summary) + geom_bar(mapping=aes(x=sleep_hours, fill = sleep_hours))+ theme(axis.text.x = element_text(angle = 15))

ggplot(data = activity_summary) + geom_point(mapping=aes(x=average_calories,y=average_steps,color=sleep_hours))
