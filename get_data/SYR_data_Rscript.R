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
## In R, open each .txt file in the folder "folder", naming the new dataframe as the file name. 
## Then, filter each dataframe so that the column "SYSTEM_TYPE" equals "C". Then, save as .xlsx


# Convert downloaded SYR .txt to .csv files -------------------------------
# Function to standardize column names to uppercase with underscores
standardize_colnames <- function(df) {
  colnames(df) <- toupper(gsub(" ", "_", colnames(df)))  # Convert to uppercase and replace spaces with underscores
  return(df)
}

folder_read_path <- "data/six_year_review/raw" # path to read the downloaded data
folder_save_path <- "data/six_year_review/cleaned" # path to read the downloaded data


# List all .txt files in the folder
files <- list.files(path = folder_read_path, pattern = "\\.txt$", full.names = TRUE)

# Read, standardize, and filter each file
dataframes <- map(files, ~ read_delim(.x, delim = "\t")) %>%
  set_names(tools::file_path_sans_ext(basename(files))) %>%
  map(standardize_colnames)  # Apply standardization to column names

# Filter based on SYSTEM_TYPE == "C"
#filtered_dataframes <- map(dataframes, ~ filter(.x, SYSTEM_TYPE == "C"))
filtered_dataframes <- dataframes

# Save as .xlsx into the same folder
for (i in seq_along(filtered_dataframes)) {
  write_csv(filtered_dataframes[[i]], file.path(folder_read_path, paste0(names(filtered_dataframes)[i], ".xlsx")))
}

# Once all .txt files have been converted to .xlsx, continue with code below to merge multiple SYR files

# Merge multiple SYR data (e.g. SYR2, SYR3, SYR4, ...) ----------------------------
# Function to standardize column names to uppercase with underscores
standardize_date_column <- function(df) {
  if ("SAMPLE_COLLECTION_DATE" %in% colnames(df)) {
    df <- df %>%
      mutate(
        SAMPLE_COLLECTION_DATE = parse_date_time(
          SAMPLE_COLLECTION_DATE,
          orders = c(
            "ymd HMS", "mdy HMS", "dmy HMS",  # Datetime with min, sec
            "ymd HM", "mdy HM", "dmy HM",     # Datetime with min
            "ymd", "mdy", "dmy",              # Date without time
            "d-b-y",                          # Format for 26-JUN-12
            "d-B-y"                           # Format for 26-June-12
          ),
          quiet = TRUE
        ) %>%
          as.Date()  # Convert to Date format in ymd
      )
  }
  return(df)
}


# List all .xlsx files in the folder
xlsx_files <- list.files(path = folder_save_path, pattern = "\\.xlsx$", full.names = TRUE)
files <- xlsx_files[!grepl("^~\\$", basename(xlsx_files))]  # Exclude files starting with ~$ which are temporary files

# Read, standardize, and prepare dataframes
dataframes <- map(files, ~ read_excel(.x)) %>%
  set_names(tools::file_path_sans_ext(basename(files))) %>%
  map(standardize_colnames) %>%
  map(standardize_date_column)


# Ensure all columns are character except 'VALUE' and 'DATE'
dataframes <- map(dataframes, function(df) {
  df <- df %>% mutate(across(-c(VALUE, SAMPLE_COLLECTION_DATE), as.character))
  df$VALUE <- as.numeric(df$VALUE)
  df
})


# Apply the date standardization function to all dataframes
#dataframes_new <- map(dataframes, standardize_date_column)
dataframes_new <- dataframes

# List of contaminants to process -----------------------------------------
contaminants <- c("arsenic")  # Add or modify contaminants as needed

# Process and save merged dataframes for each contaminant
for (contaminant in contaminants) {
  # Filter relevant dataframes for the contaminant
  contaminant_dataframes <- dataframes_new[grepl(contaminant, names(dataframes_new), ignore.case = TRUE)]
  
  if (length(contaminant_dataframes) > 0) {
    # Merge all dataframes for the contaminant
    merged_contaminant_df <- bind_rows(contaminant_dataframes, .id = "ORIGINAL_FILE")  # track the source file: original file name from download
    
    # Add DATA_SOURCE column to indicate which SYR data is from, based on the SAMPLE_COLLECTION_DATE year
    merged_contaminant_df <- merged_contaminant_df %>%
      mutate(
        YEAR = year(SAMPLE_COLLECTION_DATE),  # Extract the year from SAMPLE_COLLECTION_DATE
        MONTH = month(SAMPLE_COLLECTION_DATE),
        QUARTER = quarter(SAMPLE_COLLECTION_DATE),
        YEAR_QUARTER = paste(YEAR, ' Q', QUARTER, sep=""),
        DATA_SOURCE = case_when(
          YEAR >= 2012 & YEAR <= 2019 ~ "SYR4",
          YEAR >= 2006 & YEAR <= 2011 ~ "SYR3",
          YEAR >= 1998 & YEAR <= 2005 ~ "SYR2",
          YEAR < 1998 ~ "SYR1",
          TRUE ~ NA_character_  # Default to NA if no match
        )
      )
    
    
    # Save the resulting dataframe as a CSV
    write_csv(merged_contaminant_df, file.path(folder_save_path, paste0("syr_combined_", contaminant, ".csv")))
  }
}



# Read csv to check -------------------------------------------------------
arsenic <- read_csv("data/six_year_review/cleaned/syr_combined_arsenic.csv")
