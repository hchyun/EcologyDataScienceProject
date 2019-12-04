DO3 <- read_csv("./outputs/plots_per_domain_3.csv")
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

# DO3_y <- matrix(as.numeric(0), nrow=nrow(DO3_pred))
# DO3_y <- data.frame(DO3_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO3_pred$statecd == y_fia$statecd[i] & DO3_pred$countycd == y_fia$countycd[i] & DO3_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO3_y)) ){
#      DO3_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO3_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO3_y <- filter_sparse(DO3_y)


DO3_pred_final <- DO3_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","watercd","physclcd"))
#colnames(DO3_pred_final)[1:3] <- c("slope", "aspect", "elev")


DO3_pred_mat <- apply(DO3_pred_final, 2, scale)
DO3_pred_final <- data.frame(DO3_pred_mat)

DO3_training <- split_sample(DO3_pred_final, DO3_y)
DO3_train_x <- DO3_training[[1]]
DO3_train_y <- DO3_training[[2]]
DO3_test_x <- DO3_training[[3]]
DO3_test_y <- DO3_training[[4]]

DO3_out <- train_gjam(DO3_train_x, DO3_train_y)

DO3_eval <- evaluate_model(DO3_test_x, DO3_test_y, DO3_out)
