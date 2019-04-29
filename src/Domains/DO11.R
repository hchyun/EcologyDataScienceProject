DO11 <- read_csv("./outputs/plots_per_domain_11.csv")
DO11 <- DO11 %>%
  select(-c("lon.1", "lat.1", "invyr"))

DO11_pred <- join(DO11, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO11_pred <- join(DO11_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO11_pred <- DO11_pred[, !duplicated(colnames(DO11_pred))] #removing duplicated column names
DO11_pred <- DO11_pred[complete.cases(DO11_pred),]

id <- DO11_pred$id_coords
DO11_pred$id_coords <- NULL
DO11_pred$id_coords <- id

DO11_clustered_x <- cluster_plots(DO11_pred, cols_cluster)

DO11_y <- get_responses(DO11_clustered_x, y_fia)

DO11_pred_final <- DO11_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO11_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO11_pred_mat <- apply(DO11_pred_final, 2, scale)
DO11_pred_final <- data.frame(DO11_pred_mat)

DO11_training <- split_sample(DO11_pred_final, DO11_y)
DO11_train_x <- DO11_training[[1]]
DO11_train_y <- DO11_training[[2]]
DO11_test_x <- DO11_training[[3]]
DO11_test_y <- DO11_training[[4]]

DO11_out <- train_gjam(DO11_train_x, DO11_train_y)

DO11_eval <- evaluate_model(DO11_test_x, DO11_test_y, DO11_out)