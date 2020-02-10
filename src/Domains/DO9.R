DO9 <- read_csv("./outputs/plots_per_domain_9.csv")

colnames(DO9) <- tolower(colnames(DO9))

DO9 <- DO9 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO9_pred <- join(DO9, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO9_pred <- join(DO9_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO9_pred <- DO9_pred[, !duplicated(colnames(DO9_pred))] #removing duplicated column names
DO9_pred <- DO9_pred[complete.cases(DO9_pred),]

id <- DO9_pred$id_coords
DO9_pred$id_coords <- NULL
DO9_pred$id_coords <- id

DO9_clustered_x <- cluster_plots(DO9_pred, cols_cluster)
DO9_y <- get_responses(DO9_clustered_x, y_fia)

# DO9_y <- matrix(as.numeric(0), nrow=nrow(DO9_pred))
# DO9_y <- data.frame(DO9_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO9_pred$statecd == y_fia$statecd[i] & DO9_pred$countycd == y_fia$countycd[i] & DO9_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO9_y)) ){
#      DO9_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO9_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO9_y <- filter_sparse(DO9_y)

DO9_pred_final <- DO9_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO9_pred_final)[1:3] <- c("slope", "aspect", "elev")


DO9_pred_mat <- apply(DO9_pred_final, 2, scale)
DO9_pred_final <- data.frame(DO9_pred_mat)
DO9_training <- split_sample(DO9_pred_final, DO9_y)
DO9_train_x <- DO9_training[[1]]
DO9_train_y <- DO9_training[[2]]
DO9_test_x <- DO9_training[[3]]
DO9_test_y <- DO9_training[[4]]

DO9_out <- train_gjam(DO9_train_x, DO9_train_y)

DO9_eval <- evaluate_model(DO9_test_x, DO9_test_y, DO9_out)
