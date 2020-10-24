
# Load Libraries
library(tidyverse)
library(stringr)
library(stringi)

# In make_small_versions.R, we filtered information from the datasets on the dcc

### Creating filtered_ncvoterhis_resp.rds ####
voter_small = readRDS("ncvoter_Statewide_small.rds") %>%
  filter(birth_age <= 116) %>%
  dplyr::select(-birth_year, -status_cd, -reason_cd)

hist_small = readRDS("ncvhis_Statewide_small.rds") %>%
  filter(election_desc == "11/08/2016 GENERAL") %>%
  dplyr::select(-election_lbl, -voted_party_cd, -pct_label, -voted_county_id, -vtd_label)

hist_small_not_dup =  hist_small[!duplicated(hist_small$ncid),]

median_inc_county = read.csv("median_household_incomes_NC.csv") %>%
  mutate(county = str_replace(county, " County", "")) %>%
  mutate(county = toupper(county))

voter_hist = merge(voter_small, hist_small_not_dup, by = "ncid", all.x = TRUE)
voter_hist_county = merge(voter_hist, median_inc_county, by.x = "county_desc.x", by.y = "county", all.x = TRUE)
voter_hist_filtered = voter_hist_county

nrow(voter_hist_filtered %>% 
       filter(is.na(cong_dist_abbrv)))

cant_borrow <- voter_hist_filtered %>% 
  group_by(county_desc.x, cong_dist_abbrv) %>% 
  summarise(n=n()) %>% 
  group_by(county_desc.x) %>%
  summarise(n=n()) %>% 
  filter(n>2) %>% 
  select(county_desc.x)
cant_borrow <- cant_borrow$county_desc.x

nrow(voter_hist_filtered %>% 
       filter(is.na(cong_dist_abbrv)) %>% 
       filter(county_desc.x %in% cant_borrow))

nrow(voter_hist_filtered %>% 
       filter(is.na(cong_dist_abbrv)) %>% 
       filter(county_desc.x %in% cant_borrow)) / nrow(voter_hist_filtered)

can_borrow <- voter_hist_filtered %>% 
  group_by(county_desc.x, cong_dist_abbrv) %>% 
  summarise(n=n()) %>% 
  group_by(county_desc.x) %>%
  summarise(n=n()) %>% 
  filter(n==2) %>% 
  select(county_desc.x)
can_borrow <- can_borrow$county_desc.x
can_borrow <- as.character(can_borrow)

# Create a map from county to district
# Match by county because it's much less likely 
# for everyone in a county to only come from one district
# while zip codes might result in false matches
county2district <- voter_hist_filtered %>% 
  filter(county_desc.x %in% can_borrow,
         !is.na(cong_dist_abbrv)) %>% 
  select(county_desc.x, cong_dist_abbrv) %>% 
  unique()
row.names(county2district) <- county2district$county_desc.x
county2district$county_desc.x <- as.character(county2district$county_desc.x)

voter_hist_districts <- voter_hist_filtered %>% 
  mutate(county_desc.x = as.character(county_desc.x)) %>%
  mutate(cong_dist_abbrv = case_when(
    !is.na(cong_dist_abbrv) ~ as.integer(cong_dist_abbrv),
    county_desc.x %in% can_borrow ~ as.integer(county2district[as.character(county_desc.x), 2]),
    TRUE ~ as.integer(NA)
  )) %>% 
  mutate(cong_dist_abbrv = as.factor(cong_dist_abbrv))
still_missing_zipcodes <- voter_hist_districts %>% 
  filter(is.na(cong_dist_abbrv))
still_missing_zipcodes <- still_missing_zipcodes$zip_code
# Most zip codes are missing

voter_hist_districts <- voter_hist_districts %>% 
  filter(!is.na(cong_dist_abbrv))

voter_hist_districts <- voter_hist_districts %>% 
  select(-c("county_desc.y", "county_id.y", "voter_reg_num.x", "voter_reg_num.y")) %>% 
  rename(county_desc = county_desc.x, 
         county_id = county_id.x)

voter_hist_districts_resp = voter_hist_districts %>%
  mutate(vote_or_not = case_when(
    is.na(election_desc) ~ 0,
    TRUE ~ 1
  )) %>%
  select(-county_id, -zip_code, -drivers_lic, -vtd_description, -election_desc)

voter_hist_districts_resp = voter_hist_districts_resp %>%
  mutate(party_cd = as.character(party_cd)) %>%
  mutate(party_cd = case_when(
    party_cd == "DEM" ~ "DEM",
    party_cd == "REP" ~ "REP",
    TRUE ~ "Other"
  )) %>%
  mutate(race_code = case_when(
    race_code == "W" ~ "White",
    race_code == "B" ~ "Black",
    TRUE ~ "Other"
  ))  #%>%
#mutate(birth_age = scale(birth_age, center = TRUE, scale = TRUE))

voter_hist_districts_resp$gender_code = ifelse(voter_hist_districts_resp$gender_code==" ", "U", as.character(voter_hist_districts_resp$gender_code))
voter_hist_districts_resp$race_code = relevel(as.factor(voter_hist_districts_resp$race_code), ref = "White")

voter_hist_districts_resp = voter_hist_districts_resp %>%
  select(-voted_party_desc, -voted_county_desc)

saveRDS(voter_hist_districts_resp, "filtered_ncvoterhis_resp.rds")


#### Creating grouped_voter_data_2012.rds ####
# first, use the same code as above, but filter for 2012 "11/06/2012 GENERAL"
# then, use the following grouping code

q25 = quantile(voter_hist_districts_resp$med_household_income, 0.25)
q50 = quantile(voter_hist_districts_resp$med_household_income, 0.50)
q75 = quantile(voter_hist_districts_resp$med_household_income, 0.75)

# first we need to bin age
voter_hist_districts_resp = voter_hist_districts_resp %>%
  mutate(age_2012 = birth_age - 8) %>%
  filter(!(age_2012 < 18)) %>%
  mutate(age_binned = case_when(
    age_2012 <= 29 ~ "18-29",
    age_2012 >= 30 & age_2012 <= 44 ~ "30-44",
    age_2012 >= 45 & age_2012 <= 59 ~ "45-59",
    age_2012 >= 60 ~ "60+"
  )) %>%
  mutate(med_inc_binned = case_when(
    med_household_income <=q25 ~ paste("<", q25),
    med_household_income > q25 & med_household_income <= q50 ~ paste(q25, "-", q50),
    med_household_income > q50 & med_household_income <= q75 ~ paste(q50, "-", q75),
    med_household_income > q75 ~ paste(">", q75)
  ))

voter_hist_districts_resp$med_inc_binned = factor(voter_hist_districts_resp$med_inc_binned, levels = c("< 46864", "46864 - 52798", "52798 - 64509", "> 64509"))

voter_hist_districts_resp$party_cd = factor(voter_hist_districts_resp$party_cd,
                                            levels = c("DEM", "REP", "Other"))

voter_grouped = voter_hist_districts_resp %>%
  group_by(age_binned, gender_code, party_cd, race_code, med_inc_binned) %>%
  summarise(n = n(), votes = sum(vote_or_not))

voter_grouped %>%
  arrange(., n)


#### Creating randeff_sa_grouped_model_whole_data_output.rds ####
# This file is the model output from the sensitivity analysis with random effects,
# please see 10_20_grouped_model_sa_ra.R for the code to run that model and
# generate the rds (on DCC)

