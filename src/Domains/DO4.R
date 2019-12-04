DO4 <- read_csv("./outputs/plots_per_domain_4.csv")
DO4 <- DO4 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO4_pred <- join(DO4, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO4_pred <- join(DO4_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO4_pred <- DO4_pred[, !duplicated(colnames(DO4_pred))] #removing duplicated column names
DO4_pred <- DO4_pred[complete.cases(DO4_pred),]

id <- DO4_pred$id_coords
DO4_pred$id_coords <- NULL
DO4_pred$id_coords <- id

DO4_clustered_x <- cluster_plots(DO4_pred, cols_cluster)
DO4_y <- get_responses(DO4_clustered_x, y_fia)

# DO4_y <- matrix(as.numeric(0), nrow=nrow(DO4_pred))
# DO4_y <- data.frame(DO4_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO4_pred$statecd == y_fia$statecd[i] & DO4_pred$countycd == y_fia$countycd[i] & DO4_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO4_y)) ){
#      DO4_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO4_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO4_y <- filter_sparse(DO4_y)


DO4_pred_final <- DO4_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","watercd","physclcd"))
#colnames(DO4_pred_final)[1:3] <- c("slope", "aspect", "elev")


DO4_pred_mat <- apply(DO4_pred_final, 2, scale)
DO4_pred_final <- data.frame(DO4_pred_mat)
DO4_training <- split_sample(DO4_pred_final, DO4_y)
DO4_train_x <- DO4_training[[1]]
DO4_train_y <- DO4_training[[2]]
DO4_test_x <- DO4_training[[3]]
DO4_test_y <- DO4_training[[4]]

DO4_out <- train_gjam(DO4_train_x, DO4_train_y)

DO4_eval <- evaluate_model(DO4_test_x, DO4_test_y, DO4_out)