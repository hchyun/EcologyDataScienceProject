# EcologyDataScienceProject

## Overview
The goal of this project is to apply a joint species distribution model to predict population of different tree species in the United States. This project utilizes the FIA data for the tree species information and Daymet data for the climate information. This approach of species distribution modeling is different from others as it considers interspecies relationships when modeling the species distribution. The model is applied to different NEON Domains (Figure 1) to investigate interspecies relationships in different climates and response to different variables in different climates.



![alt text](https://www.neonscience.org/sites/default/files/styles/fullwidth/public/image-content-images/2016_NEONBattelleDomainOverview-web.png?itok=WfKIIINK)
**Figure 1 (image from https://www.neonscience.org)**



### Data
The FIA data is a ground sample of FIA plots of forests in the United States. For more information visit https://www.fia.fs.fed.us.
The Daymet data contains climate information of North America. For more information visit https://daymet.ornl.gov.
For more NEON information visit https://www.neonscience.org.

## Setting Up
To Download the data run `make` in `./src`.

## Training GJAM
Running the code on RStudio would be the best method.
To train the model run `Rscript ./src/Run.R`
To train individual domains run each `Rscript ./src/Domains/DO<Domain Number>.R` file

### GJAM
To find out more about Generalized Joint Attribute Model (Clark et. al. 2017) read `Clark_et_al-2017-Ecological_Monographs.pdf` in the root directory of the source folder.

## Analysis of the Results
To view the model results and analysis of the performance run `Rscript ./src/analysis.R`