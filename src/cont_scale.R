cont_clustered_x <- cluster_plots(cont_pred, cols_cluster)

cont_y <- get_responses(cont_pred, y_fia)

cont_pred_final <- cont_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
#colnames(cont_pred)[1:3] <- c("slope", "aspect", "elev")

cont_pred_mat <- apply(cont_pred_final, 2, scale)
cont_pred_final <- data.frame(cont_pred_mat)
cont_training <- split_sample(cont_pred_final, cont_y)
cont_train_x <- cont_training[[1]]
cont_train_y <- cont_training[[2]]
cont_test_x <- cont_training[[3]]
cont_test_y <- cont_training[[4]]

cont_out <- train_gjam(cont_train_x, cont_train_y)

cont_eval <- evaluate_model(cont_test_x, cont_test_y, cont_out)