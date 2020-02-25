DO16 <- read_csv("./outputs/plots_per_domain_16.csv")

colnames(DO16) <- tolower(colnames(DO16))

DO16 <- DO16 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO16_pred <- join(DO16, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO16_pred <- join(DO16_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO16_pred <- DO16_pred[, !duplicated(colnames(DO16_pred))] #removing duplicated column names
DO16_pred <- DO16_pred[complete.cases(DO16_pred),]

id <- DO16_pred$id_coords
DO16_pred$id_coords <- NULL
DO16_pred$id_coords <- id

DO16_clustered_x <- cluster_plots(DO16_pred, cols_cluster)
DO16_y <- get_responses(DO16_clustered_x, y_fia)

DO16_pred_final <- DO16_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr", "physclcd"))

DO16_pred_mat <- apply(DO16_pred_final, 2, scale)
DO16_pred_final <- data.frame(DO16_pred_mat)

DO16_training <- split_sample(DO16_pred_final, DO16_y)
DO16_train_x <- DO16_training[[1]]
DO16_train_y <- DO16_training[[2]]
DO16_test_x <- DO16_training[[3]]
DO16_test_y <- DO16_training[[4]]
rm(DO16_pred_mat, DO16_training)

DO16_out <- train_gjam(DO16_train_x[,-c(7)], DO16_train_y)

DO16_eval <- evaluate_model(DO16_test_x, DO16_test_y, DO16_out)
