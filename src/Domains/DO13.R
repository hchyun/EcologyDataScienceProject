DO13 <- read_csv("./outputs/plots_per_domain_13.csv")

colnames(DO13) <- tolower(colnames(DO13))

DO13 <- DO13 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO13_pred <- join(DO13, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO13_pred <- join(DO13_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO13_pred <- DO13_pred[, !duplicated(colnames(DO13_pred))] #removing duplicated column names
DO13_pred <- DO13_pred[complete.cases(DO13_pred),]

id <- DO13_pred$id_coords
DO13_pred$id_coords <- NULL
DO13_pred$id_coords <- id

DO13_clustered_x <- cluster_plots(DO13_pred, cols_cluster)
DO13_y <- get_responses(DO13_clustered_x, y_fia)

DO13_pred_final <- DO13_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))

DO13_pred_mat <- apply(DO13_pred_final, 2, scale)
DO13_pred_final <- data.frame(DO13_pred_mat)

DO13_training <- split_sample(DO13_pred_final, DO13_y)
DO13_train_x <- DO13_training[[1]]
DO13_train_y <- DO13_training[[2]]
DO13_test_x <- DO13_training[[3]]
DO13_test_y <- DO13_training[[4]]
rm(DO13_pred_mat, DO13_training)

DO13_out <- train_gjam(DO13_train_x, DO13_train_y)

DO13_eval <- evaluate_model(DO13_test_x, DO13_test_y, DO13_out)