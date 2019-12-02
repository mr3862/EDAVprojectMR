#install.packages("blscrapeR")
#install.packages("jsonlite")

library(blscrapeR)
library(dplyr)
library(tidyverse)
library(jsonlite)


core_trends_raw = readr::read_csv("data/core_trends.csv")

state_config = state_fips %>% 
  dplyr::rename(
    state_code = state_abb,state_name=state) %>% 
  dplyr::mutate(state_id = as.numeric(fips_state)) %>%
  dplyr::select(state_id,state_code,state_name)


core_trends = core_trends_raw %>% 
  dplyr::mutate(twitter = ifelse(sm.use.twitter==1,"1",NA),
                instagram = ifelse(sm.use.instagram==1,"1",NA),
                facebook = ifelse(sm.use.facebook==1,"1",NA),
                snapchat = ifelse(sm.use.snapchat==1,"1",NA),
                youtube = ifelse(sm.use.youtube==1,"1",NA),
                whatsapp = ifelse(sm.use.whatsapp==1,"1",NA),
                pintrest = ifelse(sm.use.pintrest==1,"1",NA),
                linkedin = ifelse(sm.use.linkedin==1,"1",NA) ) %>%
  dplyr::select(year,state,twitter,instagram,facebook,snapchat,youtube,whatsapp,pintrest,linkedin)


trend_tidy = core_trends %>%
  tidyr::gather("social_media", "user",-year,-state) %>% 
  dplyr::filter(is.na(user) ==FALSE) %>%
  count(year,state,social_media) %>%
  dplyr::rename(user = n,state_id=state)

dataset = inner_join(state_config, trend_tidy)

json <- toJSON(dataset, dataframe = "rows")
json = paste0("{\"data\":",json,"}")


write(json,"..//..//docs//data//state_social_media.json")