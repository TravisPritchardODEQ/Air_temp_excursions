library(tidyverse)
library(zoo)
library(lubridate)


# read air temp stations

data_files <- list.files(path = 'data/raw_data/', full.names = TRUE)

dat <- list()

for(i in 1:length(data_files)){
  print(i)
  
  dat[[i]] <- read.csv(data_files[i], stringsAsFactors = FALSE) %>%
    mutate(TMAX = as.numeric(TMAX)) %>%
    select(STATION, NAME, DATE,TMAX) %>%
    filter(STATION != "")
}

Air_temp <- bind_rows(dat) %>%
  arrange(NAME)




# read 90th percentile values

per90_values <- read.csv('data/90thpercentilevalues.csv', stringsAsFactors = FALSE)


Air_temp_raw <- Air_temp %>%
  filter(!is.na(TMAX)) %>%
  left_join(select(per90_values, STATION, per90, critical.percentage)) %>%
  mutate(AT_excursion = ifelse(TMAX > per90 , 1, 0 ))

Air_temp_checker <- Air_temp_raw %>%
  mutate(AT_excursion = ifelse(is.na(AT_excursion), 0, AT_excursion ),
         DATE = mdy(DATE)) %>%
  arrange(STATION, DATE) %>%
  group_by(STATION) %>%
  mutate(startdate7 = lag(DATE, 6, order_by = DATE),
         calc7ma = ifelse(startdate7 == (as.Date(DATE) - 6), 1, 0 )) %>%
  mutate(exclude_excursion = ifelse(calc7ma == 1, rollmax(AT_excursion, k= 7, align = 'right', fill = NA), 0),
         TMAX_7d = ifelse(calc7ma == 1 ,rollmax(TMAX, k= 7, align = 'right', fill = NA), NA),
         note =ifelse(calc7ma == 1, "", "missing air tempeature values in period" )) %>%
  rename(per_complete = critical.percentage) %>%
  select(STATION,
         NAME,
         per_complete,
         DATE,
         TMAX,
         TMAX_7d,
         per90,
         exclude_excursion,
         note) %>%
  ungroup()


save(Air_temp_checker, file = 'data/Air_temp_checker.Rdata')
