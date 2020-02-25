DO9 <- read_csv("./outputs/plots_per_domain_9.csv")

colnames(DO9) <- tolower(colnames(DO9))

DO9 <- DO9 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO9_pred <- join(DO9, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO9_pred <- join(DO9_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO9_pred <- DO9_pred[, !duplicated(colnames(DO9_pred))] #removing duplicated column names
DO9_pred <- DO9_pred[complete.cases(DO9_pred),]

id <- DO9_pred$id_coords
DO9_pred$id_coords <- NULL
DO9_pred$id_coords <- id

DO9_clustered_x <- cluster_plots(DO9_pred, cols_cluster)
DO9_y <- get_responses(DO9_clustered_x, y_fia)

DO9_pred_final <- DO9_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))

DO9_pred_mat <- apply(DO9_pred_final, 2, scale)
DO9_pred_final <- data.frame(DO9_pred_mat)
DO9_training <- split_sample(DO9_pred_final, DO9_y)
DO9_train_x <- DO9_training[[1]]
DO9_train_y <- DO9_training[[2]]
DO9_test_x <- DO9_training[[3]]
DO9_test_y <- DO9_training[[4]]
rm(DO9_pred_mat, DO9_training)

DO9_out <- train_gjam(DO9_train_x, DO9_train_y)

DO9_eval <- evaluate_model(DO9_test_x, DO9_test_y, DO9_out)
