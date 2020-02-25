DO3 <- read_csv("./outputs/plots_per_domain_3.csv")
colnames(DO3) <- tolower(colnames(DO3))

DO3 <- DO3 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO3_pred <- join(DO3, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO3_pred <- join(DO3_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO3_pred <- DO3_pred[, !duplicated(colnames(DO3_pred))] #removing duplicated column names
DO3_pred <- DO3_pred[complete.cases(DO3_pred),]

id <- DO3_pred$id_coords
DO3_pred$id_coords <- NULL
DO3_pred$id_coords <- id

DO3_clustered_x <- cluster_plots(DO3_pred, cols_cluster)
DO3_y <- get_responses(DO3_clustered_x, y_fia)

DO3_n <- length(unique(y_fia[y_fia$spcd %in% colnames(DO3_y),]$spgrpcd))

DO3_pred_final <- DO3_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))

DO3_pred_mat <- apply(DO3_pred_final, 2, scale)
DO3_pred_final <- data.frame(DO3_pred_mat)

DO3_training <- split_sample(DO3_pred_final, DO3_y)
DO3_train_x <- DO3_training[[1]]
DO3_train_y <- DO3_training[[2]]
DO3_test_x <- DO3_training[[3]]
DO3_test_y <- DO3_training[[4]]
rm(DO3_pred_mat, DO3_training)

DO3_out <- train_gjam(DO3_train_x, DO3_train_y, n=DO3_n, R=5)

DO3_eval <- evaluate_model(DO3_test_x, DO3_test_y, DO3_out)
