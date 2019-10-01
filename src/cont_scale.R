cont_pred <- join(cont_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
cont_pred <- cont_pred[, !duplicated(colnames(cont_pred))] #removing duplicated column names
cont_pred <- cont_pred[complete.cases(cont_pred),]

cont_clustered_x <- cluster_plots(cont_pred, cols_cluster)

cont_y <- get_responses(cont_clustered_x, y_fia)

cont_pred_final <- cont_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred_final)[1:3] <- c("slope", "aspect", "elev")

col_x <- c("slope","aspect","elev","daylength_3","daylength_4","daylength_10","prec_6","prec_7","rad_8","tmax_8","tmin_1")


cont_pred_final <- cont_pred_final[,col_x]
cont_pred_mat <- apply(cont_pred_final, 2, scale)
cont_pred_final <- data.frame(cont_pred_mat)
cont_training <- split_sample(cont_pred_final, cont_y)
cont_train_x <- cont_training[[1]]
cont_train_y <- cont_training[[2]]
cont_test_x <- cont_training[[3]]
cont_test_y <- cont_training[[4]]

cont_out <- train_gjam(cont_train_x, cont_train_y)

cont_eval <- evaluate_model(cont_test_x, cont_test_y, cont_out)
