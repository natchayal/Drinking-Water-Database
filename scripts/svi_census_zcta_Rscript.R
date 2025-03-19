##########################################################
# Title: Demographics and Income Data
# Description: Script to get census data by zipcode (ZCTA)
# author: Natchaya Luangphairin
# date last revised: 3/17/25
# output: R Script
##########################################################
  
# ZIP Code Tabulation Areas (ZCTAs) https://www.census.gov/programs-surveys/geography/guidance/geo-areas/zctas.html gives census data by zipcode
# https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2020&layergroup=ZIP+Code+Tabulation+Areas

# Load packages and libraries ---------------------------------------------
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, readxl, purrr, tools, lubridate, writexl, zoo, ggthemes, tidycensus, sf, tigris, findSVI) 
setwd("C:/Users/nluan/OneDrive/Documents/GitHub/Drinking-Water-Database")


# SVI and Census ----------------------------------------------------------
## package tidycensus: https://walker-data.com/tidycensus/
## package findSVI: https://cran.r-project.org/web/packages/findSVI/findSVI.pdf
## sign-up for census API key https://api.census.gov/data/key_signup.html

# set Census API key
census_api_key("YOUR KEY GOES HERE", overwrite = TRUE, install = TRUE)

# define zip code of interest
zip_codes <- c("33606","33609","33629","33611","33616","33605","33619","33610","33584","33510","33527","33592")

# for year of interest
svi_census_zcta <- get_census_data(
  year = 2021,
  geography = "zcta",
  zcta = zip_codes
)

svi_zcta <- get_svi(2021, svi_census_zcta) %>%
  mutate(ZCTA = str_sub(NAME, -5),
         ZIPCODE = ZCTA
  )

svi_zcta <- svi_zcta %>%
  select(GEOID, NAME, ZCTA, ZIPCODE, everything())

# left join crosswalk data - zcta_state_xwalk2021 - to get FIPS code, state, and county info by matching ZCTA
View(zcta_state_xwalk2021)
View(fips_codes)

colnames(zcta_state_xwalk2021) <- toupper(colnames(zcta_state_xwalk2021)) 
zcta_state_xwalk2021 <- zcta_state_xwalk2021 %>%
  mutate(ST_CODE = ifelse(nchar(ST_CODE) == 1, sprintf("%02d", as.numeric(ST_CODE)), ST_CODE))

colnames(fips_codes) <- toupper(colnames(fips_codes)) 

# Get the ZCTA bounaries shapefile, which includes latitude/longitude and geometry, from the Census TIGER/Line shapefiles
zcta_shapefile <- zctas(cb = TRUE, year = 2020) %>%
  st_transform(crs = 4326)  # Transform to standard latitude/longitude coordinate system

# calculate the centroids (latitude and longitude) for each ZCTA
zcta_centroids <- zcta_shapefile %>%
  st_centroid() %>%
  st_coordinates() %>%
  as.data.frame()

# add the ZCTA code (GEOID) and merge with centroid data
zcta_latlong <- zcta_shapefile %>%
  mutate(LAT = zcta_centroids$Y, 
         LON = zcta_centroids$X,
         LAND_AREA_SQMI = ALAND20,
         WATER_AREA_SQMI = AWATER20) 

# Select only the important columns: GEOID20, LAT, and LON
zcta_latlong <- zcta_latlong %>%
  select(GEOID20, LAND_AREA_SQMI, WATER_AREA_SQMI, LAT, LON, geometry) %>%
  rename_all(toupper)

svi_zcta <- svi_zcta %>%
  left_join(zcta_state_xwalk2021, by = "ZCTA") %>%
  left_join(zcta_latlong, by = c("GEOID" = "GEOID20")) %>%
  left_join(fips_codes, by = c("ST_CODE" = "STATE_CODE", "ST_ABB" = "STATE", "COUNTY")) %>%
  mutate(FIPS = paste0(ST_CODE,COUNTY_CODE)) %>%
  select(GEOID, FIPS, ST_CODE, COUNTY_CODE, STATE, ST_ABB, COUNTY, NAME, ZCTA, ZIPCODE, LAT, LON, GEOMETRY, LAND_AREA_SQMI, WATER_AREA_SQMI, everything()) %>%
  rename_all(toupper) %>%
  select(-c("STATE_NAME"))

View(svi_zcta)

# add additional income data, retrieve income and poverty data for each ZCTAs
variables = c(
  MED_INCOME = "B19013_001",         # Median household income
  PER_CAPITA_INCOME = "B19301_001",  # Per capita income
  BELOW_POV150 = "B17001_002",       # People below the poverty level
  ABOVE_POV150 = "B17001_031"        # People at or above the poverty level
)

income_poverty_data <- get_acs(
  geography = "zcta",
  variables = variables,
  year = 2021,
  #survey = "acs5",
  #output = "wide",
  zcta = zip_codes
  
)

# Pivot wider and rename columns for estimates (E_) and proportions (EP_)
income_poverty_data <- income_poverty_data %>%
  select(GEOID, NAME, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate, names_prefix = "E_") %>%
  mutate(
    EP_BELOW_POV150 = (E_BELOW_POV150 / (E_BELOW_POV150 + E_ABOVE_POV150)) * 100,  # Percent below poverty
    EP_ABOVE_POV150 = (E_ABOVE_POV150 / (E_BELOW_POV150 + E_ABOVE_POV150)) * 100   # Percent above poverty
  )

# Join income and poverty data with your SVI ZCTA dataset
svi_zcta_demographics_income <- svi_zcta %>%
  left_join(income_poverty_data, by = c("GEOID", "NAME")) %>%
  select(GEOID, FIPS, ST_CODE, COUNTY_CODE, STATE, ST_ABB, COUNTY, NAME, ZCTA, ZIPCODE, LAT, LON, GEOMETRY, 
         LAND_AREA_SQMI, WATER_AREA_SQMI, E_MED_INCOME, E_PER_CAPITA_INCOME, E_BELOW_POV150, 
         E_ABOVE_POV150, EP_BELOW_POV150, 
         EP_ABOVE_POV150, everything()
  )
  
write_csv(svi_zcta_demographics_income, "data/svi_census/raw/svi_census_zcta_2022.csv")




# Entire dataset ----------------------------------------------------------
# to get list census variables for example type: census_variables_2012
svi_census_county <- get_census_data(
  year = 2020,
  geography = "county",
  county = "Hillsborough"
)


# for multiple years
year <- c(2014,2015,2016,2017,2018,2019,2020,2021)
state <- "FL" # state = "US" or state = NULL is also accepted for nation-level data
zcta <- zip_codes
info <- data.frame(year, state)

svi_census_zcta_all <- find_svi(
  year = info$year,
  state= info$state,
  geography = "zcta"
)
