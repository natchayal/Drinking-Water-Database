# Data Processing

## 📂 Script Folder Structure (code)
This repository contains R script to process structured data stored in the `data/` directory. 
- **SDWIS_violation_data_Rscript.R** (pulls data from sdwis_violation) <br/>
- **SYR_data_Rscript.R** (pulls data from six_year_review) <br/>
- **svi_census_zcta_Rscript.R** (pulls data from Census API using R package) <br/>

## 📂 Data Folder Structure (data)
The structure is as follows:
<br/>
base folder <br/>
|-data <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|-sdwis_violation <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-raw <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-cleaned <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|-six_year_review <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-raw <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-cleaned <br/>
&nbsp;&nbsp;&nbsp;&nbsp;|-svi_census <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-raw <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-cleaned <br/>

## 📌 How the Script Works
- The script reads **raw** data from the `data/.../raw/` folder in each subdirectory. <br/>
- It **cleans and standardizes** column names and structures.
- It processes the data and saves **cleaned** versions into the `data/.../cleaned/` folder.<br/>
- Cleaned data from multiple sources is **merged into a final master dataset** for further processing.
- The cleaned and merged data is **saved** in the `data/.../cleaned/` folder.
