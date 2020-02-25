DO8 <- read_csv("./outputs/plots_per_domain_8.csv")

colnames(DO8) <- tolower(colnames(DO8))

DO8 <- DO8 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO8_pred <- join(DO8, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO8_pred <- join(DO8_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO8_pred <- DO8_pred[, !duplicated(colnames(DO8_pred))] #removing duplicated column names
DO8_pred <- DO8_pred[complete.cases(DO8_pred),]

id <- DO8_pred$id_coords
DO8_pred$id_coords <- NULL
DO8_pred$id_coords <- id

DO8_clustered_x <- cluster_plots(DO8_pred, cols_cluster)
DO8_y <- get_responses(DO8_clustered_x, y_fia)

DO8_pred_final <- DO8_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))

DO8_pred_mat <- apply(DO8_pred_final, 2, scale)
DO8_pred_final <- data.frame(DO8_pred_mat)

DO8_training <- split_sample(DO8_pred_final, DO8_y)
DO8_train_x <- DO8_training[[1]]
DO8_train_y <- DO8_training[[2]]
DO8_test_x <- DO8_training[[3]]
DO8_test_y <- DO8_training[[4]]
rm(DO8_pred_mat, DO8_training)

DO8_out <- train_gjam(DO8_train_x, DO8_train_y)

DO8_eval <- evaluate_model(DO8_test_x, DO8_test_y, DO8_out)