DO11 <- read_csv("./outputs/plots_per_domain_11.csv")
DO11 <- DO11 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO11_pred <- join(DO11, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO11_pred <- join(DO11_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO11_pred <- DO11_pred[, !duplicated(colnames(DO11_pred))] #removing duplicated column names
DO11_pred <- DO11_pred[complete.cases(DO11_pred),]

id <- DO11_pred$id_coords
DO11_pred$id_coords <- NULL
DO11_pred$id_coords <- id

DO11_clustered_x <- cluster_plots(DO11_pred, cols_cluster)
DO11_y <- get_responses(DO11_clustered_x, y_fia)

# DO11_y <- matrix(as.numeric(0), nrow=nrow(DO11_pred))
# DO11_y <- data.frame(DO11_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO11_pred$statecd == y_fia$statecd[i] & DO11_pred$countycd == y_fia$countycd[i] & DO11_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO11_y)) ){
#      DO11_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO11_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO11_y <- filter_sparse(DO11_y)

DO11_pred_final <- DO11_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","watercd","physclcd"))
#colnames(DO11_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO11_pred_mat <- apply(DO11_pred_final, 2, scale)
DO11_pred_final <- data.frame(DO11_pred_mat)

DO11_training <- split_sample(DO11_pred_final, DO11_y)
DO11_train_x <- DO11_training[[1]]
DO11_train_y <- DO11_training[[2]]
DO11_test_x <- DO11_training[[3]]
DO11_test_y <- DO11_training[[4]]

DO11_out <- train_gjam(DO11_train_x, DO11_train_y)

DO11_eval <- evaluate_model(DO11_test_x, DO11_test_y, DO11_out)