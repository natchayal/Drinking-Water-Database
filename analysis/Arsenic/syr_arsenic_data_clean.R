---
# title: "Analyzing Arsenic Data"
# Description: "Arsenic Rule Review"
# author: Natchaya Luangphairin
# date last revised: "4/20/2023"
# output: R Script
---

# This code uses R to prevent having to go to a browser, like Chrome, and paste ezch URL individually to get a single CSV file that you then have to import into R and merge. To see what I mean, paste the following into Chrome to see what individual file R is assigning to each "Data" line below:
	# Example URL:
		# The CSV assigned to Data1: "https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV"

# Run each line one-by-one. Stop once you get an empty data set. You will likely encounter errors for many parts. Don't give up, come back to that set later. You should have over 2 million entries in the DataMerged file if you did this correctly.

# You must change your working directory to point to the path where this folder is saved in your laptop
setwd("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Arsenic/data/raw")
# to choose a folder interactively:
  #setwd("C://Users/nluan/")
  #setwd(choose.dir())

#######################################################################################
############################ Import Data from USEPA database ##########################
#######################################################################################
	# Import violation data by PWSID
	Data1<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV")) 
	Data2<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/100000:200000/CSV")) 
	Data3<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/200000:300000/CSV")) 
	Data4<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/300000:400000/CSV")) 
	Data5<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/400000:450000/CSV"))
	Data6<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/450000:500000/CSV"))
	Data7<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/500000:600000/CSV")) 
	Data8<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/600000:700000/CSV")) 
	Data9<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/700000:800000/CSV")) 
	Data10<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/800000:900000/CSV")) 
	Data11<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/900000:1000000/CSV")) 
	Data12<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1000000:1100000/CSV")) 
	Data13<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1100000:1200000/CSV")) 
	Data14<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1200000:1300000/CSV")) 
	Data15<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1300000:1400000/CSV")) 
	Data16<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1400000:1500000/CSV")) 
	Data17<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1500000:1600000/CSV")) 
	Data18<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1600000:1700000/CSV")) 
	Data19<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1700000:1800000/CSV")) 
	Data20<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1800000:1900000/CSV")) 
	Data21<- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1900000:2000000/CSV")) 

	DataMerged <- do.call("rbind", list(Data1,Data2,Data3,Data4,Data5,Data6,Data7,Data8,Data9,Data10,Data11,Data12,Data13,Data14,Data15,Data16,Data17,Data18,Data19,Data20,Data21))
	View(DataMerged)
	names(DataMerged)
	filename <- paste0("AllViolationData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
	write.csv(DataMerged, file = filename, row.names=FALSE)

	DataMerged <- read.csv("AllViolationData_EPA_EnvirofactsAPI_040423.csv")

	# Subset to only look at Community Water Supply (CWSs)
		DataMerged_CWS <- filter(DataMerged, PWS_TYPE_CODE == "CWS")

	# Import utility data and merge
	# SysData1<- read.csv(url("https://data.epa.gov/efservice/WATER_SYSTEM/ROWS/0:100000/CSV")) 
	# SysData2<- read.csv(url("https://data.epa.gov/efservice/WATER_SYSTEM/ROWS/100000:200000/CSV")) 
	# SysData3<- read.csv(url("https://data.epa.gov/efservice/WATER_SYSTEM/ROWS/200000:300000/CSV")) 
	# SysData4<- read.csv(url("https://data.epa.gov/efservice/WATER_SYSTEM/ROWS/300000:400000/CSV")) 
	# SysData5<- read.csv(url("https://data.epa.gov/efservice/WATER_SYSTEM/ROWS/400000:500000/CSV"))
	# SysDataMerged <- do.call("rbind", list(SysData1,SysData2,SysData3,SysData4,SysData5))
	# View(SysDataMerged)
	# names(SysDataMerged)
	# sysfilename <- paste0("water_system_detail_", format(Sys.Date(), "%m%d%y"), ".csv")
	# write.csv(SysDataMerged, file = sysfilename, row.names=FALSE)

# source: https://echo.epa.gov/tools/data-downloads#downloads    https://echo.epa.gov/tools/data-downloads/sdwa-download-summary
# scroll down to "Drinking Water Data Downloads" and download "SDWA Dataset (ZIP)"
SDWA_PUB_WATER_SYSTEMS <- read.csv("SDWA_latest_downloads/SDWA_PUB_WATER_SYSTEMS.CSV") # easier than previous method

# Add in utility data by PWSID
	# Read in the utility data file
	utility_metadata <- SDWA_PUB_WATER_SYSTEMS

	# Subset to only keep columns "PWSID","PWS_NAME","EPA_REGION","PRIMACY_AGENCY_CODE","PRIMACY_TYPE","OWNER_TYPE_CODE","PRIMARY_SOURCE_CODE","PWS_TYPE_CODE","POP_CAT_5_CODE","POP_CAT_11_CODE","POPULATION_SERVED_COUNT","ADDRESS_LINE1","ADDRESS_LINE2","CITY_NAME","STATE_CODE","ZIP_CODE","COUNTRY_CODE"
		utility_metadata <- subset(utility_metadata, select = c("PWSID","PWS_NAME","EPA_REGION","PRIMACY_AGENCY_CODE","PRIMACY_TYPE","OWNER_TYPE_CODE","PRIMARY_SOURCE_CODE","PWS_TYPE_CODE","POP_CAT_5_CODE","POP_CAT_11_CODE","POPULATION_SERVED_COUNT","ADDRESS_LINE1","ADDRESS_LINE2","CITY_NAME","STATE_CODE","ZIP_CODE","COUNTRY_CODE"))
		utility_metadata$PWSID <- paste0(utility_metadata$STATE_CODE, utility_metadata$PWSID)

# function to add state code to PWSID if necessary
add_state_code <- function(PWSID, statecode) {
  if (!grepl("[^0-9]", PWSID)) {
    paste0(statecode, PWSID)
  } else {
    PWSID
  }
}

# apply the function to the ZIP_CODE and STATE_CODE columns
#df$ZIP_CODE <- mapply(add_state_code, df$ZIP_CODE, df$STATE_CODE)
#Data Soucre: SYR
SYR2_Arsenic <- read.csv("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Arsenic/data/raw/SYR Arsenic data/SYR2_arsenic.csv") 
SYR2_Arsenic <- subset(SYR2_Arsenic, select = c("PWSID","STATE","PWSNAME","PWSTYPE","POPULATION","SRCWATER","DATE","VALUE"))
names(SYR2_Arsenic) <- c("PWSID","STATE","PWS_NAME","PWS_TYPE_CODE","POPULATION_SERVED_COUNT","PRIMARY_SOURCE_CODE","SAMPLE_COLLECTION_DATE","ARSENIC_MG_L")
SYR2_Arsenic$SAMPLE_COLLECTION_DATE <- as.Date(SYR2_Arsenic$SAMPLE_COLLECTION_DATE, format = "%m/%d/%Y")
SYR2_Arsenic$PWSID <- mapply(add_state_code, SYR2_Arsenic$PWSID, SYR2_Arsenic$STATE)

SYR3_Arsenic <- read.csv("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Spring 2023 Class/GIS4043 GIS/GIS Project/SYR Arsenic data/SYR3_arsenic.csv") 
SYR3_Arsenic <- subset(SYR3_Arsenic, select = c("PWSID","State.Code","System.Name","System.Type","Adjusted.Total.Population.Served","Source.Water.Type","Sample.Collection.Date","Value"))
names(SYR3_Arsenic) <- c("PWSID","STATE","PWS_NAME","PWS_TYPE_CODE","POPULATION_SERVED_COUNT","PRIMARY_SOURCE_CODE","SAMPLE_COLLECTION_DATE","ARSENIC_MG_L")
SYR3_Arsenic$SAMPLE_COLLECTION_DATE <- as.POSIXct(SYR3_Arsenic$SAMPLE_COLLECTION_DATE, format = "%Y-%m-%d %H:%M:%S")
SYR3_Arsenic$PWSID <- mapply(add_state_code, SYR3_Arsenic$PWSID, SYR3_Arsenic$STATE)

SYR_DataMerged <- do.call("rbind", list(SYR2_Arsenic, SYR3_Arsenic))

utility_metadata_select <- subset(utility_metadata, select = c("PWSID","EPA_REGION","PRIMACY_AGENCY_CODE","PRIMACY_TYPE","OWNER_TYPE_CODE","POP_CAT_5_CODE","POP_CAT_11_CODE","ADDRESS_LINE1","ADDRESS_LINE2","CITY_NAME","ZIP_CODE","COUNTRY_CODE"))


# Merge with DataMerged_CWS
DataMerged_meta <- merge(SYR_DataMerged, utility_metadata_select, by = "PWSID")


	library(tidyr)
	DataMerged_meta$SYSTEM_SIZE <- cut(DataMerged_meta$POP_CAT_5_CODE, 
	                                   breaks = c(0, 1, 2, 3, 4, 5),
	                                   labels = c("<=500", "501-3,300", "3,301-10,000", 
	                                              "10,001-100,000", ">100,000"), 
	                                   include.lowest = TRUE)

	DataMerged_meta$SYSTEM_SIZE_INFO <- cut(DataMerged_meta$POP_CAT_5_CODE, 
                                   breaks = c(0, 1, 2, 3, 4, 5),
                                   labels = c("Very Small: <=500", "Small: 501-3,300", "Medium: 3,301-10,000", 
                                              "Large: 10,001-100,000", "Very Large: >100,000"), 
                                   include.lowest = TRUE)

# Convert ZIPCODE to COUNTY
#install.packages("fipscounty")
#library(fipscounty)
# Remove rows where ZIP_CODE column is blank
DataMerged_meta <- DataMerged_meta[!is.na(DataMerged_meta$ZIP_CODE) & DataMerged_meta$ZIP_CODE != "", ]
# Extract first 5 characters of ZIP_CODE column
DataMerged_meta$ZIP_CODE <- substr(DataMerged_meta$ZIP_CODE, 1, 5)

#DataMerged_meta$COUNTY <- zip_county(DataMerged_meta$ZIP_CODE)

	write.csv(DataMerged_meta, "C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Arsenic/data/raw/SYR Arsenic data/SYRmerged_arsenic.csv")

DataMerged_meta <- read.csv("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Arsenic/data/raw/SYR Arsenic data/SYRmerged_arsenic.csv")

# Stacked bar chart
library(dplyr)

DataMerged_meta$YEAR <- substr(DataMerged_meta$SAMPLE_COLLECTION_DATE, 1, 4)
DataMerged_meta$COUNT <- 1
arsenic_data_filtered <- DataMerged_meta %>%
  filter(PWS_TYPE_CODE == "C", ARSENIC_MG_L > 0.01, YEAR >= 1998, YEAR <= 2023)

  arsenic_data_grouped <- arsenic_data_filtered %>%
  group_by(SYSTEM_SIZE_INFO, YEAR) %>%
  summarize(total_violations = sum(COUNT))

  library(ggplot2)
DataMerged_meta$YEAR<- as.factor(DataMerged_meta$YEAR)
ggplot(arsenic_data_grouped, aes(x = YEAR, y = total_violations, fill = SYSTEM_SIZE_INFO)) +
  geom_bar(stat = "identity") +
  labs(title = "Arsenic Violations by Population Serving Size Category and Year (1998-2011)",
       subtitle = "Data source: 6YR2-6YR3 Statewide Arsenic MCL Violations in Community Water Systems",
       x = "Year",
       y = "# Systems in Violation",
       fill = "Population Serving Size Category") +
  scale_fill_manual(values = c("#2c7bb6", "#abdda4", "#fdae61", "#d7191c", "#2b83ba"))  +
  theme_minimal() 



# concentration plot

library(dplyr)
library(ggplot2)

# Read in the data
DataMerged_meta <- read.csv("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Arsenic/data/raw/SYR Arsenic data/SYRmerged_arsenic.csv")
# Filter the data and create a new variable for year
arsenic_data_filtered <- DataMerged_meta %>%
  filter(PWS_TYPE_CODE == "C") %>% # all
  #filter(PWS_TYPE_CODE == "C", ARSENIC_MG_L > 0.01) %>% # just violating
  mutate(YEAR = substr(SAMPLE_COLLECTION_DATE, 1, 4))


# Create the plot
# Reorder the levels of SYSTEM_SIZE_INFO
arsenic_data_filtered$SYSTEM_SIZE_INFO <- factor(arsenic_data_filtered$SYSTEM_SIZE_INFO,
                                                 levels = c("Very Large: >100,000", "Large: 10,001-100,000", "Medium: 3,301-10,000", "Small: 501-3,300", "Very Small: <=500"))

# Create the plot with updated size scaling
ggplot(arsenic_data_filtered, aes(x = YEAR, y = ARSENIC_MG_L)) +
  geom_point(aes(size = SYSTEM_SIZE_INFO), alpha = ifelse(arsenic_data_filtered$POP_CAT_5_CODE > 2, 0.07, 0.1)) +
  geom_hline(aes(yintercept = 0.01, linetype = "Arsenic MCL = 0.01 mg/L")) +
  labs(title = "Arsenic Concentrations by System Size and Year (1998-2011)",
  		 subtitle = "Data source: 6YR2-6YR3 Statewide Arsenic Concentrations in Community Water Systems",
       x = "Year",
       y = "Arsenic Concentration (mg/L)",
       size = "System Size", 
       linetype = "") +
  theme_minimal() +
  scale_size_manual(values = c(7, 5, 3, 2, 1)) +
  ylim(0, 0.05) +
  scale_linetype_manual(name = "Violation Line",
                        values = c("dashed"),
                        labels = c("Arsenic MCL = 0.01 mg/L"))

# For just violating (change filter above)

# Create the plot with updated size scaling
ggplot(arsenic_data_filtered, aes(x = YEAR, y = ARSENIC_MG_L)) +
  geom_point(aes(size = SYSTEM_SIZE_INFO), alpha = ifelse(arsenic_data_filtered$POP_CAT_5_CODE > 2, 0.07, 0.1)) +
  geom_hline(aes(yintercept = 0.01, linetype = "Arsenic MCL = 0.01 mg/L")) +
  labs(title = "Arsenic Concentrations by System Size and Year (1998-2011)",
  		 subtitle = "Data source: 6YR2-6YR3 Statewide Arsenic MCL Violations in Community Water Systems",
       x = "Year",
       y = "Arsenic Concentration (mg/L)",
       size = "System Size", 
       linetype = "") +
  theme_minimal() +
  scale_size_manual(values = c(7, 5, 3, 2, 1)) +
  ylim(0, 0.05) +
  scale_linetype_manual(name = "Violation Line",
                        values = c("dashed"),
                        labels = c("Arsenic MCL = 0.01 mg/L"))






# Data Source: SDWIS VIOLATION


violation <- read.csv ("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Arsenic/data/raw/arsenic1005_violation_data_all_040523.csv")
violation  <- rename(violation, SYSTEM_SIZE = system_size) 
violation  <- rename(violation, SYSTEM_SIZE_INFO = system_size_info) 
violation$COMPL_PER_BEGIN_DATE <- as.Date(violation$COMPL_PER_BEGIN_DATE, format = "%d-%b-%y")

# Stacked bar chart
library(dplyr)

	violation$SYSTEM_SIZE_INFO <- cut(violation$POP_CAT_5_CODE, 
                                   breaks = c(0, 1, 2, 3, 4, 5),
                                   labels = c("Very Small: <=500", "Small: 501-3,300", "Medium: 3,301-10,000", 
                                              "Large: 10,001-100,000", "Very Large: >100,000"), 
                                   include.lowest = TRUE)

	# Reorder the levels of SYSTEM_SIZE_INFO
violation$SYSTEM_SIZE_INFO <- factor(violation$SYSTEM_SIZE_INFO,
                                     levels = c("Very Large: >100,000", "Large: 10,001-100,000", "Medium: 3,301-10,000", "Small: 501-3,300", "Very Small: <=500"))

violation$YEAR <- substr(violation$COMPL_PER_BEGIN_DATE, 1, 4)
violation$COUNT <- 1
arsenic_data_filtered <- violation %>%
  filter(PWS_TYPE_CODE == "CWS", VIOLATION_CATEGORY_CODE == "MCL",YEAR >= 1998, YEAR <= 2023)

  arsenic_data_grouped <- arsenic_data_filtered %>%
  group_by(SYSTEM_SIZE_INFO, YEAR) %>%
  summarize(total_violations = sum(COUNT))

  library(ggplot2)

ggplot(arsenic_data_grouped, aes(x = YEAR, y = total_violations, fill = SYSTEM_SIZE_INFO)) +
  geom_bar(stat = "identity") +
  labs(title = "Arsenic Violations by Population Serving Size Category and Year (1998-2022)",
       subtitle = "Data source: SDWIS Statewide Arsenic MCL Violations in Community Water Systems",
       x = "Year",
       y = "# Systems in Violation",
       fill = "Population Serving Size Category") +
  scale_fill_manual(values = c("#2b83ba", "#abdda4", "#ffffbf", "#fdae61", "#d7191c")) +
  scale_y_continuous(breaks = seq(0, 1500, by = 250)) +
  theme_minimal()





## ODDS RATIO ##
 # Using R, merge the dataframe x = "20221209_CENSUS2020_UCMR3_PWS_FINAL_DATA" with the dataframe y = "SVI2020_US_COUNTY", keeping all columns from both dataframes. Merge them based on matching 2 columns as follows: "State.x" = "ST_ABBR" and "PCounty" = "COUNTY".

     x <- read.csv("C:/Users/andre/Box/AndrewUSF/USF/Manuscripts/RegDet_Social_Justice/DECENNIALPL2020.P1_2022-12-08T110444/20221209_CENSUS2020_UCMR3_PWS_FINAL_DATA.csv")
     y <- read.csv("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Arsenic/data/raw/SVI2020_US_COUNTY.csv")

     colnames(y)[colnames(y) == "ST_ABBR"] <- "State.x"
     colnames(y)[colnames(y) == "COUNTY"] <- "PCounty"

     count_majority_minority <- ifelse(is.na(y$E_MINRTY / y$E_TOTPOP), NA, ifelse(y$E_MINRTY / y$E_TOTPOP > 0.5, TRUE, FALSE))
     sum(count_majority_minority, na.rm = TRUE) # 388 counties have a population where the majority is a minority

     merged_data <- merge(x, y, by = c("State.x", "PCounty"), all = TRUE)


     # Divided the estimated minority population column by the estimated population column from the CDC database, and put this in a new TRUE/FALSE column for majority minority
     merged_data$majority_minority <- ifelse(is.na(merged_data$E_MINRTY / merged_data$E_TOTPOP), "NA", ifelse(merged_data$E_MINRTY / merged_data$E_TOTPOP > 0.5, "TRUE", "FALSE"))

     # Calculate the odds ratio to answer "Is a majority-minority county more likely to have a detection of any one of the reg det contaminants?"
          # Define the response variable (dependent variable) and the explanatory variables (independent variables)
          response_expl_variables <- subset(merged_data, select = c("detect", "majority_minority"))
          # Remove rows in the merged_data dataframe that have an NA in the "detect" or "majority_minority" columns, and print how many rows were removed from the dataframe
          response_expl_variables$majority_minority <- as.logical(response_expl_variables$majority_minority)
          cleaned_data <- response_expl_variables %>% filter(!is.na(majority_minority))
          num_removed <- nrow(response_expl_variables) - nrow(cleaned_data)
          print(paste(num_removed, "rows removed")) # 30 rows removed out of original 129,993 rows

          # Use glm to perform a logistic regression of the binomial family, between response_variable and Explanatory_variable
          logistic_regression_model <- glm(detect ~ majority_minority, family = binomial(link = "logit"), data = cleaned_data)
          summary(logistic_regression_model)
          CDC_maj_minor_all <- as.data.frame(odds.ratio(logistic_regression_model))
          # Copy the output onto the clipboard so I can paste into excel sheet
          clipr::write_clip(CDC_maj_minor_all)
          odds.ratio(logistic_regression_model)
