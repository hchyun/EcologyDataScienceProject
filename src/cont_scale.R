cont_pred <- join(cont_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
cont_pred <- cont_pred[, !duplicated(colnames(cont_pred))] #removing duplicated column names
cont_pred <- cont_pred[complete.cases(cont_pred),]

ids <- cont_pred$id_coords
cont_pred$id_coords <- NULL
cont_pred$id_coords <- ids

cont_clustered_x <- cluster_plots(cont_pred, cols_cluster)

cont_y <- get_responses(cont_clustered_x, y_fia)

cont_clustered_x <- cont_clustered_x %>%
  group_by(statecd, countycd) %>%
  dplyr::mutate(tmin_1_county = mean(tmin_1), tmax_8_county = mean(tmax_8), prec_6_county = mean(prec_6), prec7_county = mean(prec_7), rad_8_county = mean(rad_8))

cont_clustered_x <- cont_clustered_x %>%
  group_by(statecd) %>%
  dplyr::mutate(tmin_1_state = mean(tmin_1), tmax_8_state = mean(tmax_8), prec_6_state = mean(prec_6), prec7_state = mean(prec_7), rad_8_state = mean(rad_8))

cont_pred_final <- cont_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr"))
#colnames(cont_pred_final)[1:3] <- c("slope", "aspect", "elev")

cont_pred_mat <- apply(cont_pred_final, 2, scale)
cont_pred_final <- data.frame(cont_pred_mat)
cont_training <- split_sample(cont_pred_final, cont_y)
cont_train_x <- cont_training[[1]]
cont_train_y <- cont_training[[2]]
cont_test_x <- cont_training[[3]]
cont_test_y <- cont_training[[4]]
rm(cont_training)

cont_out <- train_gjam(cont_train_x, cont_train_y)

cont_eval <- evaluate_model(cont_test_x, cont_test_y, cont_out)
