# title: EPA Database - Treatment Information
# Description: Facility Treatment Data
# author: "Natchaya Luangphairin"
# date last revised: "10/08/2025"
# output: R Script

# Install packages and libraries ------------------------------------------
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse, readxl, purrr, tools, lubridate, writexl, zoo, ggthemes, tidycensus, sf, tigris, findSVI) 

# Data Source to cite -----------------------------------------------------
# SDWA Reference codes downloded from zip: https://echo.epa.gov/tools/data-downloads#downloads 
# Treatment using API: https://enviro.epa.gov/enviro/ef_metadata_html.ef_metadata_table?p_table_name=TREATMENT&p_topic=SDWIS
# Manual Download, link below: 1) Select "Facilities" as Report 2) "Select Columns" 3) Move all column or select columns to include in report 
# https://ordspub.epa.gov/ords/sfdw_rest/r/sfdw/sdwis_fed_reports_public/6?p6_report=FAC

## Load SDWIS Treatment data with read_csv --------------------------------
#https://enviro.epa.gov/enviro/ef_metadata_html.ef_metadata_table?p_table_name=VIOLATION&p_topic=SDWIS
treatment_data <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/CSV")) # not that many rows so calling it once works
# treatment_data2 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/1000000:1500000/CSV"))
# treatment_data3 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/1500000:2000000/CSV"))
# treatment_data4 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2000000:2100000/CSV"))
# treatment_data5 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2100000:2200000/CSV"))
# treatment_data6 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2200000:2300000/CSV"))
# treatment_data7 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2300000:2400000/CSV"))
# treatment_data8 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2400000:2500000/CSV"))
# treatment_data9 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2500000:2550000/CSV"))
# treatment_data10 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2550000:2600000/CSV"))
# treatment_data11 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2600000:2650000/CSV"))
# treatment_data12 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2650000:2700000/CSV"))
# treatment_data13 <- read_csv(url("https://data.epa.gov/efservice/TREATMENT/ROWS/2750000:2800000/CSV"))

#treatment_data <- do.call("rbind", list(treatment_data1,treatment_data2,treatment_data3,treatment_data4,treatment_data5,treatment_data6,treatment_data7,treatment_data8,treatment_data9,treatment_data10,treatment_data11,treatment_data12,treatment_data13))

filename <- paste0("data/raw/AllTreatmentData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
write_csv(treatment_data, file = filename) # must be updated every now and then


# Read csv ----------------------------------------------------------------
## PWS System info (SDWA_PUB_WATER_SYSTEMS.csv) ----------------------------
# https://echo.epa.gov/tools/data-downloads#downloads:~:text=Tanks%2C%20and%20TSCA.-,Drinking%20Water%20Data%20Downloads,-Name
# updated quarterly
sdwa_pub_water_systems <- read_csv("data/raw/SDWA_PUB_WATER_SYSTEMS.csv")
# Make all column names lowercase
names(sdwa_pub_water_systems) <- tolower(names(sdwa_pub_water_systems))

## Codes and values ref (SDWA_REF_CODE_VALUES.csv) -------------------------
# provides key to match codes used in other sdwis database such as sdwa_pub_water_systems and violation
sdwa_ref_code_values <- read_csv("data/raw/SDWA_REF_CODE_VALUES.csv")
names(sdwa_ref_code_values) <- tolower(names(sdwa_ref_code_values))
sdwa_ref_code_values$value_type <- tolower(sdwa_ref_code_values$value_type)

# Aggregating treatment data
aggregated_treatment_data <- treatment_data %>%
  group_by(pwsid) %>%
  summarise(
    treatment_objective_code = paste(unique(treatment_objective_code), collapse = ","),
    treatment_process_code = paste(unique(treatment_process_code), collapse = ",")
  )

# Joining aggregated treatment data with master data
sdwa_pub_water_systems_treatment <- sdwa_pub_water_systems %>%
  left_join(aggregated_treatment_data, by = "pwsid") %>%
  mutate(across(starts_with("pop_cat_"), as.character))

treatment_data <- read_csv("data/raw/AllTreatmentData_EPA_EnvirofactsAPI_100825.csv")
treatment_data <- treatment_data %>%
  mutate(across(everything(), as.character))

sdwa_treatment_code_to_info <- sdwa_ref_code_values %>%
  filter(value_type %in% c("treatment_objective_code", "treatment_process_code"))
  
# lookups
proc_lu <- sdwa_ref_code_values %>%
  filter(value_type == "treatment_process_code") %>%
  select(value_code, treatment_process_description = value_description)

obj_lu <- sdwa_ref_code_values %>%
  filter(value_type == "treatment_objective_code") %>%
  select(value_code, treatment_objective_description = value_description)

# join both descriptions onto your data
treatment_data_description <- treatment_data %>%
  left_join(proc_lu,  by = c("treatment_process_code"    = "value_code")) %>%
  left_join(obj_lu,   by = c("treatment_objective_code" = "value_code"))

# Aggregating treatment data
# optional: small helper
collapse_if_multi <- function(x) {
  ux <- unique(na.omit(x))
  if (length(ux) == 0) NA_character_
  else if (length(ux) == 1) ux
  else paste(sort(ux), collapse = ", ")
}

aggregated_treatment_data <- treatment_data_description %>%
  group_by(pwsid) %>%
  summarise(
    treatment_objective_code        = collapse_if_multi(treatment_objective_code),
    treatment_process_code          = collapse_if_multi(treatment_process_code),
    treatment_objective_description = collapse_if_multi(treatment_objective_description),
    treatment_process_description   = collapse_if_multi(treatment_process_description),
    .groups = "drop"
  )


filename <- paste0("data/cleaned/AllTreatmentData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
write_csv(aggregated_treatment_data, file = filename) # must be updated every now and then


########## USE THIS DATASET TO PERFORM FRTHER ANALYSIS LIKE BELOW ##########

# Analysis ----------------------------------------------------------------
# Filter ------------------------------------------------------------------
# Filter to active CWS only
active_cws <- sdwa_pub_water_systems_treatment %>%
  filter(pws_type_code == "CWS", pws_activity_code == "A") %>%
  distinct(pwsid)

n_active_cws <- nrow(active_cws)

# Count for IX ------------------------------------------------------------
# refer to SDWA reference code file. treatment_process_code 460 is code for Ion exchange
ion_exchange_pwsid <- treatment_data %>%
  filter(treatment_process_code == 460) %>%
  distinct(pwsid)

active_cws_with_ion_exchange <- active_cws %>%
  semi_join(ion_exchange_pwsid, by = "pwsid")
n_active_cws_with_ion_exchange <- nrow(active_cws_with_ion_exchange)


active_cws_with_ion_exchange_source <- active_cws_with_ion_exchange %>%
  left_join(
    sdwa_pub_water_systems_treatment %>% select(pwsid, gw_sw_code),
    by = "pwsid"
  )

# Count GW
n_gw <- active_cws_with_ion_exchange_source %>%
  filter(gw_sw_code == "GW") %>%
  nrow()
# Count SW
n_sw <- active_cws_with_ion_exchange_source %>%
  filter(gw_sw_code == "SW") %>%
  nrow()


cat("Number of active CWS systems:", n_active_cws, "\n")
cat("Number of active CWS systems with Ion Exchange:", n_active_cws_with_ion_exchange, "\n")
cat("Of the Ion Exchange systems:\n")
cat("- Groundwater (GW):", n_gw, "\n")
cat("- Surface Water (SW):", n_sw, "\n")



# Count for aluminum coagulation ------------------------------------------
aluminum_coag_pwsid <- treatment_data %>%
  filter(treatment_process_code == 999) %>%
  distinct(pwsid)

active_cws_with_aluminum_coag <- active_cws %>%
  semi_join(aluminum_coag_pwsid, by = "pwsid")

n_active_cws_with_aluminum_coag <- nrow(active_cws_with_aluminum_coag)

active_cws_with_aluminum_coag_source <- active_cws_with_aluminum_coag %>%
  left_join(
    sdwa_pub_water_systems_treatment %>% select(pwsid, gw_sw_code),
    by = "pwsid"
  )

# Count GW
n_gw_aluminum <- active_cws_with_aluminum_coag_source %>%
  filter(gw_sw_code == "GW") %>%
  nrow()
# Count SW
n_sw_aluminum <- active_cws_with_aluminum_coag_source %>%
  filter(gw_sw_code == "SW") %>%
  nrow()

cat("Number of active CWS systems:", n_active_cws, "\n")
cat("Number of active CWS systems with Aluminum Coagulation (code 999):", n_active_cws_with_aluminum_coag, "\n")
cat("Of the Aluminum Coagulation systems:\n")
cat("- Groundwater (GW):", n_gw_aluminum, "\n")
cat("- Surface Water (SW):", n_sw_aluminum, "\n")


