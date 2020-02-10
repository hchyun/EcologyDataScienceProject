library(tidyverse)
library(gjam)
library(plyr)
library(maptools)
library(sp)
library(rgdal)

neon_domains <- readOGR("NEONDomains_0/", "NEON_Domains")

#11, 10 are lon, lat
subscales_fia("../data/climate_fia.csv", c(11,10))

daymet_used <- read_csv("../data/climate_daymet.csv")
daymet_used$`Unnamed: 0` <- NULL

files <- c("../data/climate_fia.csv", "../data/response_fia.csv")
data_eco <- load_data(files)

x_fia <- get_mat(data_eco[[1]], colnames(data_eco[[1]]))
y_fia <- get_mat(data_eco[[2]], colnames(data_eco[[2]]))
rm(data_eco)
cont_pred<- x_fia

remove_plots <- cont_pred[is.na(cont_pred$physclcd) | is.na(cont_pred$slope) | is.na(cont_pred$aspect)
          | is.na(cont_pred$carbon_soil_org),]$id_coords

cont_pred <- cont_pred[!cont_pred$id_coords %in% remove_plots,]
y_fia <- y_fia[!y_fia$id_coords %in% remove_plots,]


cont_pred$dry <- 0
cont_pred[cont_pred$physclcd < 20, 'dry'] <- 1
cont_pred$mod <- 0
cont_pred[cont_pred$physclcd > 20 & cont_pred$physclcd < 30, 'mod'] <- 1

cont_pred$physclcd <- NULL

cols_cluster <- c("lat", "lon")


spcd_code <- read.csv("../data/spcd.csv")

set.seed(1)
