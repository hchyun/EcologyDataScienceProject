# EcologyDataScienceProject

## Overview
The goal of this project is to apply a joint species distribution model to predict population of different tree species in the United States. This project utilizes the FIA data for the tree species information and Daymet data for the climate information. This approach of species distribution modeling is different from others as it considers interspecies relationships when modeling the species distribution. The model is applied to different NEON Domains (Figure 1) to investigate interspecies relationships in different climates and response to different variables in different climates.

 Link to our paper: https://arxiv.org/pdf/1910.04932.pdf


![alt text](https://www.neonscience.org/sites/default/files/styles/fullwidth/public/image-content-images/2016_NEONBattelleDomainOverview-web.png?itok=WfKIIINK)
**Figure 1 (image from https://www.neonscience.org)**

### Data
The FIA data is a ground sample of FIA plots of forests in the United States. For more information visit https://www.fia.fs.fed.us.
The Daymet data contains climate information of North America. For more information visit https://daymet.ornl.gov.
For more NEON information visit https://www.neonscience.org.

## Setting Up
To Download the data run `make` in `./src`.

## Training GJAM
Running the code on RStudio would be the best method and set the working directory to `EcologyDataScienceProject/src`. 
To train the model run `Rscript ./src/Run.R`
To train individual domains run each `Rscript ./src/Domains/DO<Domain Number>.R` file

### GJAM
To find out more about Generalized Joint Attribute Model (Clark et. al. 2017) read https://cran.r-project.org/web/packages/gjam/vignettes/gjamVignette.html.

## Analysis of the Results
To view the model results and analysis of the performance run `Rscript ./src/analysis.R`

### Directory Structure
```
EcologyDataScienceProject
├── data 
    ├── response_fia.csv    # Tree species data file from FIA
    ├── climate_fia.csv   # Climate data from FIA
    ├── spcd.csv        # Species code and species name from FIA
    └── climate_daymet.csv   # Daymet data with fia location codes
├── plots
    ├── spcaccuracy.png  # histogram for the species accuracy
    ├── Accuracy.png # barplot of the percentage of species above 0 R2 value
    ├── cont pred.png # Predictor sensitivity for continental model
    ├── Fiaplots.png # Plots mapped on the US
    └── predictorplots # Directory that contains the predictors sensitivity across the domains
└── src
    ├── shared.R # Data that is shared among all domains and continental scale models
    ├── analysis.R # Analysis of the results, generating plots
    ├── Run.R # Main file to run the code
    ├── cont_scale.R # Continental GJAM model
    ├── download.py # Downloading NEON data
    ├── functions.R # File with the utility functions for the code
    ├── plotpoints.R # Plotting points of where the species occur
    ├── DataSetup
        ├── spcd.py # Generating spcd.csv file
        └── make_data.py # Querying from FIA SQL database to generate csv files in data directory
    ├── outputs
        └── plots_per_domain_<number>.csv # Generated from sub_scales function dividing FIA plots into NEON domains
    ├── Domains
        └── DO<number>.R # Domain level GJAM models
    └── NEONDomains_0 # Neon domain files downloaded from NEON website
```