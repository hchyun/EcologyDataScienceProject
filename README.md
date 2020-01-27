# EcologyDataScienceProject

## Overview
The goal of this project is to apply a joint species distribution model to predict population of different tree species in the United States. This project utilizes the FIA data for the tree species information and Daymet data for the climate information. This approach of species distribution modeling is different from others as it considers interspecies relationships when modeling the species distribution. The model that was used is the [Generalized Joint Attribute Model][GJAM] (Clark et.al. 2017). The model is applied to different NEON Domains (Figure 1) to investigate interspecies relationships in different climates and response to different variables in different climates. The model is also applied to a more global scales to investigate any differences in tree species behavior from smaller scales.

For other data science challenges to ecology, read more about the [data science challenge][idtrees] coming up!

## Quick Links
- [Requirements](#requirements)
- [Data](#data)
- [Training GJAM](#training-gjam)
- [Analysis of Results](#analysis-of-the-results)
- [Directory Structure](#directory-structure)
- [Contact](#contact)


![alt text](https://www.neonscience.org/sites/default/files/styles/fullwidth/public/image-content-images/2016_NEONBattelleDomainOverview-web.png?itok=WfKIIINK)
**Figure 1 (image from https://www.neonscience.org) Courtesy: Battelle. The information provided may not have been reviewed or prepared by Battelle.  It is provided AS IS without any warranty of any kind, express or implied, and may not reflect Battelle's views or opinions**

## Requirements
The best way to run this project is to download [RStudio][RStudio]. This project was built on R version 3.5.1 but may run on other versions of R and Python version 3.6.3.

In order to clone the repository, run following command:
```bash
git clone https://github.com/hchyun/EcologyDataScienceProject.git
```

Then open RStudio and create a new project and open `setup.R` file and run the file to install the necessary R packages.
To complete the setup of the R environment set the working directory to `EcologyDataScienceProject/src` by typing `setwd("<Path_to_project>/EcologyDataScienceProject/src")` in the R console or setting the working directory through RStudio.

## Data
There are three main data sources for this project: [Forest Inventory and Analysis][FIA-home] (FIA), [Daymet][Daymet], and [The National Ecological Observatory Network][NEON]. Each of these data sources require different permissions to download the data.

The FIA data was used to find species abundances across the forests in the United States. For the FIA data, there is a [FIA DataMart][FIA-datamart], where SQLite databases can be downloaded for each state.

For the Daymet data, a user account for Oak Ridge National Laboratory Distributed Active Archive Center (ORNL DAAC) must be made in order to access and download the data.

The NEON data could be downloaded by running `python download.py` in the `EcologyDataScienceProject/src` directory of the project. A compressed file called `NEONDomains_0.zip` will be downloaded and unzipping the file will create a `NEONDomains_0` directory. Or it can be found on the [NEON Data Website][NEON-data] under `NEON Domains - Shapefile`. This data contains information about the NEON domains shown in figure 1.

## Training GJAM
To train the model run `Run.R` in `EcologyDataScienceProject/src`. Which will run the following files:
`functions.R    Shared.R    cont_scale.R  /Domains/DO<Domain Number>.R `. The file will run the continental model and each domain. To run a domain or continental model just run the line that corresponds to the respective model in `Run.R`. Note that `Shared.R` and `functions.R` must be ran before running any of these models.


## Analysis of the Results
To view the model results and analysis of the performance run `analysis.R`. This script was used to generate the plots on `plots/` directory

### Directory Structure
```
EcologyDataScienceProject
├── data 
    ├── climate_daymet.csv   # Daymet data with fia location codes
    ├── climate_fia.csv   # Climate data from FIA
    ├── response_fia.csv    # Tree species data file from FIA
    └── spcd.csv        # Species code and species name from FIA
├── plots
    ├── Accuracy.png # barplot of the percentage of species above 0 R2 value
    ├── cont pred.png # Predictor sensitivity for continental model
    ├── Fiaplots.png # Plots mapped on the US
    ├── predictorplots # Directory that contains the predictors sensitivity across the domains
    └── spcaccuracy.png  # histogram for the species accuracy
└── src
    ├── analysis.R # Analysis of the results, generating plots
    ├── cont_scale.R # Continental GJAM model
    ├── DataSetup
        ├── spcd.py # Generating spcd.csv file
        └── make_data.py # Querying from FIA SQL database to generate csv files in data directory
    ├── Domains
        └── DO<number>.R # Domain level GJAM models
    ├── download.py # Downloading NEON data
    ├── functions.R # File with the utility functions for the code
    ├── NEONDomains_0 # Neon domain files downloaded from NEON website
    ├── outputs
        └── plots_per_domain_<number>.csv # Generated from sub_scales function dividing FIA plots into NEON domains
    ├── plotpoints.R # Plotting points of where the species occur
    ├── Run.R # Main file to run the code
    └── shared.R # Data that is shared among all domains and continental scale models
```

## Contact

Please contact [Hyun Choi][hyun-home] (hchyun@ufl.edu) for any bugs or any questions regarding the dataset or code


[Daymet]: https://daymet.ornl.gov
[FIA-home]: https://www.fia.fs.fed.us
[FIA-datamart]: https://apps.fs.usda.gov/fia/datamart/
[GJAM]: https://cran.r-project.org/web/packages/gjam/vignettes/gjamVignette.html
[hyun-home]: https://www.linkedin.com/in/hyun-choi-712340151/
[idtrees]: https://idtrees.org
[NEON]: https://www.neonscience.org
[NEON-data]: https://www.neonscience.org/data/about-data/spatial-data-maps
[RStudio]: https://rstudio.com/products/rstudio/download/
[paper-link]: https://arxiv.org/abs/1910.04932