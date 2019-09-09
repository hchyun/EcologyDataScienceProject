DO1 <- read_csv("./outputs/plots_per_domain_1.csv")
DO1 <- DO1 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO1_pred <- join(DO1, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO1_pred <- join(DO1_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO1_pred <- DO1_pred[, !duplicated(colnames(DO1_pred))] #removing duplicated column names
DO1_pred <- DO1_pred[complete.cases(DO1_pred),]

id <- DO1_pred$id_coords
DO1_pred$id_coords <- NULL
DO1_pred$id_coords <- id

DO1_clustered_x <- cluster_plots(DO1_pred, cols_cluster)

DO1_y <- get_responses(DO1_clustered_x, y_fia)

DO1_pred_final <- DO1_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO1_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO1_pred_mat <- apply(DO1_pred_final, 2, scale)
DO1_pred_final <- data.frame(DO1_pred_mat)
DO1_training <- split_sample(DO1_pred_final, DO1_y)
DO1_train_x <- DO1_training[[1]]
DO1_train_y <- DO1_training[[2]]
DO1_test_x <- DO1_training[[3]]
DO1_test_y <- DO1_training[[4]]

DO1_out <- train_gjam(DO1_train_x, DO1_train_y)

DO1_eval <- evaluate_model(DO1_test_x, DO1_test_y, DO1_out)