DO6 <- read_csv("./outputs/plots_per_domain_6.csv")
DO6 <- DO6 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO6_pred <- join(DO6, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO6_pred <- DO6_pred[, !duplicated(colnames(DO6_pred))] #removing duplicated column names
DO6_pred <- DO6_pred[complete.cases(DO6_pred),]
DO6_pred <- join(DO6_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")


id <- DO6_pred$id_coords
DO6_pred$id_coords <- NULL
DO6_pred$id_coords <- id

DO6_clustered_x <- cluster_plots(DO6_pred, cols_cluster)

DO6_y <- get_responses(DO6_clustered_x, y_fia)

DO6_pred_final <- DO6_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO6_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO6_pred_mat <- apply(DO6_pred_final, 2, scale)
DO6_pred_final <- data.frame(DO6_pred_mat)

DO6_training <- split_sample(DO6_pred_final, DO6_y)
DO6_train_x <- DO6_training[[1]]
DO6_train_y <- DO6_training[[2]]
DO6_test_x <- DO6_training[[3]]
DO6_test_y <- DO6_training[[4]]

DO6_out <- train_gjam(DO6_train_x, DO6_train_y)

DO6_eval <- evaluate_model(DO6_test_x, DO6_test_y, DO6_out)