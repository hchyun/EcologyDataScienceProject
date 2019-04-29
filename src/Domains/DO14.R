DO14 <- read_csv("../outputs/plots_per_domain_14.csv")
DO14 <- DO14 %>%
  select(-c("lon.1", "lat.1", "invyr"))

DO14_pred <- join(DO14, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO14_pred <- join(DO14_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO14_pred <- DO14_pred[, !duplicated(colnames(DO14_pred))] #removing duplicated column names
DO14_pred <- DO14_pred[complete.cases(DO14_pred),]


id <- DO14_pred$id_coords
DO14_pred$id_coords <- NULL
DO14_pred$id_coords <- id

DO14_clustered_x <- cluster_plots(DO14_pred, cols_cluster)

DO14_y <- get_responses(DO14_clustered_x, y_fia)

DO14_pred_final <- DO14_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO14_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO14_pred_mat <- apply(DO14_pred_final, 2, scale)
DO14_pred_final <- data.frame(DO14_pred_mat)

DO14_training <- split_sample(DO14_pred_final, DO14_y)
DO14_train_x <- DO14_training[[1]]
DO14_train_y <- DO14_training[[2]]
DO14_test_x <- DO14_training[[3]]
DO14_test_y <- DO14_training[[4]]

DO14_out <- train_gjam(DO14_train_x, DO14_train_y)

DO14_eval <- evaluate_model(DO14_test_x, DO14_test_y, DO14_out)