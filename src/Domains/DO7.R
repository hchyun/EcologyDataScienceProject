DO7 <- read_csv("./outputs/plots_per_domain_7.csv")
DO7 <- DO7 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO7_pred <- join(DO7, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO7_pred <- join(DO7_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO7_pred <- DO7_pred[, !duplicated(colnames(DO7_pred))] #removing duplicated column names
DO7_pred <- DO7_pred[complete.cases(DO7_pred),]

id <- DO7_pred$id_coords
DO7_pred$id_coords <- NULL
DO7_pred$id_coords <- id

DO7_clustered_x <- cluster_plots(DO7_pred, cols_cluster)

DO7_y <- get_responses(DO7_clustered_x, y_fia)

DO7_pred_final <- DO7_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO7_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO7_pred_mat <- apply(DO7_pred_final, 2, scale)
DO7_pred_final <- data.frame(DO7_pred_mat)

DO7_training <- split_sample(DO7_pred_final, DO7_y)
DO7_train_x <- DO7_training[[1]]
DO7_train_y <- DO7_training[[2]]
DO7_test_x <- DO7_training[[3]]
DO7_test_y <- DO7_training[[4]]

DO7_out <- train_gjam(DO7_train_x, DO7_train_y)

DO7_eval <- evaluate_model(DO7_test_x, DO7_test_y, DO7_out)