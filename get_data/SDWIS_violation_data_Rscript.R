#################################################################
# title: "USEPA Violation Data"
# Description: Code to get SDWIS Violation data as .csv using API
# author: Natchaya Luangphairin
# date last revised: "3/17/2025"
# output: R Script
#################################################################
  
# Install packages and load libraries -------------------------------------

#install.packages("pacman")
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, readxl, purrr, tools, lubridate, writexl)
setwd("C:/Users/nluan/OneDrive/Documents/GitHub/Drinking-Water-Database")

# Import data -------------------------------------------------------------

# This code uses R to prevent having to go to a browser, like Chrome, and paste each URL individually to get a single CSV file that you then have to import into R and merge. To see what I mean, paste the following into Chrome to see what individual file R is assigning to each "Data" line below:
  # Example URL:
    # The CSV assigned to Data1: "https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV"

# Run each line one-by-one. Stop once you get an empty data set. You will likely encounter errors for many parts. Don't give up, come back to that set later. You should have over 2 million entries in the DataMerged file if you did this correctly.

# Import violation data by PWSID (each year there's ~220,000 more violations)
Data1<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV")) 
Data2<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/100001:200000/CSV")) 
Data3<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/200001:300000/CSV")) 
Data4<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/300001:400000/CSV")) 
Data5<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/400001:450000/CSV"))
Data6<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/450001:500000/CSV"))
Data7<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/500001:600000/CSV")) 
Data8<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/600001:700000/CSV")) 
Data9<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/700001:800000/CSV")) 
Data10<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/800001:900000/CSV")) 
Data11<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/900001:1000000/CSV")) 
Data12<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1000001:1100000/CSV")) 
Data13<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1100001:1200000/CSV")) 
Data14<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1200001:1300000/CSV")) 
Data15<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1300001:1400000/CSV")) 
Data16<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1400001:1500000/CSV")) 
Data17<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1500001:1600000/CSV")) 
Data18<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1600001:1700000/CSV")) 
Data19<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1700001:1800000/CSV")) 
Data20<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1800001:1900000/CSV")) 
Data21<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1900001:2000000/CSV")) 
Data22<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2000001:2100000/CSV")) 
Data23<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2100001:2200000/CSV")) 
Data24<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2200001:2300000/CSV")) 
Data25<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2300001:2400000/CSV"))
Data26<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2500001:2600000/CSV"))
Data27<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2600001:2700000/CSV"))
Data28<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2700001:2800000/CSV"))
Data29<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2800001:2900000/CSV"))
Data30<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2900001:3000000/CSV"))
# keep adding Data# to call new data until no obs left 

DataMerged_meta <- do.call("rbind", list(Data1,Data2,Data3,Data4,Data5,Data6,Data7,Data8,Data9,Data10,
Data11,Data12,Data13,Data14,Data15,Data16,Data17,Data18,Data19,Data20,Data21,Data22,Data23,Data24,Data25,Data26,Data27,Data28,Data29,Data30))
#View(DataMerged)
#names(DataMerged)
filename <- paste0("data/sdwis_violation/raw/AllViolationData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
write_csv(DataMerged_meta, file = filename) # save into folder called raw for raw data



# Clean data (example) ----------------------------------------------------

#### Read raw violation data ####
raw_data <- read_csv("data/sdwis_violation/raw/AllViolationData_EPA_EnvirofactsAPI_031725.csv")  #2676752 obs

# add new column for violation begin month, quarter, year_quarter
data_all <- raw_data %>% 
  mutate(year = year(compl_per_begin_date),
         month = month(compl_per_begin_date),
         quarter = quarter(compl_per_begin_date),
         year_quarter = paste(year, ' Q', quarter, sep=""))

View(data_all)
glimpse(data_all)

filename <- paste0("data/sdwis_violation/cleaned/AllViolationData_EPA_EnvirofactsAPI_cleaned_", format(Sys.Date(), "%m%d%y"), ".csv")
write_csv(data_all, file = filename) # save into folder called raw for raw data


#### Filtering data (example) ####
colnames(data_all)
# Typical filter by columns include:
## contaminant_code <- by contaminant
## violation_code, violation_category_code <--- by violation category e.g., MCL, TT, ...
## is_health_based_ind, is_major_viol_ind <--- by health
## rule_code, rule_group_code, rule_family_code <--- by violation rule

# Active Community Water Systems (CWS) only
# Arsenic: 
Arsenic <- filter(data_all, contaminant_code == "1005" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Arsenic, file = paste0("Arsenic_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Fluoride: 
Fluoride <- filter(data_all, contaminant_code == "1025" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Fluoride, file = paste0("Fluoride_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Lead:
Lead <- filter(data_all, contaminant_code == "1030" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Lead, file = paste0("Lead_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Manganese:
Manganese<- filter(data_all, contaminant_code == "1032" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Manganese, file = paste0("Manganese_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Asbestos:
Asbestos <- filter(data_all, contaminant_code == "1094" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Asbestos, file = paste0("Asbestos_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Dichloromethane:
Dichloromethane <- filter(data_all, contaminant_code == "2964" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Dichloromethane, file = paste0("Dichloromethane_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Uranium:
Uranium <- filter(data_all, contaminant_code == "4006" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Uranium, file = paste0("Uranium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# HAA5:
HAA5 <- filter(data_all, contaminant_code == "2456" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)
write_csv(HAA5, file = paste0("HAA5_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Nitrate
Nitrate <- filter(data_all, contaminant_code == "1040" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Nitrate, file = paste0("Nitrate_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Uranium (Combined)
Uranium <- filter(data_all, contaminant_code == "4006" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Uranium, file = paste0("Uranium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Mercury
Mercury <- filter(data_all, contaminant_code == "1035" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Mercury, file = paste0("Mercury_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Fluoride
Fluoride <- filter(data_all, contaminant_code == "1025" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Fluoride, file = paste0("Fluoride_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Total Chromium
Chromium <- filter(data_all, contaminant_code == "1020" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Chromium, file = paste0("Chromium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Selenium
Selenium <- filter(data_all, contaminant_code == "1045" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Selenium, file = paste0("Selenium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Cadmium 
Cadmium <- filter(data_all, contaminant_code == "1015" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Cadmium, file = paste0("Cadmium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Bromide
Bromide <- filter(data_all, contaminant_code == "1004" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Bromide, file = paste0("Bromide_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

#A full description of violation and contaminant codes can be accessed in the SDWA_REF_CODE_VALUES.csv of https://echo.epa.gov/files/echodownloads/SDWA_latest_downloads.zip ECHO site.
