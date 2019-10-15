temporal_fia <- read.csv("../data/fia_temporal.csv")

temporal_fia_2000 <- temporal_fia[temporal_fia$invyr == 2000,]
colnames(temporal_fia_2000)[1] <- "count"
temporal_fia_2000$id_coords <- paste(temporal_fia_2000$statecd, temporal_fia_2000$unitcd, temporal_fia_2000$countycd, temporal_fia_2000$plot, sep='_')
temporal_fia_2005 <- temporal_fia[temporal_fia$invyr == 2005,]
colnames(temporal_fia_2005)[1] <- "count"
temporal_fia_2005$id_coords <- paste(temporal_fia_2005$statecd, temporal_fia_2005$unitcd, temporal_fia_2005$countycd, temporal_fia_2005$plot, sep='_')
temporal_fia_2015 <- temporal_fia[temporal_fia$invyr == 2015,]
colnames(temporal_fia_2015)[1] <- "count"
temporal_fia_2015$id_coords <- paste(temporal_fia_2015$statecd, temporal_fia_2015$unitcd, temporal_fia_2015$countycd, temporal_fia_2015$plot, sep='_')

#2000 Predictor setup
cont_pred_2000 <- get_cont_pred_year(2000, cont_pred, tmax, tmin, prcp_jun, prcp_jul, cont_x)
#2005 Predictor setup
cont_pred_2005 <- get_cont_pred_year(2005, cont_pred, tmax, tmin, prcp_jun, prcp_jul, cont_x)
#2015 Predictor setup
cont_pred_2015 <- get_cont_pred_year(2015, cont_pred, tmax, tmin, prcp_jun, prcp_jul, cont_x)


cont_pred_2000_clustered <- cluster_plots(cont_pred_2000, cols_cluster)
cont_pred_2005_clustered <- cluster_plots(cont_pred_2005, cols_cluster)
cont_pred_2015_clustered <- cluster_plots(cont_pred_2015, cols_cluster)

cont_y_2000 <- get_responses(cont_pred_2000_clustered, temporal_fia_2000)
cont_y_2005 <- get_responses(cont_pred_2005_clustered, temporal_fia_2005)
cont_y_2015 <- get_responses(cont_pred_2015_clustered, temporal_fia_2015)
intersect_spc <- intersect(intersect(colnames(cont_y_2000), colnames(cont_y_2005)), colnames(cont_y_2015))
cont_y_2000 <- cont_y_2000[,intersect_spc]
cont_y_2005 <- cont_y_2005[,intersect_spc]
cont_y_2015 <- cont_y_2015[,intersect_spc]

cont_pred_2000_final <- cont_pred_2000_clustered %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred_2000_final)[1:3] <- c("slope", "aspect", "elev")

cont_pred_2005_final <- cont_pred_2005_clustered %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred_2005_final)[1:3] <- c("slope", "aspect", "elev")

cont_pred_2015_final <- cont_pred_2015_clustered %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred_2015_final)[1:3] <- c("slope", "aspect", "elev")

cont_pred_2000_final <- cont_pred_2000_final[,col_x]
cont_pred_2000_mat <- apply(cont_pred_2000_final, 2, scale)
cont_pred_2000_final <- data.frame(cont_pred_2000_mat)

cont_pred_2005_final <- cont_pred_2005_final[,col_x]
cont_pred_2005_mat <- apply(cont_pred_2005_final, 2, scale)
cont_pred_2005_final <- data.frame(cont_pred_2005_mat)

cont_pred_2015_final <- cont_pred_2015_final[,col_x]
cont_pred_2015_mat <- apply(cont_pred_2015_final, 2, scale)
cont_pred_2015_final <- data.frame(cont_pred_2015_mat)

cont_out_2000 <- train_gjam(cont_pred_2000_final, cont_y_2000)
cont_out_2005 <- train_gjam(cont_pred_2005_final, cont_y_2005)
cont_out_2015 <- train_gjam(cont_pred_2015_final, cont_y_2015)

cont_eval_2000 <- evaluate_model(cont_pred_2005_final, cont_y_2005, cont_out_2000)
cont_eval_200015 <- evaluate_model(cont_pred_2015_final, cont_y_2015, cont_out_2000)

gjamPlot(output=cont_out_2000)
gjamPlot(output=cont_out_2005)
gjamPlot(output=cont_out_2015)
