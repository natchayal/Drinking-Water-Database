---
# title: "USEPA Regulation Project"
# Description: Aquatic Class - code to get SDWIS Violation data as .csv using API
# author: Natchaya Luangphairin
# date last revised: "11/18/2024"
# output: R Script
---
  
# Install packages and load libraries -------------------------------------

#install.packages("pacman")
library(pacman)
p_load(ggplot2, plyr,dplyr,shiny,statsr,plotly,grid,gridExtra,
       readxl,readr,ggpubr,RColorBrewer,scales,naniar,tidyr,stringr,ggpubr,
       ggthemes,janitor,binr,mltools,gtools,formattable,foreign,utils,lubridate,
       data.table,hrbrthemes,tidyverse,zoo) 
setwd("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Classes/Fall 2024/Aquatic Chemistry TA/sdwis_violation_CWS")

# Import data -------------------------------------------------------------

# This code uses R to prevent having to go to a browser, like Chrome, and paste ezch URL individually to get a single CSV file that you then have to import into R and merge. To see what I mean, paste the following into Chrome to see what individual file R is assigning to each "Data" line below:
  # Example URL:
    # The CSV assigned to Data1: "https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV"

# Run each line one-by-one. Stop once you get an empty data set. You will likely encounter errors for many parts. Don't give up, come back to that set later. You should have over 2 million entries in the DataMerged file if you did this correctly.

# Import violation data by PWSID (each year there's ~220,000 more violations)
Data1<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV")) 
Data2<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/100000:200000/CSV")) 
Data3<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/200000:300000/CSV")) 
Data4<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/300000:400000/CSV")) 
Data5<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/400000:450000/CSV"))
Data6<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/450000:500000/CSV"))
Data7<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/500000:600000/CSV")) 
Data8<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/600000:700000/CSV")) 
Data9<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/700000:800000/CSV")) 
Data10<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/800000:900000/CSV")) 
Data11<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/900000:1000000/CSV")) 
Data12<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1000000:1100000/CSV")) 
Data13<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1100000:1200000/CSV")) 
Data14<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1200000:1300000/CSV")) 
Data15<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1300000:1400000/CSV")) 
Data16<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1400000:1500000/CSV")) 
Data17<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1500000:1600000/CSV")) 
Data18<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1600000:1700000/CSV")) 
Data19<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1700000:1800000/CSV")) 
Data20<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1800000:1900000/CSV")) 
Data21<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1900000:2000000/CSV")) 
Data22<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2000000:2100000/CSV")) 
Data23<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2100000:2200000/CSV")) 
Data24<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2200000:2300000/CSV")) 
Data25<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2300000:2400000/CSV"))
Data26<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2500000:2600000/CSV"))
Data27<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2600000:2700000/CSV"))
Data28<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2700000:2800000/CSV"))
Data29<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2800000:2900000/CSV"))
Data30<- read_csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/2900000:3000000/CSV"))


DataMerged_meta <- do.call("rbind", list(Data1,Data2,Data3,Data4,Data5,Data6,Data7,Data8,Data9,Data10,
Data11,Data12,Data13,Data14,Data15,Data16,Data17,Data18,Data19,Data20,Data21,Data22,Data23,Data24,Data25,Data26,Data27,Data28,Data29,Data30))
#View(DataMerged)
#names(DataMerged)
filename <- paste0("AllViolationData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
#write_csv(DataMerged_meta, file = filename)


# Filter data ---------------------------------------------------------------
#### Read raw violation data ####
data <- read_csv("AllViolationData_EPA_EnvirofactsAPI_111824.csv")  #2702442 obs

data_all <- data %>% 
  mutate(violation_year = year(compl_per_begin_date),
         quarter = quarter(compl_per_begin_date),
         year_quarter = paste(violation_year, ' Q', quarter, sep=""))


# ASSIGNED CONTAMINANTS Fall 2024 -----------------------------------------
# Active Community Water Systems (CWS) only
# Arsenic: Manish
Arsenic <- filter(data_all, contaminant_code == "1005" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Arsenic, file = paste0("Arsenic_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Fluoride: Camille
Fluoride <- filter(data_all, contaminant_code == "1025" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Fluoride, file = paste0("Fluoride_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Lead: Max
Lead <- filter(data_all, contaminant_code == "1030" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Lead, file = paste0("Lead_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Manganese
Manganese<- filter(data_all, contaminant_code == "1032" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Manganese, file = paste0("Manganese_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Asbestos: Andrew
Asbestos <- filter(data_all, contaminant_code == "1094" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Asbestos, file = paste0("Asbestos_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Dichloromethane: Tione
Dichloromethane <- filter(data_all, contaminant_code == "2964" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Dichloromethane, file = paste0("Dichloromethane_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# Uranium: Elissa
Uranium <- filter(data_all, contaminant_code == "4006" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Uranium, file = paste0("Uranium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

# HAA5: Jordin
HAA5 <- filter(data_all, contaminant_code == "2456" & pws_type_code == "CWS" & pws_activity_code == "A" & violation_year >= 2006 & violation_year <= 2024)

write_csv(HAA5, file = paste0("HAA5_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))







# ASSIGNED CONTAMINANTS Spring 2024 ---------------------------------------

# Kwabena: Nitrate
Nitrate <- filter(data_all, contaminant_code == "1040" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Nitrate, file = paste0("Nitrate_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

#Uzoma: Uranium (Combined)
Uranium <- filter(data_all, contaminant_code == "4006" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Uranium, file = paste0("Uranium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

#Oscar: Mercury
Mercury <- filter(data_all, contaminant_code == "1035" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Mercury, file = paste0("Mercury_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

#Nimisha: Fluoride
Fluoride <- filter(data_all, contaminant_code == "1025" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Fluoride, file = paste0("Fluoride_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

#Kaylie Total Chromium
Chromium <- filter(data_all, contaminant_code == "1020" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Chromium, file = paste0("Chromium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

#Kowshik: Selenium
Selenium <- filter(data_all, contaminant_code == "1045" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Selenium, file = paste0("Selenium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))

#Maedeh: Cadmium 
Cadmium <- filter(data_all, contaminant_code == "1015" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)

write_csv(Cadmium, file = paste0("Cadmium_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))


#A full description of violation and contaminant codes can be accessed in the SDWA_REF_CODE_VALUES.csv of https://echo.epa.gov/files/echodownloads/SDWA_latest_downloads.zip ECHO site.


#For In-class example
# Arsenic
Arsenic <- filter(data_all, contaminant_code == "1005" & pws_type_code == "CWS" & violation_year >= 2014 & violation_year <= 2024)
write_csv(Arsenic, file = paste0("Arsenic_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))
# Strontium
Bromide <- filter(data_all, contaminant_code == "1004" & pws_type_code == "CWS" & violation_year >= 2006 & violation_year <= 2024)
write_csv(Strontium, file = paste0("Bromide_violations_", format(Sys.Date(), "%m%d%y"), ".csv"))
