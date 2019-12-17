library(tidyverse)
library(zoo)


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
  left_join(select(per90_values, STATION, per90)) %>%
  mutate(AT_excursion = ifelse(TMAX > per90 , 1, 0 ))

Air_temp_checker <- Air_temp_raw %>%
  mutate(AT_excursion = ifelse(is.na(AT_excursion), 0, AT_excursion )) %>%
  group_by(STATION) %>%
  mutate(AT_7d_excursion = rollmax(AT_excursion, k= 7, align = 'right', fill = NA))


save(Air_temp_checker, file = 'data/Air_temp_checker.Rdata')
