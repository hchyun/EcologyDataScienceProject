daymet <- read.csv('../data/daymet_climate_temporal.csv')

get_min_distance <- function(x_mat, lat, lon){
  dist <- sqrt((x_mat$lat - lat)^2 + (x_mat$lon - lon)^2)
  row <- which.min(dist)
 
  if(dist[row] > 1){
    return(NULL)
  }
  return(row)
  
}

get_cont_pred_year <- function(year, cont_pred_, daymet_data){
  
  daymet_data <- daymet_data[daymet_data$year == year, ]
  final_data <- cont_pred_
  final_data$year <- year
  final_data$prec_6 <- NA
  final_data$prec_7 <- NA
  final_data$tmax_8 <- NA
  final_data$tmin_1 <- NA
  unique_ind <- c()
  for(i in 1:nrow(cont_pred_)){
    plot_ind <- get_min_distance(daymet_data, cont_pred_$lat[i], cont_pred_$lon[i])

    if(!is.null(plot_ind)){
      unique_ind <- c(unique_ind, plot_ind)
      final_data[i, c('prec_6','prec_7','tmin_1','tmax_8')] <- daymet_data[plot_ind, c('prec_6','prec_7','tmin_1','tmax_8')]
    }
   
  }
  
  final_data <- final_data[complete.cases(final_data),]
  
  return(final_data)
}

