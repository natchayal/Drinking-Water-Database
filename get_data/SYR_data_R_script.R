---
# title: "USEPA Regulation Project"
# Description: Aquatic Class - code to convert SYR .txt file to .csv
# author: Natchaya Luangphairin
# date last revised: "11/18/2024"
# output: R Script
---

# Load packages and libraries ---------------------------------------------
if (!require("pacman")) install.packages("pacman")
p_load(ggplot2, plyr,dplyr,shiny,statsr,plotly,grid,gridExtra,
       readxl,readr,ggpubr,RColorBrewer,scales,naniar,tidyr,stringr,ggpubr,
       ggthemes,janitor,binr,mltools,gtools,formattable,foreign,utils,lubridate,
       data.table,hrbrthemes,tidyverse,zoo,purr,openxlsx) 
setwd("C:/Users/nluan/Box Sync/USF PhD CEE/MS CEE/Classes/Fall 2024/Aquatic Chemistry TA/syr_occurrence_CWS")


# In R, open each .txt file in the folder "folder", naming the new dataframe as the file name. Then, filter each dataframe so that the column "SYSTEM_TYPE" equals "C". Then, save as .xlsx


# Convert downloaded SYR .txt to .csv files -------------------------------
# Function to standardize column names to uppercase with underscores
standardize_colnames <- function(df) {
  colnames(df) <- toupper(gsub(" ", "_", colnames(df)))  # Convert to uppercase and replace spaces with underscores
  return(df)
}

folder_path <- "syr3_syr4_raw"
# List all .txt files in the folder
files <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

# Read, standardize, and filter each file
dataframes <- map(files, ~ read_delim(.x, delim = "\t")) %>%
  set_names(tools::file_path_sans_ext(basename(files))) %>%
  map(standardize_colnames)  # Apply standardization to column names

# Filter based on SYSTEM_TYPE == "C"
filtered_dataframes <- map(dataframes, ~ filter(.x, SYSTEM_TYPE == "C"))

# Save as .xlsx into the same folder
for (i in seq_along(filtered_dataframes)) {
  write.xlsx(filtered_dataframes[[i]], file.path(folder_path, paste0(names(filtered_dataframes)[i], ".xlsx")))
}



# Merge multiple SYR data (e.g. SYR3 and SYR4) ----------------------------
# Function to standardize column names to uppercase with underscores
standardize_colnames <- function(df) {
  colnames(df) <- toupper(gsub(" ", "_", colnames(df)))  # Convert to uppercase and replace spaces with underscores
  return(df)
}

# Function to ensure SAMPLE_COLLECTION_DATE is in datetime format
standardize_date_column <- function(df) {
  if ("SAMPLE_COLLECTION_DATE" %in% colnames(df)) {
    df <- df %>%
      mutate(SAMPLE_COLLECTION_DATE = ymd_hms(SAMPLE_COLLECTION_DATE, quiet = TRUE) %>% 
               coalesce(ymd(SAMPLE_COLLECTION_DATE, quiet = TRUE)))  # Attempt to parse as datetime or date
  }
  return(df)
}

folder_path <- "syr3_syr4_raw"
# List all .txt files in the folder
files <- list.files(path = folder_path, pattern = "\\.txt$", full.names = TRUE)

# Read, standardize, and prepare dataframes
dataframes <- map(files, ~ read_delim(.x, delim = "\t", show_col_types = FALSE)) %>%
  set_names(tools::file_path_sans_ext(basename(files))) %>%
  map(standardize_colnames) %>%
  map(standardize_date_column)

# List of contaminants to process
contaminants <- c("arsenic", "fluoride", "lead", "asbestos", "dichloromethane", "haa5", "uranium")

# Process and save merged dataframes for each contaminant
for (contaminant in contaminants) {
  contaminant_dataframes <- dataframes[grepl(contaminant, names(dataframes), ignore.case = TRUE)]
  
  if (length(contaminant_dataframes) > 0) {
    merged_contaminant_df <- bind_rows(contaminant_dataframes, .id = "Source")
    write.xlsx(merged_contaminant_df, file.path(folder_path, paste0("syr_", contaminant, ".xlsx")))
  }
}
