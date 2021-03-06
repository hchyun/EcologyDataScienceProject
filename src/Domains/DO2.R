DO2 <- read_csv("./outputs/plots_per_domain_2.csv")

colnames(DO2) <- tolower(colnames(DO2))

DO2 <- DO2 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO2_pred <- join(DO2, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO2_pred <- join(DO2_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO2_pred <- DO2_pred[, !duplicated(colnames(DO2_pred))] #removing duplicated column names
DO2_pred <- DO2_pred[complete.cases(DO2_pred),]

id <- DO2_pred$id_coords
DO2_pred$id_coords <- NULL
DO2_pred$id_coords <- id

DO2_clustered_x <- cluster_plots(DO2_pred, cols_cluster)
DO2_y <- get_responses(DO2_clustered_x, y_fia)


DO2_pred_final <- DO2_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))

DO2_pred_mat <- apply(DO2_pred_final, 2, scale)
DO2_pred_final <- data.frame(DO2_pred_mat)
DO2_training <- split_sample(DO2_pred_final, DO2_y)
DO2_train_x <- DO2_training[[1]]
DO2_train_y <- DO2_training[[2]]
DO2_test_x <- DO2_training[[3]]
DO2_test_y <- DO2_training[[4]]
rm(DO2_pred_mat, DO2_training)

DO2_out <- train_gjam(DO2_train_x, DO2_train_y)

DO2_eval <- evaluate_model(DO2_test_x, DO2_test_y, DO2_out)
