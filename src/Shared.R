library(tidyverse)
library(gjam)
library(plyr)
library(maptools)
library(sp)
library(rgdal)
load_packages()

neon_domains <- readOGR("NEONDomains_0/", "NEON_Domains")

#6, 5 are lon, lat
subscales_fia("../data/climate_fia.csv", c(6,5))

#Fix daymet so its just last year
daymet <- read_csv("../data/climate_daymet.csv")
daymet_used <- daymet[,c("countycd", "unitcd","statecd","plot","daylength_3", "daylength_4","daylength_10","prec_6","prec_7","rad_8","tmax_8","tmin_1")]

files <- c("../data/climate_fia.csv", "../data/response_fia.csv")
data_eco <- load_data(files)

#x <- get_mat(data_eco[[1]],colnames(data_eco[[1]])[-1])   #Getting rid of row indexer column
x_fia <- get_mat(data_eco[[1]], colnames(data_eco[[1]]))
y_fia <- get_mat(data_eco[[2]], colnames(data_eco[[2]]))
rm(data_eco)
colnames(y_fia)[1] <- "count"
cont_pred<- x_fia

cont_pred$dry <- 0
cont_pred[cont_pred$physclcd < 20, 'dry'] <- 1
cont_pred$mod <- 0
cont_pred[cont_pred$physclcd > 20 & cont_pred$physclcd < 30, 'mod'] <- 1

cont_pred$physclcd <- NULL
cont_pred$watercd <- NULL

cols_cluster <- c("lat", "lon")


spcd_code <- read.csv("../data/spcd.csv")

set.seed(1)