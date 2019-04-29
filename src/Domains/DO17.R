DO17 <- read_csv("./outputs/plots_per_domain_17.csv")
DO17 <- DO17 %>%
  select(-c("lon.1", "lat.1", "invyr"))

DO17_pred <- join(DO17, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO17_pred <- join(DO17_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO17_pred <- DO17_pred[, !duplicated(colnames(DO17_pred))] #removing duplicated column names
DO17_pred <- DO17_pred[complete.cases(DO17_pred),]


id <- DO17_pred$id_coords
DO17_pred$id_coords <- NULL
DO17_pred$id_coords <- id

DO17_clustered_x <- cluster_plots(DO17_pred, cols_cluster)

DO17_y <- get_responses(DO17_clustered_x, y_fia)

DO17_pred_final <- DO17_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO17_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO17_pred_mat <- apply(DO17_pred_final, 2, scale)
DO17_pred_final <- data.frame(DO17_pred_mat)

DO17_training <- split_sample(DO17_pred_final, DO17_y)
DO17_train_x <- DO17_training[[1]]
DO17_train_y <- DO17_training[[2]]
DO17_test_x <- DO17_training[[3]]
DO17_test_y <- DO17_training[[4]]

DO17_out <- train_gjam(DO17_train_x, DO17_train_y)

DO17_eval <- evaluate_model(DO17_test_x, DO17_test_y, DO17_out)