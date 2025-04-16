#######################################################
# title: "EJScreen data"
# Description: Combine EJScreen and SVI by Zipcode level
# author: Natchaya Luangphairin
# date last revised: "4/15/2025"
# output: R Script
#######################################################

# WORKFLOW
#1 Download EJScreen data from EPA, SVI from CDC/ATSDR, ZCTA from Census
#2 Match ID to ZCTA to get zipcode by using BLOCK_ID, ZCTA and ZIPCODE Crosswalk
#3 Left join SVI with BLOCK_ID and ZCTA, then with EJScreen database, matched by BLOCK_ID 

# Install packages and libraries ------------------------------------------
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, readxl, purrr, tools, lubridate, writexl, zoo, ggthemes, tidycensus, sf, tigris, findSVI) 

# Load data ---------------------------------------------------------------
# EJSCREEN data is available at the census block-group level, which is the smallest level of geographic granularity the tool uses.
# This is a 12-digit code identifying the US Census Block Group where the first 5 digits correspond to the FIPS code of State, County
ejscreen <- read_csv("data/raw/EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv")

# Census data by ZCTA to get ZIPCODE --------------------------------------
## package tidycensus: https://walker-data.com/tidycensus/
## package findSVI: https://cran.r-project.org/web/packages/findSVI/findSVI.pdf
## sign-up for census API key https://api.census.gov/data/key_signup.html

# set Census API key
census_api_key("YOUR API KEY HERE", overwrite = TRUE, install = TRUE)

# zip code
east_tampa_zip <- c("33603", "33605", "33610")
west_tampa_zip <- c("33607")
new_tampa_zip <- c("33647")
university_area_zip <- c("33612", "33613")
temple_terrace_zip <- c("33617", "33637", "33687")
south_tampa_zip <- c("33606", "33608", "33609", "33611", "33616", "33621", "33629")

zip_codes <- c(
  east_tampa_zip,
  west_tampa_zip,
  new_tampa_zip,
  university_area_zip,
  temple_terrace_zip,
  south_tampa_zip
)

ejscreen <- ejscreen %>%
  mutate(FIPS = str_sub(ID, 1, 5)) %>%
  rename(BLOCK_ID = ID) %>%
  select(BLOCK_ID, FIPS, everything())


# Example: total population
svi_census_bg <- get_decennial(
  geography = "block group",
  variables = "P001001",  # total population (2020 Census)
  state = "FL",
  county = "Hillsborough",
  year = 2010,            # 2010 is required for decennial data
  output = "wide"
) %>%
  mutate(BLOCK_ID = GEOID) # ID is block group to match EJScreen

# Add state and county FIPS + names
svi_census_bg <- svi_census_bg %>%
  mutate(
    state_fips = substr(GEOID, 1, 2),
    county_fips = substr(GEOID, 3, 5)
  ) %>%
  left_join(
    tidycensus::fips_codes %>%
      filter(state_code == "12") %>%  # Florida
      select(state_code, county_code, state_name, county) %>%
      distinct(),
    by = c("state_fips" = "state_code", "county_fips" = "county_code")
  )

#data <- left_join(ejscreen, svi_census_bg, by = "BLOCK_ID")


# Link ZCTA to Block ID by matching shapefile geometries ------------------
# Manually Download ZCTA Shapefile (source: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html)
# Scroll to "Web Interface" and select Block or Block Group" to download as .zip
zcta_shapes <- st_read("data/raw/tl_2024_us_zcta520/tl_2024_us_zcta520.shp") %>%
  st_transform(4326)
# Filter ZCTA shapes to only those zipcodes
zcta_filtered <- zcta_shapes %>%
  filter(ZCTA5CE20 %in% zip_codes)

# Get Block Group shapefiles (smallest level EJScreen goes down to)
block_groups <- st_read("data/raw/tl_2024_12_bg/tl_2024_12_bg.shp") %>%
  st_transform(4326)

# Get Block shapefiles (Might be useless since EJScreen don't go down to this level)
block <- st_read("data/raw/tl_2024_12_tabblock20/tl_2024_12_tabblock20.shp") %>%
  st_transform(4326)

# Spatial join: assign each block group a ZIP code (ZCTA)
bg_with_zcta <- st_join(block_groups, zcta_filtered, join = st_intersects)

# Cleanup (rename the ZCTA column)
bg_with_zcta <- bg_with_zcta %>%
  rename(ZCTA = ZCTA5CE20,
         BLOCK_ID = GEOID) %>%
  select(BLOCK_ID, ZCTA, everything())  # Put ID and ZCTA up front followed by everything else. ID is BLOCK_ID


# Get SVI
svi_census_zcta <- get_census_data(year = 2022,geography = "zcta", zcta = zip_codes)

svi_zcta <- get_svi(2022, svi_census_zcta) %>%
  mutate(ZCTA = str_sub(NAME, -5), 
         ZIPCODE = ZCTA)

svi_zcta <- svi_zcta %>%
  select(GEOID, NAME, ZCTA, ZIPCODE, everything())


# Final dataset -----------------------------------------------------------
svi_zcta_select <- svi_zcta %>%
  filter(ZCTA %in% zip_codes)

bg_with_zcta_select <- bg_with_zcta %>%
  filter(ZCTA %in% zip_codes)

bg_zcta_svi_select <- bg_with_zcta_select %>%
  left_join(svi_zcta_select, by = "ZCTA")

# Relate back to EJScreen
# Data Source: 2024 EJScreen, 2022 CDC/ATSDR SVI, 2024 ZCTA Crosswalk data
ejscreen_zipcode <- bg_zcta_svi_select %>%
  left_join(ejscreen, by = "BLOCK_ID") %>%
  mutate(
    ZIPCODE = ZCTA,
    STATE = ifelse(STATEFP == 12, "FL", STATEFP),
    COUNTY = ifelse(COUNTYFP == "057", "Hillsborough County", COUNTYFP),
    TAMPA_AREA = case_when(
      ZIPCODE %in% c("33603", "33605", "33610") ~ "East Tampa",
      ZIPCODE %in% c("33607") ~ "West Tampa",
      ZIPCODE %in% c("33647") ~ "New Tampa",
      ZIPCODE %in% c("33612", "33613") ~ "University Area",
      ZIPCODE %in% c("33617", "33637", "33687") ~ "Temple Terrace",
      ZIPCODE %in% c("33606", "33608", "33609", "33611", "33616", "33621", "33629") ~ "South Tampa",
      TRUE ~ "Other"
    )
  ) %>%
  select(STATE, COUNTY, TAMPA_AREA, BLOCK_ID, ZCTA, ZIPCODE, everything())

write_csv(ejscreen_zipcode, "data/cleaned/EJScreen_with_zipcode.csv")


# Check which zipcode is missing ------------------------------------------
tampa_zip_list <- c(
  "33603", "33605", "33610",                # East Tampa
  "33607",                                  # West Tampa
  "33647",                                  # New Tampa
  "33612", "33613",                         # University Area
  "33617", "33637", "33687",                # Temple Terrace
  "33606", "33608", "33609", "33611",
  "33616", "33621", "33629"                 # South Tampa
)

# Find which ZIPs is not present in our data
missing_zips <- setdiff(tampa_zip_list, unique(ejscreen_zipcode$ZIPCODE))

# These 33687 and 33608 not on list
missing_zips