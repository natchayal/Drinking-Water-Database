---
# Title: Metadataset for PWS with Demographic Info
# Description: Data pre-processing
# author: Natchaya Luangphairin
# date last revised: 09/26/24
# output: R Script
---

# Load packages and libraries ---------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(shiny, tidyverse, maps, viridis, writexl, tictoc, zoo, ggthemes)

# Define functions --------------------------------------------------------
# Define EPA regions list
EPA_regions <- list(
  "01" = c("CT", "ME", "MA", "NH", "RI", "VT"),
  "02" = c("NJ", "NY", "PR", "VI"),
  "03" = c("DC", "DE", "MD", "PA", "VA", "WV"),
  "04" = c("AL", "FL", "GA", "KY", "MS", "NC", "SC", "TN"),
  "05" = c("IL", "IN", "MI", "MN", "OH", "WI"),
  "06" = c("AR", "LA", "NM", "OK", "TX"),
  "07" = c("IA", "KS", "MO", "NE"),
  "08" = c("CO", "MT", "ND", "SD", "UT", "WY"),
  "09" = c("AZ", "CA", "HI", "NV", "AS", "GU"),
  "10" = c("AK", "ID", "OR", "WA")
)

# Create a function to get the EPA region based on the first two characters
get_EPA_region <- function(pgm_sys_id) {
  first_two <- substr(pgm_sys_id, 1, 2)  # Extract the first two characters
  
  for (region in names(EPA_regions)) {
    if (first_two %in% EPA_regions[[region]] || first_two == region) {
      return(region)
    }
  }
  return(NA)  # Return NA if no match is found
}

# Create a function to get the STATE_CODE based on the first two characters of PWSID
get_STATE_CODE <- function(pwsid) {
  first_two <- substr(pwsid, 1, 2)  # Extract the first two characters
}
  
# NOTE: EPA ECHO database has a lot of data and easy to get lost. Recommend pre-processing data as follow to allow stitching:
##(1) use FRS_PROGRAM_LINKS.csv to match PWSID with PGM_SYS_ID and get its matching REGISTRY_ID and FAC. PGM_SYS_ACRNM == SFDW and PGM_SYS_ID == PWSID for SDWIS data
##(2) use PWSID and/or FIPS to merge with other databases

# Pre-processing data -----------------------------------------------------
##https://echo.epa.gov/tools/data-downloads
##download .zip files, unzip, and save files in data/raw/

# ECHO Exporter -----------------------------------------------------------
##provides summary information about each facility in a table format
echo_exporter <- read_csv("data/raw/echo_exporter/ECHO_EXPORTER.csv") 

# Facility Registry Service (FRS) Download --------------------------------
##https://echo.epa.gov/tools/data-downloads/frs-download-summary
##Facility identification data from EPA's Facility Registry Service (FRS), which integrates facility information from various EPA and state data systems.
###Facilities contains FRS Name and Address information along with "Registry_ID," the unique FRS Facility identifier. PGM_SYS_ACRNM, PGM_SYS_ID, and REGISTRY_ID are primary keys.
###Program Links contains the linkages between program record (identified by Program Acronym and Program System Identifier) to the FRS Facility (identified by the Registry ID).
###NAICS and SIC contain the industrial classification codes for each facility in FRS.
frs_program_links <- read_csv("data/raw/frs_downloads/FRS_PROGRAM_LINKS.csv") # THIS IS THE MVP: Match PGM_SYS_ID with PWSID and REGISTRY_ID, then use REGISTRY_ID to match rest
frs_program_links$REGISTRY_ID <- as.character(frs_program_links$REGISTRY_ID) # after filtered for SFDW address info are all NAs; get FIPS code by ZIPCODE here for SVI analysis later
frs_facilities <- read_csv("data/raw/frs_downloads/FRS_FACILITIES.csv") # contains all facility address with lat/long info that is missing as NA in frs_program_links, with county for svi analysis
frs_facilities$REGISTRY_ID <- as.character(frs_facilities$REGISTRY_ID) 
frs_naics_codes <- read_csv("data/raw/frs_downloads/FRS_NAICS_CODES.csv") # NAICS codes are 6 digit numbers used by the Bureau of Census as part of a system to categorize and track the types of business activities conducted in the United States.
frs_naics_codes$REGISTRY_ID <- as.character(frs_naics_codes$REGISTRY_ID)
frs_sic_codes <- read_csv("data/raw/frs_downloads/FRS_SIC_CODES.csv") # The 4-digit Standard Industrial Classification (SIC) code that represents the economic activity of a company.
frs_sic_codes$REGISTRY_ID <- as.character(frs_sic_codes$REGISTRY_ID)

#sic_dictionary <- read_csv(url("https://data.epa.gov/efservice/TRI_FACILITY_SIC/ROWS/0:10/CSV"))

# Community and Demographic Downloads (derived from U.S. Census and ACS) -
##Demographic data describing the population within 1, 3, and 5 mile radii around the location of each facility in ECHO
echo_demographics <- read_csv("data/raw/echo_demographics/ECHO_DEMOGRAPHICS.csv")


# Social Vulnerability Indexes (SVI) --------------------------------------
##https://www.atsdr.cdc.gov/placeandhealth/svi/index.html
##https://www.atsdr.cdc.gov/placeandhealth/svi/interactive_map.html (has all colnames the same, easier for joinging multiple years data)
##CDC/ATSDR's SVI data available starting for years 2000. Data gets updated every two years
svi_2000 <- mutate(read_csv("data/raw/svi/SVI_2000_US_county.csv"), YEAR = "2000")
svi_2010 <- mutate(read_csv("data/raw/svi/SVI_2010_US_county.csv"), YEAR = "2010")
svi_2014 <- mutate(read_csv("data/raw/svi/SVI_2014_US_county.csv"), YEAR = "2014")
svi_2016 <- mutate(read_csv("data/raw/svi/SVI_2016_US_county.csv"), YEAR = "2016")
svi_2018 <- mutate(read_csv("data/raw/svi/SVI_2018_US_county.csv"), YEAR = "2018")
svi_2020 <- mutate(read_csv("data/raw/svi/SVI_2020_US_county.csv"), YEAR = "2020")
svi_2022 <- mutate(read_csv("data/raw/svi/SVI_2022_US_county.csv"), YEAR = "2022")

# Assume you have a dataframe 'df' (replace it with your actual dataframe)
colnames_format <- paste0('c("', paste(colnames(svi_2018), collapse = '", "'), '")')
cat(colnames_format)

# Rename columns in svi_2000 to match the structure of svi_2022
svi_2000 <- svi_2000 %>%
  rename(
    FIPS = STCOFIPS,
    STATE = STATE_NAME,
    ST_ABBR = STATE_ABBR,
    COUNTY = COUNTY,
    
    # Estimates
    E_TOTPOP = Totpop2000, # Total population
    E_HU = Totalhu,        # Total housing units
    E_POV150 = G1V1N,  # Poverty level
    E_UNEMP = G1V2N,   # Unemployment rate
    E_PCI = G1V3R,     # Per capita income
    E_NOHSDP = G1V4N,  # No high school diploma
    E_AGE65 = G2V1N,   # Aged 65 and older
    E_AGE17 = G2V2N,   # Aged 17 and younger
    E_DISABL = G2V3N,  # Persons with disabilities
    E_SNGPNT = G2V4N,  # Single-parent households
    E_MINRTY = G3V1N,  # Minority status
    E_LIMENG = G3V2N,  # Persons with limited English proficiency
    E_MUNIT = G4V1N,   # Housing units in multi-unit structures
    E_MOBILE = G4V2N,  # Mobile homes
    E_CROWD = G4V3N,   # Crowded rooms
    E_NOVEH = G4V4N,   # No vehicle access
    E_GROUPQ = G4V5N,  # Group quarters
    
    # Proportion
    EP_POV150 = G1V1R,  # Poverty level
    EP_UNEMP = G1V2R,   # Unemployment rate
    EP_NOHSDP = G1V4R,  # No high school diploma
    EP_AGE65 = G2V1R,   # Aged 65 and older
    EP_AGE17 = G2V2R,   # Aged 17 and younger
    EP_DISABL = G2V3R,  # Persons with disabilities
    EP_SNGPNT = G2V4R,  # Single-parent households
    EP_MINRTY = G3V1R,  # Minority status
    EP_LIMENG = G3V2R,  # Persons with limited English proficiency
    EP_MUNIT = G4V1R,   # Housing units in multi-unit structures
    EP_MOBILE = G4V2R,  # Mobile homes
    EP_CROWD = G4V3R,   # Crowded rooms
    EP_NOVEH = G4V4R,   # No vehicle access
    EP_GROUPQ = G4V5R,  # Group quarters
    
    # Percentiles
    EPL_POV150 = USG1V1P,  # Percentile - Poverty level
    EPL_UNEMP = USG1V2P,   # Percentile - Unemployment rate
    EPL_PCI = USG1V3P,     # Percentile - Per capita income
    EPL_NOHSDP = USG1V4P,  # Percentile - No high school diploma
    EPL_AGE65 = USG2V1P,   # Percentile - Aged 65 and older
    EPL_AGE17 = USG2V2P,   # Percentile - Aged 17 and younger
    EPL_DISABL = USG2V3P,  # Percentile - Persons with disabilities
    EPL_SNGPNT = USG2V4P,  # Percentile - Single-parent households
    EPL_MINRTY = USG3V1P,  # Percentile - Minority status
    EPL_LIMENG = USG3V2P,  # Percentile - Persons with limited English proficiency
    EPL_MUNIT = USG4V1P,   # Percentile - Housing units in multi-unit structures
    EPL_MOBILE = USG4V2P,  # Percentile - Mobile homes
    EPL_CROWD = USG4V3P,   # Percentile - Crowded rooms
    EPL_NOVEH = USG4V4P,   # Percentile - No vehicle access
    EPL_GROUPQ = USG4V5P,  # Percentile - Group quarters
    
    # Flags
    F_POV150 = USG1V1F,    # Flag - Poverty level in the 90th percentile
    F_UNEMP = USG1V2F,     # Flag - Unemployment in the 90th percentile
    F_PCI = USG1V3F,       # Flag - Per capita income
    F_NOHSDP = USG1V4F,    # Flag - No high school diploma in the 90th percentile
    F_AGE65 = USG2V1F,     # Flag - Aged 65 and older in the 90th percentile
    F_AGE17 = USG2V2F,     # Flag - Aged 17 and younger in the 90th percentile
    F_DISABL = USG2V3F,    # Flag - Persons with disabilities in the 90th percentile
    F_SNGPNT = USG2V4F,    # Flag - Single-parent households in the 90th percentile
    F_MINRTY = USG3V1F,    # Flag - Minority status in the 90th percentile
    F_LIMENG = USG3V2F,    # Flag - Persons with limited English proficiency in the 90th percentile
    F_MUNIT = USG4V1F,     # Flag - Housing units in multi-unit structures in the 90th percentile
    F_MOBILE = USG4V2F,    # Flag - Mobile homes in the 90th percentile
    F_CROWD = USG4V3F,     # Flag - Crowded rooms
    F_NOVEH = USG4V4F,     # Flag - No vehicle access in the 90th percentile
    F_GROUPQ = USG4V5F,    # Flag - Group quarters in the 90th percentile
    F_TOTAL = USTF,        # Flag - Total
    F_THEME1 = USG1TF,     # Flag - Socioeconomic Domain Total Flags
    F_THEME2 = USG2TF,     # Flag - Household Composition & Disability Total Flags
    F_THEME3 = USG3TF,     # Flag - Minority Status/Language Domain Total Flags
    F_THEME4 = USG4TF,     # Flag - Housing/Transportation Domain Total Flags
    
    # SVI
    RPL_THEME1 = USG1TP,   # SVI - Socioeconomic Domain Total Percentile Ranking 
    RPL_THEME2 = USG2TP,   # SVI - Household Composition & Disability Total Percentile Ranking 
    RPL_THEME3 = USG3TP,   # SVI - Minority Status/Language Domain Total Percentile Ranking 
    RPL_THEME4 = USG4TP,    # SVI - Housing/Transportation Domain Total Percentile Ranking 
    RPL_THEMES = USTP
    
  )

# Add missing columns from svi_2022 and fill with NA
missing_columns <- setdiff(colnames(svi_2022), colnames(svi_2000))
svi_2000[missing_columns] <- NA

# Reorder columns to match the exact structure of svi_2022
svi_2000 <- svi_2000[, colnames(svi_2022)]



# Rename columns in svi_2010 to match the structure of svi_2022
# Avoid renaming columns that are already correctly named
svi_2010 <- svi_2010 %>%
  rename(
    # Unique columns that don't have duplicates
    FIPS = FIPS,
    STATE = STATE,
    ST = ST,
    COUNTY = LOCATION,   # Assuming LOCATION contains county information
    E_TOTPOP = E_TOTPOP,   # Total population estimate (renaming only once)
    M_TOTPOP = M_TOTPOP, # MOE for total population (keep as is)
    
    E_HU = E_HU,           # Housing units estimate (renaming only once)
    M_HU = M_HU,         # MOE for housing units (keep as is)
    
    E_HH = HH,           # Number of households (renaming only once)
    E_POV150 = E_POV,    # Poverty level estimate
    M_POV150 = M_POV,    # MOE for poverty level
    E_UNEMP = E_UNEMP,   # Unemployment estimate
    M_UNEMP = M_UNEMP,   # MOE for unemployment
    E_PCI = E_PCI,       # Per capita income estimate
    M_PCI = M_PCI,       # MOE for per capita income
    E_NOHSDP = E_NOHSDIP,# No high school diploma estimate
    M_NOHSDP = M_NOHSDIP,# MOE for no high school diploma
    E_AGE65 = AGE65,     # Aged 65 and older
    E_AGE17 = AGE17,     # Aged 17 and younger
    E_SNGPNT = SNGPRNT,  # Single-parent households
    E_MINRTY = MINORITY, # Minority status
    E_LIMENG = E_LIMENG, # Limited English proficiency estimate
    M_LIMENG = M_LIMENG, # MOE for limited English proficiency
    E_MUNIT = E_MUNIT,   # Housing units in multi-unit structures estimate
    M_MUNIT = M_MUNIT,   # MOE for multi-unit structures
    E_MOBILE = E_MOBILE, # Mobile homes estimate
    M_MOBILE = M_MOBILE, # MOE for mobile homes
    E_CROWD = E_CROWD,   # Overcrowded housing estimate
    M_CROWD = M_CROWD,   # MOE for overcrowded housing
    E_NOVEH = E_NOVEH,   # No vehicle access estimate
    M_NOVEH = M_NOVEH,   # MOE for no vehicle access
    E_GROUPQ = GROUPQ,   # Group quarters estimate
    
    # Proportion
    EP_POV150 = E_P_POV,    # Proportion for poverty level
    EP_UNEMP = E_P_UNEMP,   # Proportion for unemployment
    EP_PCI = E_P_PCI,       # Proportion for per capita income
    EP_NOHSDP = E_P_NOHSDIP,# Proportion for no high school diploma
    EP_AGE65 = P_AGE65,     # Proportion for aged 65 and older
    EP_AGE17 = P_AGE17,     # Proportion for aged 17 and younger
    EP_SNGPNT = P_SNGPRNT,  # Proportion for single-parent households
    EP_MINRTY = P_MINORITY, # Proportion for minority status
    EP_LIMENG = E_P_LIMENG, # Proportion for limited English proficiency
    EP_MUNIT = E_P_MUNIT,   # Proportion for multi-unit structures
    EP_MOBILE = E_P_MOBILE, # Proportion for mobile homes
    EP_CROWD = E_P_CROWD,   # Proportion for overcrowded housing
    EP_NOVEH = E_P_NOVEH,   # Proportion for no vehicle access
    EP_GROUPQ = P_GROUPQ,   # Proportion for group quarters
    
    # Percentiles
    EPL_POV150 = E_PL_POV,    # Percentile for poverty level
    EPL_UNEMP = E_PL_UNEMP,   # Percentile for unemployment
    EPL_PCI = E_PL_PCI,       # Percentile for per capita income
    EPL_NOHSDP = E_PL_NOHSDIP,# Percentile for no high school diploma
    EPL_AGE65 = PL_AGE65,     # Percentile for aged 65 and older
    EPL_AGE17 = PL_AGE17,     # Percentile for aged 17 and younger
    EPL_SNGPNT = PL_SNGPRNT,  # Percentile for single-parent households
    EPL_MINRTY = PL_MINORITY, # Percentile for minority status
    EPL_LIMENG = E_PL_LIMENG, # Percentile for limited English proficiency
    EPL_MUNIT = E_PL_MUNIT,   # Percentile for multi-unit structures
    EPL_MOBILE = E_PL_MOBILE, # Percentile for mobile homes
    EPL_CROWD = E_PL_CROWD,   # Percentile for overcrowded housing
    EPL_NOVEH = E_PL_NOVEH,   # Percentile for no vehicle access
    EPL_GROUPQ = PL_GROUPQ,   # Percentile for group quarters
    
    # Flags
    F_POV150 = F_PL_POV,     # Flag - Poverty level in 90th percentile
    F_UNEMP = F_PL_UNEMP,    # Flag - Unemployment in 90th percentile
    F_PCI = F_PL_PCI,        # Flag - Per capita income in 90th percentile
    F_NOHSDP = F_PL_NOHSDIP, # Flag - No high school diploma in 90th percentile
    F_AGE65 = F_PL_AGE65,    # Flag - Aged 65 and older in 90th percentile
    F_AGE17 = F_PL_AGE17,    # Flag - Aged 17 and younger in 90th percentile
    F_SNGPNT = F_PLSNGPRNT,  # Flag - Single-parent households in 90th percentile
    F_MINRTY = F_PL_MINORITY,# Flag - Minority status in 90th percentile
    F_LIMENG = F_PL_LIMENG,  # Flag - Limited English proficiency in 90th percentile
    F_MUNIT = F_PL_MUNIT,    # Flag - Multi-unit structures in 90th percentile
    F_MOBILE = F_PL_MOBILE,  # Flag - Mobile homes in 90th percentile
    F_CROWD = F_PL_CROWD,    # Flag - Overcrowded housing in 90th percentile
    F_NOVEH = F_PL_NOVEH,    # Flag - No vehicle access in 90th percentile
    F_GROUPQ = F_PL_GROUPQ,  # Flag - Group quarters in 90th percentile
    F_THEME1 = F_PL_THEME1,  # Flag - Socioeconomic Domain Total Flags
    F_THEME2 = F_PL_THEME2,  # Flag - Household Composition & Disability Total Flags
    F_THEME3 = F_PL_THEME3,  # Flag - Minority Status/Language Domain Total Flags
    F_THEME4 = F_PL_THEME4,  # Flag - Housing/Transportation Domain Total Flags
    F_TOTAL = F_PL_TOTAL,    # Flag - Total
    
    # SVI
    SPL_THEME1 = S_PL_THEME1,   # SVI - Socioeconomic Domain Sum of Total Percentile
    SPL_THEME2 = S_PL_THEME2,   # SVI - Household Composition & Disability Sum of Total Percentile 
    SPL_THEME3 = S_PL_THEME3,   # SVI - Minority Status/Language Domain Sum of Total Percentile
    SPL_THEME4 = S_PL_THEME4,   # SVI - Housing/Transportation Domain Sum of Total Percentile
    SPL_THEMES = S_PL_THEMES,   # SVI - Total Sum of Total Percentile
    
    RPL_THEME1 = R_PL_THEME1,   # SVI - Socioeconomic Domain Total Percentile Ranking 
    RPL_THEME2 = R_PL_THEME2,   # SVI - Household Composition & Disability Total Percentile Ranking 
    RPL_THEME3 = R_PL_THEME3,   # SVI - Minority Status/Language Domain Total Percentile Ranking 
    RPL_THEME4 = R_PL_THEME4,   # SVI - Housing/Transportation Domain Total Percentile Ranking 
    RPL_THEMES = R_PL_THEMES    # SVI - Total
  )

# Add missing columns from svi_2022 and fill with NA
missing_columns <- setdiff(colnames(svi_2022), colnames(svi_2010))
svi_2010[missing_columns] <- NA

# Reorder columns to match the exact structure of svi_2022
svi_2010 <- svi_2010[, colnames(svi_2022)]


# Rename columns in svi_2014 to match the structure of svi_2022
svi_2014 <- svi_2014 %>%
  rename(
    FIPS = FIPS,
    STATE = STATE,
    ST = ST,
    ST_ABBR = ST_ABBR,
    COUNTY = COUNTY,
    LOCATION = LOCATION,
    AREA_SQMI = AREA_SQMI,
    E_TOTPOP = E_TOTPOP,   # Total population estimate
    M_TOTPOP = M_TOTPOP,   # MOE for total population
    E_HU = E_HU,           # Housing units estimate
    M_HU = M_HU,           # MOE for housing units
    E_HH = E_HH,           # Households estimate
    M_HH = M_HH,           # MOE for households
    E_POV150 = E_POV,      # Poverty estimate
    M_POV150 = M_POV,      # MOE for poverty
    E_UNEMP = E_UNEMP,     # Unemployment estimate
    M_UNEMP = M_UNEMP,     # MOE for unemployment
    E_NOHSDP = E_NOHSDP,   # No high school diploma estimate
    M_NOHSDP = M_NOHSDP,   # MOE for no high school diploma
    E_UNINSUR = E_UNINSUR, # Uninsured estimate
    M_UNINSUR = M_UNINSUR, # MOE for uninsured
    E_AGE65 = E_AGE65,     # Aged 65 and older
    M_AGE65 = M_AGE65,     # MOE for aged 65 and older
    E_AGE17 = E_AGE17,     # Aged 17 and younger
    M_AGE17 = M_AGE17,     # MOE for aged 17 and younger
    E_DISABL = E_DISABL,   # Disability estimate
    M_DISABL = M_DISABL,   # MOE for disability
    E_SNGPNT = E_SNGPNT,   # Single-parent households estimate
    M_SNGPNT = M_SNGPNT,   # MOE for single-parent households
    E_MINRTY = E_MINRTY,   # Minority status estimate
    M_MINRTY = M_MINRTY,   # MOE for minority status
    E_LIMENG = E_LIMENG,   # Limited English proficiency estimate
    M_LIMENG = M_LIMENG,   # MOE for limited English proficiency
    E_MUNIT = E_MUNIT,     # Multi-unit housing estimate
    M_MUNIT = M_MUNIT,     # MOE for multi-unit housing
    E_MOBILE = E_MOBILE,   # Mobile homes estimate
    M_MOBILE = M_MOBILE,   # MOE for mobile homes
    E_CROWD = E_CROWD,     # Overcrowded housing estimate
    M_CROWD = M_CROWD,     # MOE for overcrowded housing
    E_NOVEH = E_NOVEH,     # No vehicle access estimate
    M_NOVEH = M_NOVEH,     # MOE for no vehicle access
    E_GROUPQ = E_GROUPQ,   # Group quarters estimate
    M_GROUPQ = M_GROUPQ,   # MOE for group quarters
    
    # Percentiles
    EPL_POV150 = EPL_POV,    # Percentile for poverty level
    EPL_UNEMP = EPL_UNEMP,   # Percentile for unemployment
    EPL_NOHSDP = EPL_NOHSDP, # Percentile for no high school diploma
    EPL_AGE65 = EPL_AGE65,   # Percentile for aged 65 and older
    EPL_AGE17 = EPL_AGE17,   # Percentile for aged 17 and younger
    EPL_SNGPNT = EPL_SNGPNT, # Percentile for single-parent households
    EPL_MINRTY = EPL_MINRTY, # Percentile for minority status
    EPL_LIMENG = EPL_LIMENG, # Percentile for limited English proficiency
    EPL_MUNIT = EPL_MUNIT,   # Percentile for multi-unit housing
    EPL_MOBILE = EPL_MOBILE, # Percentile for mobile homes
    EPL_CROWD = EPL_CROWD,   # Percentile for overcrowded housing
    EPL_NOVEH = EPL_NOVEH,   # Percentile for no vehicle access
    EPL_GROUPQ = EPL_GROUPQ, # Percentile for group quarters
    
    # Flags
    F_POV150 = F_POV,     # Flag - Poverty level in 90th percentile
    F_UNEMP = F_UNEMP,    # Flag - Unemployment in 90th percentile
    F_NOHSDP = F_NOHSDP,  # Flag - No high school diploma in 90th percentile
    F_AGE65 = F_AGE65,    # Flag - Aged 65 and older in 90th percentile
    F_AGE17 = F_AGE17,    # Flag - Aged 17 and younger in 90th percentile
    F_SNGPNT = F_SNGPNT,  # Flag - Single-parent households in 90th percentile
    F_MINRTY = F_MINRTY,  # Flag - Minority status in 90th percentile
    F_LIMENG = F_LIMENG,  # Flag - Limited English proficiency in 90th percentile
    F_MUNIT = F_MUNIT,    # Flag - Multi-unit housing in 90th percentile
    F_MOBILE = F_MOBILE,  # Flag - Mobile homes in 90th percentile
    F_CROWD = F_CROWD,    # Flag - Overcrowded housing in 90th percentile
    F_NOVEH = F_NOVEH,    # Flag - No vehicle access in 90th percentile
    F_GROUPQ = F_GROUPQ   # Flag - Group quarters in 90th percentile
  )

# Add missing columns from svi_2022 and fill them with NA
missing_columns <- setdiff(colnames(svi_2022), colnames(svi_2014))
svi_2014[missing_columns] <- NA

# Reorder columns to match the exact structure of svi_2022
svi_2014 <- svi_2014[, colnames(svi_2022)]


# Rename columns in svi_2016 to match the structure of svi_2022
svi_2016 <- svi_2016 %>%
  rename(
    E_POV150 = E_POV,      # Poverty estimate
    M_POV150 = M_POV,      # MOE for poverty
  
    # Percentiles
    EPL_POV150 = EPL_POV,    # Percentile for poverty level
    
    # Flags
    F_POV150 = F_POV,     # Flag - Poverty level in 90th percentile
  )

# Add missing columns from svi_2022 and fill them with NA
missing_columns <- setdiff(colnames(svi_2022), colnames(svi_2016))
svi_2016[missing_columns] <- NA

# Reorder columns to match the exact structure of svi_2022
svi_2016 <- svi_2016[, colnames(svi_2022)]


# Rename columns in svi_2018 to match the structure of svi_2022
svi_2018 <- svi_2018 %>%
  rename(
    E_POV150 = E_POV,      # Poverty estimate
    M_POV150 = M_POV,      # MOE for poverty
   
    # Percentiles
    EPL_POV150 = EPL_POV,    # Percentile for poverty level
   
    # Flags
    F_POV150 = F_POV,     # Flag - Poverty level in 90th percentile
  )

# Add missing columns from svi_2022 and fill them with NA
missing_columns <- setdiff(colnames(svi_2022), colnames(svi_2018))
svi_2018[missing_columns] <- NA

# Reorder columns to match the exact structure of svi_2022
svi_2018 <- svi_2018[, colnames(svi_2022)]


# Check columns in SVI 2020 that are not in SVI 2022
columns_in_2020_not_in_2022 <- setdiff(colnames(svi_2020), colnames(svi_2022))

svi <- bind_rows(svi_2000, svi_2010, svi_2014, svi_2016, svi_2018, svi_2020, svi_2022)
list(unique(svi$YEAR)) # check all years present
#write_csv(svi, "data/cleaned/SVI_US_county.csv")
svi <- read_csv("data/cleaned/SVI_US_county.csv")



# EJScreen Data -----------------------------------------------------------
##https://www.epa.gov/ejscreen/download-ejscreen-data



# SDWA Drinking Water Data Downloads --------------------------------------
## Quarterly update (MUST figure out how to get archive data from previous years)
sdwa_events_milestones<- read_csv("data/raw/SDWA_latest_downloads/SDWA_EVENTS_MILESTONES.csv")
sdwa_facilities <- read_csv("data/raw/SDWA_latest_downloads/SDWA_FACILITIES.csv")
sdwa_geographic_areas<- read_csv("data/raw/SDWA_latest_downloads/SDWA_GEOGRAPHIC_AREAS.csv")
sdwa_lcr_samples <- read_csv("data/raw/SDWA_latest_downloads/SDWA_LCR_SAMPLES.csv")
sdwa_pn_violation_assoc <- read_csv("data/raw/SDWA_latest_downloads/SDWA_PN_VIOLATION_ASSOC.csv")
sdwa_pub_water_systems <- read_csv("data/raw/SDWA_latest_downloads/SDWA_PUB_WATER_SYSTEMS.csv")
sdwa_ref_ansi_areas <- read_csv("data/raw/SDWA_latest_downloads/SDWA_REF_ANSI_AREAS.csv")
sdwa_ref_code_values <- read_csv("data/raw/SDWA_latest_downloads/SDWA_REF_CODE_VALUES.csv")
sdwa_service_areas <- read_csv("data/raw/SDWA_latest_downloads/SDWA_SERVICE_AREAS.csv")
sdwa_site_visits <- read_csv("data/raw/SDWA_latest_downloads/SDWA_SITE_VISITS.csv")
sdwa_violations_enforcement <- read_csv("data/raw/SDWA_latest_downloads/SDWA_VIOLATIONS_ENFORCEMENT.csv")

# Pre save csv data to avoid connection issues to local
# All SDWA data download and unzip from https://echo.epa.gov/files/echodownloads/SDWA_latest_downloads.zip
# Treatment and Violation Data scraped from Envirofacts Data Service API


# SDWIS -------------------------------------------------------------------
## Treatment ---------------------------------------------------------------
#https://enviro.epa.gov/enviro/ef_metadata_html.ef_metadata_table?p_table_name=TREATMENT&p_topic=SDWIS
treatment_data1 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/CSV"))
treatment_data2 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/1000000:1500000/CSV"))
treatment_data3 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/1500000:2000000/CSV"))
treatment_data4 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2000000:2100000/CSV"))
treatment_data5 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2100000:2200000/CSV"))
treatment_data6 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2200000:2300000/CSV"))
treatment_data7 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2300000:2400000/CSV"))
treatment_data8 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2400000:2500000/CSV"))
treatment_data9 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2500000:2550000/CSV"))
treatment_data10 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2550000:2600000/CSV"))
treatment_data11 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2600000:2650000/CSV"))
treatment_data12 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2650000:2700000/CSV"))

treatment_data <- do.call("rbind", list(treatment_data1,treatment_data2,treatment_data3,treatment_data4,treatment_data5,treatment_data6,treatment_data7,treatment_data8,treatment_data9,treatment_data10,treatment_data11,treatment_data12))

filename <- paste0("data/raw/AllTreatmentData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
#write_csv(treatment_data, file = filename) # must be updated every now and then
treatment_data <- read_csv("data/raw/AllTreatmentData_EPA_EnvirofactsAPI_091024.csv")


## Violation ---------------------------------------------------------------
#https://enviro.epa.gov/enviro/ef_metadata_html.ef_metadata_table?p_table_name=VIOLATION&p_topic=SDWIS
violation_data1 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/CSV"))
violation_data2 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1000000:1500000/CSV"))
violation_data3 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1500000:2000000/CSV"))
violation_data4 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2000000:2100000/CSV"))
violation_data5 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2100000:2200000/CSV"))
violation_data6 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2200000:2300000/CSV"))
violation_data7 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2300000:2400000/CSV"))
violation_data8 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2400000:2500000/CSV"))
violation_data9 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2500000:2550000/CSV"))
violation_data10 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2550000:2600000/CSV"))
violation_data11 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2600000:2650000/CSV"))
violation_data12 <- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2650000:2700000/CSV"))

violation_data <- do.call("rbind", list(violation_data1,violation_data2,violation_data3,violation_data4,violation_data5,violation_data6,violation_data7,violation_data8,violation_data9,violation_data10,violation_data11,violation_data12))

filename <- paste0("data/raw/AllViolationData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
#write_csv(violation_data, file = filename)
violation_data <- read_csv("data/raw/AllViolationData_EPA_EnvirofactsAPI_091024.csv")

# Merging Data from EPA's database (SDWIS, SYR, etc.)
#https://echo.epa.gov/tools/data-downloads#downloads
#https://echo.epa.gov/tools/data-downloads/sdwa-download-summary#facilities
#https://www.epa.gov/enviro/envirofacts-data-service-api

## PWS System info (SDWA_PUB_WATER_SYSTEMS.csv) ----------------------------
# https://echo.epa.gov/tools/data-downloads#downloads:~:text=Tanks%2C%20and%20TSCA.-,Drinking%20Water%20Data%20Downloads,-Name
# updated quarterly
sdwa_pub_water_systems <- read_csv("data/raw/SDWA_latest_downloads/SDWA_PUB_WATER_SYSTEMS.csv")
# Make all column names lowercase
names(sdwa_pub_water_systems) <- tolower(names(sdwa_pub_water_systems))
#write_csv(sdwa_pub_water_systems,"data/cleaned/SDWA_PUB_WATER_SYSTEMS.csv")
sdwa_pub_water_systems <- read_csv("data/cleaned/SDWA_PUB_WATER_SYSTEMS.csv")

## Codes and values ref (SDWA_REF_CODE_VALUES.csv) -------------------------
# provides key to match codes used in other sdwis database such as sdwa_pub_water_systems and violation
sdwa_ref_code_values <- read_csv("data/raw/SDWA_latest_downloads/SDWA_REF_CODE_VALUES.csv")
names(sdwa_ref_code_values) <- tolower(names(sdwa_ref_code_values))
sdwa_ref_code_values$value_type <- tolower(sdwa_ref_code_values$value_type)
#write_csv(sdwa_ref_code_values,"data/cleaned/SDWA_REF_CODE_VALUES.csv")
sdwa_ref_code_values <- read_csv("data/cleaned/SDWA_REF_CODE_VALUES.csv")

## PWS data ----------------------------------------------------------------
treatment_data <- read_csv("data/raw/AllTreatmentData_EPA_EnvirofactsAPI_091024.csv") # from previous

# Aggregating treatment data
aggregated_treatment_data <- treatment_data %>%
  group_by(pwsid) %>%
  summarise(
    treatment_objective_code = paste(unique(treatment_objective_code), collapse = ","),
    treatment_process_code = paste(unique(treatment_process_code), collapse = ",")
  )

# Joining aggregated treatment data with sdwa pws to make master pws info data
sdwa_pub_water_systems_treatment <- sdwa_pub_water_systems %>%
  left_join(aggregated_treatment_data, by = "pwsid") %>%
  mutate(across(starts_with("pop_cat_"), as.character))

# Find matching column names between two datasets
matching_columns <- intersect(colnames(sdwa_facilities), colnames(frs_naics_code))

# Display the matching column names
print(matching_columns)

# Need this as key to get FIPS by zip code in order to match FIPS with SVI data to get demographics data
# Clean FIPS_CODE and POSTAL_CODE (only keep first 5 digits) while including only specified columns
frs_program_links_fips <- frs_program_links %>%
  filter(grepl("^[0-9]+$", FIPS_CODE)) %>%  # Keep rows where FIPS_CODE contains only digits
  # Clean POSTAL_CODE by keeping only the first 5 digits
  mutate(POSTAL_CODE = substr(POSTAL_CODE, 1, 5)) %>% 
  # Select relevant columns
  select(COUNTY_NAME, FIPS_CODE, STATE_CODE, STATE_NAME, POSTAL_CODE) %>%
  # Keep distinct combinations of POSTAL_CODE and FIPS_CODE
  distinct(COUNTY_NAME, STATE_CODE, POSTAL_CODE, FIPS_CODE, .keep_all = TRUE)

# filter to get drinking water data only and match by REGISTRY_ID to get address and geographic from frs_facilities
frs_program_links_sfdw <- filter(frs_program_links, PGM_SYS_ACRNM == "SFDW") %>% # only want those related to the safe drinking water program; problem = no county name
  mutate(POSTAL_CODE = substr(POSTAL_CODE, 1, 5),
         COUNTY_NAME = gsub(" COUNTY$", "", COUNTY_NAME, ignore.case = TRUE)  # Remove 'COUNTY'
  )

frs_program_links_sfdw_facilities <- left_join(frs_program_links_sfdw, frs_facilities, by = "REGISTRY_ID") # to append county

# Ensure POSTAL_CODE in both datasets only has the first 5 digits
frs_program_links_fips <- frs_program_links_fips %>%
  mutate(POSTAL_CODE = substr(POSTAL_CODE, 1, 5),
         COUNTY_NAME = gsub(" COUNTY$", "", COUNTY_NAME, ignore.case = TRUE)  # Remove 'COUNTY'
  )

frs_program_links_sfdw_facilities <- frs_program_links_sfdw_facilities %>%
  mutate(POSTAL_CODE = substr(FAC_ZIP, 1, 5), # use FAC_ZIP which contains less NAs than POSTAL_CODE
         FAC_COUNTY = gsub(" (COUNTY|COUNT)$", "", FAC_COUNTY, ignore.case = TRUE),  # Remove 'COUNTY'
         COUNTY_NAME = FAC_COUNTY
  )

# Perform a join on STATE_CODE and POSTAL_CODE to match SFDW entries with FIPS data
frs_program_links_sfdw_fips <- frs_program_links_sfdw_facilities %>%
  left_join(frs_program_links_fips, by = c("FAC_STATE" = "STATE_CODE", "FAC_COUNTY" = "COUNTY_NAME", "FAC_ZIP" = "POSTAL_CODE"))


# First join by FAC_STATE, FAC_COUNTY, and FAC_ZIP when FAC_ZIP is not NA
frs_program_links_sfdw_facilities_cleaned <- frs_program_links_sfdw_facilities %>%
  mutate(PWSID = sapply(strsplit(PGM_SYS_ID, " "), function(x) x[1]), # PWSID is PGM_SYS_ID before the first space
         FAC_STREET = ifelse((!is.na(LOCATION_ADDRESS) & is.na(FAC_STREET)), LOCATION_ADDRESS, 
                             ifelse(is.na(LOCATION_ADDRESS) & is.na(FAC_STREET), SUPPLEMENTAL_LOCATION,
                                    FAC_STREET)),
         FAC_CITY = ifelse((!is.na(CITY_NAME) & is.na(FAC_CITY)), CITY_NAME, FAC_CITY),
         FAC_STATE = ifelse((!is.na(STATE_CODE) & is.na(FAC_STATE)), STATE_CODE, 
                            ifelse(is.na(STATE_CODE) & is.na(FAC_STATE), substr(PGM_SYS_ID, 1, 2),
                                   FAC_STATE)),
         FAC_ZIP = ifelse((!is.na(POSTAL_CODE) & is.na(FAC_ZIP)), POSTAL_CODE, FAC_ZIP),
         FAC_COUNTY = ifelse((!is.na(COUNTY_NAME) & is.na(FAC_COUNTY)), COUNTY_NAME, FAC_COUNTY),
         FAC_EPA_REGION = sapply(PGM_SYS_ID, get_EPA_region)) %>%
  subset(.,select = -c(LOCATION_ADDRESS, SUPPLEMENTAL_LOCATION, CITY_NAME, COUNTY_NAME, FIPS_CODE, STATE_CODE, STATE_NAME, COUNTRY_NAME, POSTAL_CODE)) %>%
  select(everything(), PWSID) %>% # Ensure PWSID is added
  select(1:which(names(.) == "REGISTRY_ID"), PWSID, everything()) # Reorder PWSID after REGISTRY_ID

join_with_zip <-  left_join(frs_program_links_sfdw_facilities_cleaned, frs_program_links_fips, by = c("FAC_STATE" = "STATE_CODE", "FAC_COUNTY" = "COUNTY_NAME", "FAC_ZIP" = "POSTAL_CODE"))
# Second join only by FAC_STATE and FAC_COUNTY where FAC_ZIP is NA, keeping first unique match
# Only keep rows where FIPS_CODE is NA and perform the join again on FAC_STATE and FAC_COUNTY
distinct_frs_program_links_fips <- distinct(frs_program_links_fips, STATE_CODE, COUNTY_NAME, .keep_all = TRUE) # Ensure unique rows
join_without_zip <- join_with_zip %>% 
  filter(is.na(FIPS_CODE) | FIPS_CODE == "NA") %>%  # Filter rows where FIPS_CODE is missing
  left_join(distinct_frs_program_links_fips, by = c("FAC_STATE" = "STATE_CODE", "FAC_COUNTY" = "COUNTY_NAME")) %>%
  mutate(FIPS_CODE = ifelse(is.na(FIPS_CODE.x), FIPS_CODE.y, FIPS_CODE.x),
         STATE_NAME = ifelse(is.na(STATE_NAME.x), STATE_NAME.y, STATE_NAME.x)) %>%  # Fill missing FIPS_CODE
  select(-FIPS_CODE.x, -FIPS_CODE.y, -STATE_NAME.x, -STATE_NAME.y, -POSTAL_CODE) 

# Combine the two join results
join_with_zip <- join_with_zip %>% filter(!is.na(FIPS_CODE))
frs_program_links_sfdw_facilities_fips <- bind_rows(join_with_zip, join_without_zip) %>%
  select(-STATE_NAME)

View(frs_program_links_sfdw_facilities_fips)

#write_csv(frs_program_links_sfdw_facilities_fips, "data/cleaned/FRS_PROGRAM_LINKS_SFDW_FACILITIES_FIPS.csv")
frs_program_links_sfdw_facilities_fips <- read_csv("data/cleaned/FRS_PROGRAM_LINKS_SFDW_FACILITIES_FIPS.csv")

# Now we have geographic data and most importantly FIPS we could use to link PWSID to other database such as US Census data


# Violation data cleaned ----------------------------------------------------------
colnames(violation_data) <- toupper(colnames(violation_data))
violation_fips <- left_join(violation_data, frs_program_links_sfdw_facilities_fips, by = "PWSID")
#write_csv(violation_fips, "data/cleaned/ALL_VIOLATION_FIPS.csv")
violation_fips <- read_csv("data/cleaned/ALL_VIOLATION_FIPS.csv") # cleaned data now contains county and other frs info to link with other database



# Geographic Area ---------------------------------------------------------
geographic_area <- read_csv(url("https://data.epa.gov/efservice/GEOGRAPHIC_AREA/ROWS/CSV"))
