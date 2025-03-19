#######################################################
# title: "USEPA Six Year Review Data"
# Description: Code to convert SYR .txt file to .csv
# author: Natchaya Luangphairin
# date last revised: "3/17/2025"
# output: R Script
#######################################################

# Load packages and libraries ---------------------------------------------
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, readxl, purrr, tools, lubridate, writexl) 
setwd("C:/Users/nluan/OneDrive/Documents/GitHub/Drinking-Water-Database")


# Download the SYR files from https://www.epa.gov/dwsixyearreview and put them all in one folder. 
# Note: syr2 and older must be converted and save from Microsoft Access to Excel
# Summary of what the below code will do: 
## In R, open the .xlsx file saved from Microsoft Access (SYR2) and standardize the columns to match current column names.
## Then, open each .txt file in the folder "folder", naming the new dataframe as the file name and save as .xlsx. 
## Then, combine all the .xlsx files and save into the 'data/six_year_review/cleaned' folder


# Convert downloaded SYR .txt to .csv files -------------------------------
# Function to standardize column names to uppercase with underscores
# Define paths
folder_read_path <- "data/six_year_review/raw"
folder_save_path <- "data/six_year_review/cleaned"

# Function to standardize column names
standardize_colnames <- function(df) {
  colnames(df) <- toupper(gsub("[^A-Za-z0-9]+", "_", colnames(df)))  # Uppercase, replace non-alphanumeric with "_"
  return(df)
}

# Function to standardize date columns
standardize_date_column <- function(df) {
  if ("SAMPLE_COLLECTION_DATE" %in% colnames(df)) {
    df <- df %>%
      mutate(
        SAMPLE_COLLECTION_DATE = parse_date_time(
          SAMPLE_COLLECTION_DATE,
          orders = c("ymd HMS", "mdy HMS", "dmy HMS", "ymd HM", "mdy HM", "dmy HM",
                     "ymd", "mdy", "dmy", "d-b-y", "d-B-y", "d/b/y", "d/B/y"),
          quiet = TRUE
        ) %>%
          as.Date()
      )
  }
  return(df)
}


# ---- 0. Standardize SYR2 Columns to match current SYR .XLSX ---- #

# List all .xlsx files that match the "*_Chem[Number]" pattern
xlsx_files <- list.files(path = folder_read_path, pattern = "_Chem\\d+\\.xlsx$", full.names = TRUE)

# Function to standardize and add missing columns
standardize_file <- function(file_path) {
  # Read the file
  df <- read_excel(file_path)
  
  # Extract the analyte name from the filename (everything before "_Chem")
  analyte_name <- str_extract(basename(file_path), "^[^_]+") %>% toupper()
  
  # Rename existing columns
  col_rename <- c(
    "ANALYTE_ID" = "CHEMID",
    "STATE_CODE" = "STATE",
    "PWSID" = "PWSID",
    "SYSTEM_NAME" = "PWSNAME",
    "SYSTEM_TYPE" = "PWSTYPE",
    "RETAIL_POPULATION_SERVED" = "POPULATION",
    "SOURCE_WATER_TYPE" = "SRCWATER",
    "WATER_FACILITY_ID" = "ID",
    "SAMPLING_POINT_ID" = "SAMPLEPOINTID",
    "SAMPLE_ID" = "SAMPLEID",
    "SAMPLE_COLLECTION_DATE" = "DATE",
    "DETECT" = "DETECT",
    "VALUE" = "VALUE",
    "UNITS" = "UNIT"
  )
  
  df <- df %>% rename(any_of(col_rename))
  
  # Add missing columns with default values
  df <- df %>%
    mutate(
      ANALYTE_NAME = analyte_name,  # Assign analyte name from filename
      ADJUSTED_TOTAL_POPULATION_SERVED = RETAIL_POPULATION_SERVED,
      WATER_FACILITY_TYPE = NA,
      SAMPLING_POINT_TYPE = NA,
      SOURCE_TYPE_CODE = NA,
      SAMPLE_TYPE_CODE = NA,
      LABORATORY_ASSIGNED_ID = NA,
      SIX_YEAR_ID = NA,
      DETECTION_LIMIT_UNIT = NA,
      DETECTION_LIMIT_CODE = NA,
      PRESENCE_INDICATOR_CODE = NA,
      RESIDUAL_FIELD_FREE_CHLORINE_MG_L = NA,
      RESIDUAL_FIELD_TOTAL_CHLORINE_MG_L = NA
    )
  
  # Define the expected column order
  desired_colnames <- c(
    "ANALYTE_ID", "ANALYTE_NAME", "STATE_CODE", "PWSID", "SYSTEM_NAME", "SYSTEM_TYPE",
    "RETAIL_POPULATION_SERVED", "ADJUSTED_TOTAL_POPULATION_SERVED",
    "SOURCE_WATER_TYPE", "WATER_FACILITY_ID", "WATER_FACILITY_TYPE",
    "SAMPLING_POINT_ID", "SAMPLING_POINT_TYPE", "SOURCE_TYPE_CODE",
    "SAMPLE_TYPE_CODE", "LABORATORY_ASSIGNED_ID", "SIX_YEAR_ID",
    "SAMPLE_ID", "SAMPLE_COLLECTION_DATE", "DETECTION_LIMIT_VALUE",
    "DETECTION_LIMIT_UNIT", "DETECTION_LIMIT_CODE", "DETECT", "VALUE",
    "UNIT", "PRESENCE_INDICATOR_CODE", "RESIDUAL_FIELD_FREE_CHLORINE_MG_L",
    "RESIDUAL_FIELD_TOTAL_CHLORINE_MG_L"
  )
  
  # Ensure column order matches
  df <- df %>% select(any_of(desired_colnames))
  
  # Generate output file path
  output_file <- file.path(folder_save_path, paste0(tools::file_path_sans_ext(basename(file_path)), ".xlsx"))
  
  # Save the cleaned file
  write_xlsx(df, output_file)
  
  print(paste("Processed:", basename(file_path)))
}

# Process all matching files
map(xlsx_files, standardize_file)
print("All files standardized and saved!")


# ---------------- 1. Convert .TXT Files to .XLSX ---------------- #

# List all .txt files
files <- list.files(path = folder_read_path, pattern = "\\.txt$", full.names = TRUE)

# Read, standardize, and clean data
dataframes <- map(files, ~ read_delim(.x, delim = "\t")) %>%
  set_names(tools::file_path_sans_ext(basename(files))) %>%
  map(standardize_colnames)

# Save cleaned data as .xlsx
for (i in seq_along(dataframes)) {
  write_xlsx(dataframes[[i]], file.path(folder_save_path, paste0(names(dataframes)[i], ".xlsx")))
}

# ---------------- 2. Merge & Process SYR Excel Files ---------------- #

# List all .xlsx files from the cleaned folder
xlsx_files <- list.files(path = folder_save_path, pattern = "\\.xlsx$", full.names = TRUE)
files <- xlsx_files[!grepl("^~\\$", basename(xlsx_files))]

# Read, standardize, and prepare dataframes
dataframes <- map(files, ~ read_excel(.x)) %>%
  set_names(tools::file_path_sans_ext(basename(files))) %>%
  map(standardize_colnames) %>%
  map(standardize_date_column)

# Ensure all columns are character except 'VALUE' and 'SAMPLE_COLLECTION_DATE'
dataframes <- map(dataframes, function(df) {
  df <- df %>% mutate(across(-any_of(c("VALUE", "SAMPLE_COLLECTION_DATE")), as.character))
  df$VALUE <- as.numeric(df$VALUE)
  df
})

# List of contaminants to process
contaminants <- c("arsenic")  # Modify/add more contaminants as needed

# Process and save merged dataframes for each contaminant
for (contaminant in contaminants) {
  # Filter dataframes for the contaminant
  contaminant_dataframes <- dataframes[grepl(contaminant, names(dataframes), ignore.case = TRUE)]
  
  if (length(contaminant_dataframes) > 0 && all(map_lgl(contaminant_dataframes, ~ nrow(.x) > 0))) {
    # Merge all dataframes for the contaminant
    merged_contaminant_df <- bind_rows(contaminant_dataframes, .id = "ORIGINAL_FILE")  # Track the source file
    
    # Add columns for year, quarter, and SYR classification
    merged_contaminant_df <- merged_contaminant_df %>%
      mutate(
        ANALYTE_ID = ifelse(!is.na(ANALYTE_ID), ANALYTE_ID, ANALYTE_ID), 
        ANALYTE_CODE = ifelse(!is.na(ANALYTE_CODE), ANALYTE_CODE, ANALYTE_ID),  
        PRIMACY_CODE = ifelse(is.na(PRIMACY_CODE) | PRIMACY_CODE == "", substr(PWSID, 1, 2), PRIMACY_CODE),  # Fill if missing
        YEAR = year(SAMPLE_COLLECTION_DATE),
        MONTH = month(SAMPLE_COLLECTION_DATE),
        QUARTER = quarter(SAMPLE_COLLECTION_DATE),
        YEAR_QUARTER = paste(YEAR, " Q", QUARTER, sep = ""),
        DATA_SOURCE = case_when(
          YEAR >= 2012 & YEAR <= 2019 ~ "SYR4",
          YEAR >= 2006 & YEAR <= 2011 ~ "SYR3",
          YEAR >= 1998 & YEAR <= 2005 ~ "SYR2",
          YEAR < 1998 ~ "SYR1",
          TRUE ~ NA_character_
        )
      )
    
    # Save the final merged dataset
    write_csv(merged_contaminant_df, file.path(folder_save_path, paste0("syr_combined_", contaminant, ".csv")))
  }
}



# Read csv from cleaned folder to check -----------------------------------
arsenic <- read_csv("data/six_year_review/cleaned/syr_combined_arsenic.csv")
