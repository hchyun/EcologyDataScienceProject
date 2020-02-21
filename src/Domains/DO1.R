DO1 <- read_csv("./outputs/plots_per_domain_1.csv")
DO1 <- DO1 %>%
  dplyr::select(-c("LON.1", "LAT.1", "INVYR"))

colnames(DO1) <- tolower(colnames(DO1))

DO1_pred <- join(DO1, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO1_pred <- join(DO1_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO1_pred <- DO1_pred[, !duplicated(colnames(DO1_pred))] #removing duplicated column names
DO1_pred <- DO1_pred[complete.cases(DO1_pred),]

id <- DO1_pred$id_coords
DO1_pred$id_coords <- NULL
DO1_pred$id_coords <- id

DO1_clustered_x <- cluster_plots(DO1_pred, cols_cluster)
DO1_y <- get_responses(DO1_clustered_x, y_fia)

DO1_n <- length(unique(y_fia[y_fia$spcd %in% colnames(DO1_y),]$spgrpcd))

DO1_pred_final <- DO1_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO1_pred_final)[1:3] <- c("slope", "aspect", "elev")


DO1_pred_mat <- apply(DO1_pred_final, 2, scale)
DO1_pred_final <- data.frame(DO1_pred_mat)
DO1_training <- split_sample(DO1_pred_final, DO1_y)
DO1_train_x <- DO1_training[[1]]
DO1_train_y <- DO1_training[[2]]
DO1_test_x <- DO1_training[[3]]
DO1_test_y <- DO1_training[[4]]

DO1_out <- train_gjam(DO1_train_x, DO1_train_y, n=DO1_n, R=5)

DO1_eval <- evaluate_model(DO1_test_x, DO1_test_y, DO1_out)
