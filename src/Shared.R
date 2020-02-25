library(tidyverse)
library(gjam)
library(plyr)
library(sp)

daymet_used <- read_csv("../data/climate_daymet.csv")

files <- c("../data/climate_fia.csv", "../data/response_fia.csv")
data_eco <- load_data(files)

x_fia <- get_mat(data_eco[[1]], colnames(data_eco[[1]]))
y_fia <- get_mat(data_eco[[2]], colnames(data_eco[[2]]))
rm(data_eco)

cont_pred<- x_fia
rm(x_fia)

cont_pred <- cont_pred[complete.cases(cont_pred),]
y_fia <- y_fia[y_fia$id_coords %in% cont_pred$id_coords,]


cont_pred$dry <- 0
cont_pred[cont_pred$physclcd < 20, 'dry'] <- 1
cont_pred$mod <- 0
cont_pred[cont_pred$physclcd > 20 & cont_pred$physclcd < 30, 'mod'] <- 1
cont_pred$physclcd <- NULL

cols_cluster <- c("lat", "lon")
spcd_code <- read.csv("../data/spcd.csv")

set.seed(1)
