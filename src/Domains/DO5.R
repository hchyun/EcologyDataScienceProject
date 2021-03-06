DO5 <- read_csv("./outputs/plots_per_domain_5.csv")
colnames(DO5) <- tolower(colnames(DO5))

DO5 <- DO5 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO5_pred <- join(DO5, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO5_pred <- join(DO5_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO5_pred <- DO5_pred[, !duplicated(colnames(DO5_pred))] #removing duplicated column names
DO5_pred <- DO5_pred[complete.cases(DO5_pred),]

id <- DO5_pred$id_coords
DO5_pred$id_coords <- NULL
DO5_pred$id_coords <- id

DO5_clustered_x <- cluster_plots(DO5_pred, cols_cluster)
DO5_y <- get_responses(DO5_clustered_x, y_fia)

DO5_pred_final <- DO5_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))

DO5_pred_mat <- apply(DO5_pred_final, 2, scale)
DO5_pred_final <- data.frame(DO5_pred_mat)
DO5_training <- split_sample(DO5_pred_final, DO5_y)
DO5_train_x <- DO5_training[[1]]
DO5_train_y <- DO5_training[[2]]
DO5_test_x <- DO5_training[[3]]
DO5_test_y <- DO5_training[[4]]
rm(DO5_pred_mat, DO5_training)


DO5_out <- train_gjam(DO5_train_x, DO5_train_y)

DO5_eval <- evaluate_model(DO5_test_x, DO5_test_y, DO5_out)
