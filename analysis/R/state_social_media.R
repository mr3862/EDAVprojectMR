#install.packages("blscrapeR")
#install.packages("jsonlite")

library(blscrapeR)
library(dplyr)
library(tidyverse)
library(jsonlite)


states <- blscrapeR::state_fips %>% 
  transmute(state_code = state_abb,
            state_name=state,
            state_id = as.numeric(fips_state)) 

data <- readr::read_csv("../../data/core_trends.csv") %>%
  select(year, state, contains('sm.use.')) %>%
  set_names(gsub('sm.use.', '', names(.)))

tidy <- data %>%
  gather(app, response, -year, -state) %>%
  filter(!is.na(response), app != 'reddit') %>%
  group_by(year, state, app) %>%
  summarise(percent_use = sum(response == 1) / n(), 
            total_respondents = n()) %>%
  ungroup() %>%
  rename(state_id = state) %>%
  inner_join(states)

json <- toJSON(tidy, dataframe = "rows")
json = paste0("{\"data\":",json,"}")


write(json,"..//..//docs//data//state_social_media.json")

