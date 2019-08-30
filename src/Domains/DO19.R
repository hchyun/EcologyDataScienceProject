DO19 <- read_csv("./outputs/plots_per_domain_19.csv")
DO19 <- DO19 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO19_pred <- join(DO19, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO19_pred <- join(DO19_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO19_pred <- DO19_pred[, !duplicated(colnames(DO19_pred))] #removing duplicated column names
DO19_pred <- DO19_pred[complete.cases(DO19_pred),]

id <- DO19_pred$id_coords
DO19_pred$id_coords <- NULL
DO19_pred$id_coords <- id

DO19_clustered_x <- cluster_plots(DO19_pred, cols_cluster)

DO19_y <- get_responses(DO19_clustered_x, y_fia)

DO19_pred_final <- DO19_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr","mat","mdr","ts","mtw","mtc","mtwet","mtdry","mtwarm","mtcold","prec","precwet","precdry","precseason","precwec_quart","precdry_quart"))
colnames(DO19_pred_final)[1:3] <- c("slope", "aspect", "elev")
DO19_pred_mat <- apply(DO19_pred_final, 2, scale)
DO19_pred_final <- data.frame(DO19_pred_mat)

DO19_training <- split_sample(DO19_pred_final, DO19_y)
DO19_train_x <- DO19_training[[1]]
DO19_train_y <- DO19_training[[2]]
DO19_test_x <- DO19_training[[3]]
DO19_test_y <- DO19_training[[4]]

DO19_out <- train_gjam(DO19_train_x, DO19_train_y)

DO19_eval <- evaluate_model(DO19_test_x, DO19_test_y, DO19_out)