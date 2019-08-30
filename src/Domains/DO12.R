DO12 <- read_csv("./outputs/plots_per_domain_12.csv")
DO12 <- DO12 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO12_pred <- join(DO12, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO12_pred <- join(DO12_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO12_pred <- DO12_pred[, !duplicated(colnames(DO12_pred))] #removing duplicated column names
DO12_pred <- DO12_pred[complete.cases(DO12_pred),]

id <- DO12_pred$id_coords
DO12_pred$id_coords <- NULL
DO12_pred$id_coords <- id

DO12_clustered_x <- cluster_plots(DO12_pred, cols_cluster)

DO12_y <- get_responses(DO12_clustered_x, y_fia)

DO12_pred_final <- DO12_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO12_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO12_pred_mat <- apply(DO12_pred_final, 2, scale)
DO12_pred_final <- data.frame(DO12_pred_mat)

DO12_training <- split_sample(DO12_pred_final, DO12_y)
DO12_train_x <- DO12_training[[1]]
DO12_train_y <- DO12_training[[2]]
DO12_test_x <- DO12_training[[3]]
DO12_test_y <- DO12_training[[4]]

DO12_out <- train_gjam(DO12_train_x, DO12_train_y)

DO12_eval <- evaluate_model(DO12_test_x, DO12_test_y, DO12_out)