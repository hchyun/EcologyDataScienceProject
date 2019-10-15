daymet_files <- c("../data/prcp.csv", "../data/tmax.csv", "../data/tmin.csv")

daymet_raw <- load_data(daymet_files)
prcp <- daymet_raw[[1]]
prcp_jun <- prcp[prcp$month == 6, ]
colnames(prcp_jun)[3] <- "prec_6"
prcp_jul <- prcp[prcp$month == 7, ]
colnames(prcp_jul)[3] <- "prec_7"
tmax <- daymet_raw[[2]]
colnames(tmax)[3] <- "tmax_8"
tmin <- daymet_raw[[3]]
colnames(tmin)[3] <- "tmin_1"

min_lat <- min(cont_x$lat)
max_lat <- max(cont_x$lat)
min_lon <- min(cont_x$lon)
max_lon <- max(cont_x$lon)

#Removing coordinates outside of fia boundaries
prcp_jun <- prcp_jun[prcp_jun$lon >= min_lon & prcp_jun$lon <= max_lon &
                       prcp_jun$lat >= min_lat & prcp_jun$lat <= max_lat, ]
prcp_jul <- prcp_jul[prcp_jul$lon >= min_lon & prcp_jul$lon <= max_lon &
                       prcp_jul$lat >= min_lat & prcp_jul$lat <= max_lat, ]
tmax <- tmax[tmax$lon >= min_lon & tmax$lon <= max_lon &
                   tmax$lat >= min_lat & tmax$lat <= max_lat, ]
tmin <- tmin[tmin$lon >= min_lon & tmin$lon <= max_lon &
                   tmin$lat >= min_lat & tmin$lat <= max_lat, ]

get_min_distance <- function(x_mat, lat, lon){
  dist <- sqrt((x_mat$lat - lat)^2 + (x_mat$lon - lon)^2)
  min_dist <- min(dist)
  #What should be the minimum distance
  if(min_dist > 5){
    return(NULL)
  }
  row <- which(dist ==  min_dist)
  return(list("county"=x_mat$countycd[row], "state"=x_mat$statecd[row], "plot"=x_mat$plot[row]))
}

get_daymet_temporal <- function(year, climate_variable, climate_name, cont_df, to_join=NULL){

  final_df <- cont_df
  final_df[,climate_name] <- NA
  clim <- climate_variable[climate_variable$year == year,]
  for(i in 1:nrow(clim)){
    if(climate_variable[i, climate_name] != -9999){
      location <- get_min_distance(final_df, clim$lat[i], clim$lon[i])
      if(!is.null(location)){
        row <- which(final_df$statecd == location$state & final_df$countycd == location$county & final_df$plot == location$plot)
        final_df[row, climate_name] = clim[i, climate_name]
      }
    }
    
  }
  final_df <- final_df[as.vector(!is.na(final_df[,climate_name])), c("statecd", "unitcd", "countycd", "plot", climate_name)]
  return(final_df)
  
}

get_cont_pred_year <- function(year, cont_pred_, tmax_, tmin_, prcp_jun_, prcp_jul_, cont_x_){
  cont_pred_tmax <- get_daymet_temporal(2000, tmax_, "tmax_8", cont_x_)
  cont_pred_tmin <- get_daymet_temporal(2000, tmin_, "tmin_1", cont_x_)
  cont_pred_prec6 <- get_daymet_temporal(2000, prcp_jun_, "prec_6", cont_x_)
  cont_pred_prec7 <- get_daymet_temporal(2000, prcp_jul_, "prec_7", cont_x_)
  
  cont_pred <- join(cont_pred_[, colnames(cont_pred_) != 'tmax_8'], cont_pred_tmax, type="right", by=c("statecd","unitcd","countycd","plot"), match="first")
  cont_pred_ <- join(cont_pred_[, colnames(cont_pred_) != 'tmin_1'], cont_pred_tmin, type="right", by=c("statecd","unitcd","countycd","plot"), match="first")
  cont_pred_ <- join(cont_pred_[, colnames(cont_pred_) != 'prec_6'], cont_pred_prec6, type="right", by=c("statecd","unitcd","countycd","plot"), match="first")
  cont_pred_ <- join(cont_pred_[, colnames(cont_pred_) != 'prec_7'], cont_pred_prec7, type="right", by=c("statecd","unitcd","countycd","plot"), match="first")
  cont_pred_ <- cont_pred_[complete.cases(cont_pred_),]
  id <- cont_pred_$id_coords
  cont_pred_$id_coords <- NULL
  cont_pred_$id_coords <- id
  return(cont_pred_)
}
