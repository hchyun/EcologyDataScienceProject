DO14 <- read_csv("./outputs/plots_per_domain_14.csv")

colnames(DO14) <- tolower(colnames(DO14))

DO14 <- DO14 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO14_pred <- join(DO14, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO14_pred <- join(DO14_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO14_pred <- DO14_pred[, !duplicated(colnames(DO14_pred))] #removing duplicated column names
DO14_pred <- DO14_pred[complete.cases(DO14_pred),]

id <- DO14_pred$id_coords
DO14_pred$id_coords <- NULL
DO14_pred$id_coords <- id

DO14_clustered_x <- cluster_plots(DO14_pred, cols_cluster)
DO14_y <- get_responses(DO14_clustered_x, y_fia)

# DO14_y <- matrix(as.numeric(0), nrow=nrow(DO14_pred))
# DO14_y <- data.frame(DO14_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO14_pred$statecd == y_fia$statecd[i] & DO14_pred$countycd == y_fia$countycd[i] & DO14_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO14_y)) ){
#      DO14_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO14_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO14_y <- filter_sparse(DO14_y)

DO14_pred_final <- DO14_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO14_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO14_pred_mat <- apply(DO14_pred_final, 2, scale)
DO14_pred_final <- data.frame(DO14_pred_mat)

DO14_training <- split_sample(DO14_pred_final, DO14_y)
DO14_train_x <- DO14_training[[1]]
DO14_train_y <- DO14_training[[2]]
DO14_test_x <- DO14_training[[3]]
DO14_test_y <- DO14_training[[4]]

DO14_out <- train_gjam(DO14_train_x, DO14_train_y)

DO14_eval <- evaluate_model(DO14_test_x, DO14_test_y, DO14_out)