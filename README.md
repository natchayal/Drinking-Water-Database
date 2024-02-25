# Drinking Water Database Exploration
Analyzing drinking water standards and regulations. This git repository contains code for data acquision (see get_data subdirectory), analysis (see analysis subdirectory), and the jekyll site for this project (see docs subdirectory). 

The website for this project can be viewed here (*in progress*).

## 💧 Executive Summary 💧
I spent a lot of time exploring various drinking water database available on the internet including national, state-level, and local-level databases. I evaluated resources on the relevance of the data they provided as well as how easily the data could be accessed and downloaded, a summary of which is provided below. I also generated a number of R scripts, provided as interactive R markdown notebooks (.Rmd) files that demonstrate how some of these datasets are accessed and visualized. 

While this represents a number of useful sites, it's certainly not exhaustive. 

**Summary of datasets evaluated**

| Source          | Dataset                                                      | Ease of Access | Data Utility | Comments                                                 |
| --------------- | ------------------------------------------------------------ | :------------: | :----------: | -------------------------------------------------------- |
| EPA             | [Safe Drinking Water Information System (SDWIS)](https://www.epa.gov/enviro/web-services) |       💧💧💧💧       |     💧💧💧      | Limited Data, easy to scrape with R. <br />Can get violation data, treatment, water system detail, and purchaser-seller info.                            |                              |
| EPA             | [Enforcement & Compliance History Online (ECHO)](https://echo.epa.gov/) |      💧💧💧💧      |    💧💧💧💧💧     | Good, but so much data it's hard to know what's what     |
| EPA             | [USEPA Six Year Review](https://www.epa.gov/dwsixyearreview) |       💧💧💧💧       |     💧💧💧💧      | Data rich, easy to scrape. <br />Reports National occurence for each contaminant (not just the violations).  |
| USGS/EPA        | [Water Quality Portal](https://www.waterqualitydata.us/)     |     💧💧💧💧💧      |    💧💧💧💧💧     | Well organized & <br />comprehensive data                |
| EPA | [Unregulated Contaminant Monitoring Rule (UCMR)](https://www.epa.gov/dwucmr) |     💧💧💧💧💧      |    💧💧     | Occurrence on unregulated contaminants. <br />Reports disinfection type, residual, and treatment info.    
| EPA | [USEPA IRIS Information](https://www.epa.gov/iris) |     💧💧💧💧💧      |    💧💧     | Concentration on drinking (oral) route of exposure, not air. <br />Toxicology information, Maximum Contaminant Level (MCL) info.                        |


---

## I. National Data Sources

### A. EPA Safe Drinking Water Information System (SWDIS)

- **<u>Overview</u>**: Potential, but with obstacles; possibly redundant.
  - The data are obscurely layered across different servers.
  - Possibly redundant with ECHO. 
  - Queries must be done iteratively with R. Server is often down.

- <u>Link</u>: https://www.epa.gov/enviro/topic-searches#water 

- <u>Summary</u>: Data on violations and enforcement history since 1993 of the EPA's drinking water regulations. 

- <u>Data</u>:
  
  - Violation:
    - The data is available from here, in limited capacity: https://www.epa.gov/enviro/sdwis-search
      	* SDWIS Search by: 'Select a geographic area' or 'Enter the water system ID number' (PWSID for tribal agencies will have region code instead of state code as prefix)
      - Select data of interest and export report as a .csv file, use this link: https://ofmpub.epa.gov/apex/sfdw/f?p=108:1:0::NO:1
      - A full description of violation and contaminant codes can be accessed in the SDWA_REF_CODE_VALUES.csv of https://echo.epa.gov/files/echodownloads/SDWA_latest_downloads.zip
    
    - R script is based on the info contained here: https://www.epa.gov/enviro/web-services and https://www.epa.gov/enviro/envirofacts-data-service-api
      - Then need to scrape sub-tables.
      - If you need to define a code or other parameter in the table, this link contains all that information: https://enviro.epa.gov/enviro/ef_metadata_html.ef_metadata_table?p_table_name=VIOLATION&p_topic=SDWIS
- <u>Code examples</u> : 
```r
	Data1 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV")) 
	Data2 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/100000:200000/CSV")) 
	Data3 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/200000:300000/CSV")) 
	Data4 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/300000:400000/CSV")) 
	Data5 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/400000:500000/CSV"))
	
	DataMerged <- do.call("rbind", list(Data1,Data2,Data3,Data4,Data5))
	filename <- paste0("AllViolationData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
	write.csv(DataMerged, file = filename, row.names=FALSE)
```
  - Treatment:
    - For treatment information, this link: https://enviro.epa.gov/enviro/ef_metadata_html.ef_metadata_table?p_table_name=TREATMENT&p_topic=SDWIS

  - For other Envirofacts Data Service: API https://www.epa.gov/enviro/sdwis-model (How these files relate is described here)
    
### B. EPA Enforcement and Compliance History Online (ECHO)

- **<u>Overview</u>**: ***Promising!***
  - Established data services capabilities with documented web services
  - Holds many datasets, though so much that it's somewhat confusing what it holds:
    - Drinking Water: https://echo.epa.gov/help/facility-search/drinking-water-search-results-help
    - Water Facility: https://echo.epa.gov/tools/web-services/facility-search-water
    - The EPA/State Drinking Water Dashboard: https://echo.epa.gov/trends/comparative-maps-dashboards/drinking-water-dashboard (quick view of violation trend)

- <u>Link</u>: https://echo.epa.gov/
- <u>Summary</u>: Provides compliance and enforcement information for over 900,000 regulated facilities nationwide. Allows query at state/county/city/zip level for a table of facilities and their compliance records. Not limited to water (NPDES and drinking water); includes air, hazardous waste,...
- <u>Data</u>:
  - Main pages searches by form. Not REST interface. CSV's generated with temporary link. 	
  - Download utility meta data as ZIP file: https://echo.epa.gov/tools/data-downloads 
  - Ex. Drinking Water Data Downloads: https://echo.epa.gov/tools/data-downloads/sdwa-download-summary contains facility information from SDWIS database (includes: Events, Facility, Geograhic Area, Violations and Enforcement, and PWS address information that can be geocoded using GIS!)
  - <u>Web services</u> provided: https://echo.epa.gov/tools/web-services
    - Documentation is a bit obtuse, generates temporary result files (valid for 30 min)
- <u>Code examples</u>: None


### C. USEPA Six Year Review (SYR)

- <u>**Overview**</u>: Data rich, easy to scrape, and contains occurence and contaminant level data (not just the violations!)
  - Updated every 6 years 
  - Does not contain system information
  - Can link with SDWIS database by matching PWSID to get more system information

* <u>Link</u>: https://www.epa.gov/dwsixyearreview

* <u>Summary</u>: The Safe Drinking Water Act (SDWA) requires EPA to review each national primary drinking water regulation at least once every six years and revise them, if appropriate. As part of the "Six-Year Review," EPA evaluates any newly available data, information and technologies to determine if any regulatory revisions are needed. Revisions must maintain or strengthen public health protection.

* Data: 
  * Each zip file below contains data for multiple contaminants and related information that can be unzipped into tab delimited text files: https://www.epa.gov/dwsixyearreview
  * Data is located at the following link, and is broken down by contaminant: example for SYR3 https://www.epa.gov/dwsixyearreview/six-year-review-3-compliance-monitoring-data-2006-2011
* <u>Code examples</u>: 
```r
nitrate <- read.delim("C:/Users/nluan/Downloads/syr3_phasechem_3/nitrate.txt")
```


### D. US Water Quality Portal

- **<u>Overview</u>**: ***Most promising!*** 
  - Repository of many datasets from multiple sources (EPA, USGS).
  - Web services and file shares provide ready access to data with excellent documentation
  - Need to compare what data are provided relative to state/local data portals. 
- <u>Link</u>: https://www.waterqualitydata.us/
- <u>Summary</u>:
  The Water Quality Portal (WQP) is a cooperative service sponsored by the United States Geological Survey (USGS), the Environmental Protection Agency (EPA), and the National Water Quality Monitoring Council (NWQMC). It serves data collected by over 400 state, federal, tribal, and local agencies: https://www.waterqualitydata.us/. The data include information on sites where data are gathered, physical/chemical monitoring data, and biological sample data. Complete metadata are available here: https://www.waterqualitydata.us/portal_userguide/
- <u>Data:</u>
  - Complete web services documentation: https://www.waterqualitydata.us/webservices_documentation/
- Code examples: 
  * `USWQP/USWaterData-Scrape.Rmd` uses the WQP web service to pull station data for all sites in California (N = 336801). 
  * `USWQP/USWaterData-Explore.Rmd` provides and example for ingesting and visualizing the US Water Quality Portal data scraped for California. 


### F. Unregulated Contaminant Monitoring Rule (UCMR)

- **<u>Overview</u>**: Only place to get data on unregulated contaminants
  - The 1996 Safe Drinking Water Act (SDWA) amendments require that once every five years EPA issue a new list of no more than 30 unregulated contaminants to be monitored by public water systems (PWSs).
  - Contains disinfectant type and treatment information useful info to match by PWSID and merge with data from SDWIS and SYR. Disinfectant Residual (e.g. Free Chlorine, Chloramine) and treatment information (e.g. GAC, Ionic exchange, etc.) only available UCMR4 onwards.

- <u>Link</u>: https://www.epa.gov/dwucmr
- <u>Summary</u>: EPA uses the Unregulated Contaminant Monitoring Rule (UCMR) to collect data for contaminants suspected to be present in drinking water, but that do not have regulatory standards set under the Safe Drinking Water Act (SDWA). The monitoring provides EPA and other interested parties with nationally representative data on the occurrence of contaminants in drinking water, the number of people potentially being exposed, and an estimate of the levels of that exposure. These data can support future regulatory determinations and other actions to protect public health.
- <u>Data</u>:
    - Occurence: https://www.epa.gov/dwucmr/occurrence-data-unregulated-contaminant-monitoring-rule
   
- <u>Code examples</u>: None


### F. USEPA IRIS Information

- **<u>Overview</u>**: Good for toxicity information
  - "What is the toxicity?"

- <u>Link</u>: https://www.epa.gov/iris
- <u>Summary</u>: IRIS assessments provide the following toxicity values for health effects resulting from chronic exposure to chemicals.
- <u>Data</u>:
    - Integrated Risk Information System: https://www.epa.gov/iris
    - National Primary Drinking Water Regulations: https://www.epa.gov/ground-water-and-drinking-water/national-primary-drinking-water-regulations
   
- <u>Code examples</u>: None


### G. Other Useful Database
- **<u>Overview</u>**: Good for Geographic & Demographic Information

- <u>Summary</u>: Information can be combined with water quality data and mapped with GIS.
    - ECHO Drinking Water Data Downloads: https://echo.epa.gov/tools/data-downloads/sdwa-download-summary contains PWS address information that can be geocoded using GIS
    - ECHO Facility Demographic: https://echo.epa.gov/tools/data-downloads/demographic-download-summary for income and census data
    - UCB: https://data.census.gov/table to explore census tables which can be downloaded
    - CDC SVI: https://www.atsdr.cdc.gov/placeandhealth/svi/index.html for social vulnerability index (SVI) 
    - CDC ENJI: https://www.atsdr.cdc.gov/placeandhealth/eji/index.html for environmental justice index (EJI)
    - USGS: https://www.usgs.gov/ provides geographical data and shapefiles
    - R script on how to geocode by address:
```r
# install the necessary libraries
library(dplyr, warn.conflicts = FALSE)
library(tidygeocoder)

# create a dataframe with addresses
some_addresses <- tibble::tribble(
  ~name,                  ~addr,
  "White House",          "1600 Pennsylvania Ave NW, Washington, DC",
  "Transamerica Pyramid", "600 Montgomery St, San Francisco, CA 94111",     
  "Willis Tower",         "233 S Wacker Dr, Chicago, IL 60606"                                  
)

# geocode the addresses
lat_longs <- some_addresses %>% 
  geocode(addr, method = 'osm', lat = latitude, long = longitude)
```




---

## II. State Data Sources
Analyze Trends: EPA/State Drinking Water Dashboard
* <u>Link</u>: https://echo.epa.gov/trends/comparative-maps-dashboards/drinking-water-dashboard

Alaska Drinking Water Watch
* <u>Link</u>: https://dec.alaska.gov/DWW/

California Drinking Water Watch
* <u>Link</u>: https://www.waterboards.ca.gov/resources/data_databases/
* <u>Link</u>: https://sdwis.waterboards.ca.gov/PDWW/

Indiana Drinking Water Watch (can select "sample point type" to identify distribution systems or entry point ID)
* <u>Link</u>: https://indwv.gecsws.com/
  
Louisiana Drinking Water Watch (can select "sample point type" to identify distribution systems or entry point ID)
* <u>Link</u>: https://sdw.ldh.la.gov/DWW/

New Jersey Drinking Water Watch
* <u>Link</u>: https://www9.state.nj.us/DEP_WaterWatch_public/

North Carolina Drinking Water Watch
* <u>Link</u>: https://www.pwss.enr.state.nc.us/NCDWW2/

Texas Drinking Water Watch
* <u>Link</u>: https://www.tceq.texas.gov/agency/water_main.html
* <u>Link</u>: https://dww2.tceq.texas.gov/DWW/



---

## III. Local Data Sources


------

## Type of Sampling Point
- **<u>Type of Sampling Point</u>**: indicates the location or function of the sampling point. Type could be one of the following:
	- **DS**: Distribution System—the location is in the distribution system of the water system. Examples of this type of sampling point include sampling points for Total Coliform, lead and copper, and perhaps disinfection by-products (see several of the types below for more precise ways to define disinfection by-products sampling points).
	- **EP**: Entry Point—location at which water enters the distribution system of a public water system. This is intended to correspond to the regulatory definition of an entry point to the distribution system representative of one or more sources of water. These should not be associated to Distribution System facilities but rather to the facility from which the water is flowing (e.g., a treatment plant, a well (if not treated prior to distribution), a common header).
	- **FC**: The first customer after the entry point into the distribution system.  While this site is specifically needed for chlorite and chlorine dioxide distribution system samples, it may have other uses.
	- **LD**: Lowest Disinfectant Residual—the location where the disinfectant residual is the lowest. This type of sampling point comes directly out of the Revisions to the Unregulated Contaminant Monitoring Rule dated September 17, 1999, where the preamble explains, “Some public commentators suggested that sampling for microbiological contaminants not occur at the maximum residence time in the distribution system, but at the point of lowest disinfectant residual, since the monitoring of concern is for effectiveness of treatment and booster disinfection stations that may be in use in long distribution lines. In response, The U.S. Environmental Protection Agency added another sampling point at the ‘‘lowest disinfectant residual’’ in the distribution system.” for trihalomethane (Disinfection By-Products Rule) and/or Total Coliform sampling.
	- **MD**: Midpoint in the Distribution System—the Unregulated Contaminant Monitoring Rule location at which the chlorine residual would be expected to be typical for the system. This could also be used to designate those sampling points that are considered “representative points in the distribution system” under the Disinfection By-Products Rules.
	- **MR**: Point of Maximum Retention—the location that represents the maximum residence time of disinfectants within the distribution system under the Disinfection By-Products Rules. This can also be used as the Unregulated Contaminant Monitoring Rule location in the distribution system that is furthest from the entry point to the distribution.
	- **PC**: Process Control—locations normally associated with treatment plants or storage water system facilities. This sampling point type is used to demonstrate compliance with contact time or other disinfectant or treatment requirements.
	- **RW**: Raw Water Source—locations normally associated with intake or well water system facilities. Raw water monitoring is triggered by the detection of a contaminant at an entry point to the distribution system. This Sampling Point type can also be used to designate the raw water sampling point for precursor removal.
 	- **SR**: Source Water Point—defined in the Unregulated Contaminant Monitoring Rule as the location at which untreated water is collected at the source.
	- **UP**: Unit Process—a sampling point used to evaluate the effectiveness of a unit process. This type might be used, for instance, to determine the contact time under the Surface Water Treatment Rule for a single unit process.
	- **WS**: Water System Facility point. <br />
 
(Source: <u>Link</u>: https://dec.alaska.gov/dww/Help/html_Type_of_Sampling_Point.htm)
