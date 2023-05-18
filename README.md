# Drinking Water Database Exploration
Analyzing drinking water standards and regulations. This git repository contains code for data acquision (see get_data subdirectory), analysis (see analysis subdirectory), and the jekyll site for this project (see docs subdirectory). 

The website for this project can be viewed here (*in progress*).

## ♦ Executive Summary ♦
I spent a lot of time exploring various drinking water database available on the internet. I evaluated resources on the relevance of the data they provided as well as how easily the data could be accessed and downloaded, a summary of which is provided below. I also generated a number of R scripts, provided as interactive R markdown notebooks (.Rmd) files that demonstrate how some of these datasets are accessed and visualized. 

While this represents a number of useful sites, it's certainly not exhaustive. 

**Summary of datasets evaluated**

| Source          | Dataset                                                      | Ease of Access | Data Utility | Comments                                                 |
| --------------- | ------------------------------------------------------------ | :------------: | :----------: | -------------------------------------------------------- |
| EPA             | [Safe Drinking Water Information System (SDWIS)](https://www.epa.gov/enviro/web-services) |       ♦♦♦♦♦       |     ♦♦      | Limited Data, easy to scrape with R. <br />Can get violation data, treatment, water system, and purchaser-seller info.                              |                              |
| EPA             | [Enforcement & Compliance History Online(ECHO)](https://echo.epa.gov/) |      ♦♦♦♦      |    ♦♦♦♦♦     | Good, but so much data it's hard to know what's what     |
| EPA             | [USEPA Six Year Review Data](https://www.epa.gov/dwsixyearreview/six-year-review-3-compliance-monitoring-data-2006-2011)) |       ♦♦♦♦       |     ♦♦♦♦      | Data rich, easy to scrape. <br />Reports National occurence for each contaminant (not just the violations).  |
| USGS/EPA        | [Water Quality Portal](https://www.waterqualitydata.us/)     |     ♦♦♦♦♦      |    ♦♦♦♦♦     | Well organized & <br />comprehensive data                |
| EPA | [USEPA IRIS Information](https://www.epa.gov/iris) |     ♦♦♦♦♦      |    ♦♦     | Concentration on drinking (oral) route of exposure, not air. <br />Toxicology information, Maximum Contaminant Level (MCL) information.                        |



---
# Archive of Drinking Water Database

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
      - Select data of interest and export report as a .csv file, use this link: https://ofmpub.epa.gov/apex/sfdw/f?p=108:1:0::NO:1
    
    - R script is based on the info contained here: https://www.epa.gov/enviro/web-services
      - Then need to scrape sub-tables..
      - If you need to define a code or other parameter in the table, this link contains all that information: https://enviro.epa.gov/enviro/ef_metadata_html.ef_metadata_table?p_table_name=VIOLATION&p_topic=SDWIS
- <u>Code examples</u> : 
```r
	Data1 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/0:100000/CSV")) 
	Data2 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/100000:200000/CSV")) 
	Data3 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/200000:300000/CSV")) 
	Data4 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/300000:400000/CSV")) 
	Data5 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/400000:450000/CSV"))
	Data6 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/450000:500000/CSV"))
	Data7 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/500000:600000/CSV")) 
	Data8 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/600000:700000/CSV")) 
	Data9 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/700000:800000/CSV")) 
	Data10 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/800000:900000/CSV")) 
	Data11 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/900000:1000000/CSV")) 
	Data12 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1000000:1100000/CSV")) 
	Data13 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1100000:1200000/CSV")) 
	Data14 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1200000:1300000/CSV")) 
	Data15 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1300000:1400000/CSV")) 
	Data16 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1400000:1500000/CSV")) 
	Data17 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1500000:1600000/CSV")) 
	Data18 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1600000:1700000/CSV")) 
	Data19 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1700000:1800000/CSV")) 
	Data20 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1800000:1900000/CSV")) 
	Data21 <- read.csv(url("https://data.epa.gov/efservice/VIOLATION/ROWS/1900000:2000000/CSV")) 

	DataMerged <- do.call("rbind", list(Data1,Data2,Data3,Data4,Data5,Data6,Data7,Data8,Data9,Data10,Data11,Data12,Data13,Data14,Data15,Data16,Data17,Data18,Data19,Data20,Data21))
	filename <- paste0("AllViolationData_EPA_EnvirofactsAPI_", format(Sys.Date(), "%m%d%y"), ".csv")
	write.csv(DataMerged, file = filename, row.names=FALSE)
```


### B. EPA Enforcement and Compliance History Online (ECHO)

- **<u>Overview</u>**: ***Promising!***
  - Established data services capabilities with documented web services
  - Holds many datasets, though so much that it's somewhat confusing what it holds:
    - Drinking Water: https://echo.epa.gov/help/facility-search/drinking-water-search-results-help#frsid
    - Water Facility: https://echo.epa.gov/tools/web-services/facility-search-water

- <u>Link</u>: https://echo.epa.gov/
- <u>Summary</u>: Provides compliance and enforcement information for over 900,000 regulated facilities nationwide. Allows query at state/county/city/zip level for a table of facilities and their compliance records. Not limited to water (NPDES and drinking water); includes air, hazardous waste,...
- <u>Data</u>:
  - Main pages searches by form. Not REST interface. CSV's generated with temporary link. 	
  - Download data as ZIP file: https://echo.epa.gov/tools/data-downloads#downloads
  - <u>Web services</u> provided: https://echo.epa.gov/tools/web-services
    - Documentation is a bit obtuse, generates temporary result files (valid for 30 min)
- <u>Code examples</u>: None


### C. USEPA Six Year Review Data

- <u>**Overview**</u>: Data rich, easy to scrape, and contains occurence and contaminant level data (not just the violations!)
  - Updated every 6 years 
  - Does not contain system information
  - Can link with SDWIS database by matching PWSID to get more system information

* <u>Link</u>: https://www.epa.gov/dwsixyearreview

* <u>Summary</u>: The Safe Drinking Water Act (SDWA) requires EPA to review each national primary drinking water regulation at least once every six years and revise them, if appropriate. As part of the "Six-Year Review," EPA evaluates any newly available data, information and technologies to determine if any regulatory revisions are needed. Revisions must maintain or strengthen public health protection.

* Data: 
  * Each zip file below contains data for multiple contaminants and related information that can be unzipped into tab delimited text files: https://www.epa.gov/dwsixyearreview
  * Data is located at the following link, and is broken down by contaminant: https://www.epa.gov/dwsixyearreview/six-year-review-3-compliance-monitoring-data-2006-2011

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


### E. USEPA IRIS Information

- **<u>Overview</u>**: Good for toxicity information
  - "What is the toxicity?"

- <u>Link</u>: https://www.epa.gov/iris
- <u>Summary</u>: IRIS assessments provide the following toxicity values for health effects resulting from chronic exposure to chemicals.
- <u>Data</u>:
    - Integrated Risk Information System: https://www.epa.gov/iris
    - National Primary Drinking Water Regulations: https://www.epa.gov/ground-water-and-drinking-water/national-primary-drinking-water-regulations
   
- <u>Code examples</u>: None


### F. Census Bureau
- **<u>Overview</u>**: Good for Geographic & Demographic Information

- <u>Summary</u>: Information can be combined with water quality data and mapped with GIS.
    - ECHO: https://echo.epa.gov/tools/data-downloads/demographic-download-summary for income and census data
    - UCB: https://data.census.gov/table to explore census tables which can be downloaded
    - CDC: https://www.atsdr.cdc.gov/placeandhealth/svi/data_documentation_download.html for social vulneravility index (SVI) assessment
    - USGS: https://www.usgs.gov/ provides geographical data and shapefiles

- <u>Code examples</u>: None


---

## II. State Data Sources




---

## III. Local Data Sources


------

## 
