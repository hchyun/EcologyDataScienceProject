DO10 <- read_csv("./outputs/plots_per_domain_10.csv")

colnames(DO10) <- tolower(colnames(DO10))

DO10 <- DO10 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO10_pred <- join(DO10, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO10_pred <- join(DO10_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO10_pred <- DO10_pred[, !duplicated(colnames(DO10_pred))] #removing duplicated column names
DO10_pred <- DO10_pred[complete.cases(DO10_pred),]

id <- DO10_pred$id_coords
DO10_pred$id_coords <- NULL
DO10_pred$id_coords <- id

DO10_clustered_x <- cluster_plots(DO10_pred, cols_cluster)
DO10_y <- get_responses(DO10_clustered_x, y_fia)

# DO10_y <- matrix(as.numeric(0), nrow=nrow(DO10_pred))
# DO10_y <- data.frame(DO10_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO10_pred$statecd == y_fia$statecd[i] & DO10_pred$countycd == y_fia$countycd[i] & DO10_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO10_y)) ){
#      DO10_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO10_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO10_y <- filter_sparse(DO10_y)

DO10_pred_final <- DO10_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO10_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO10_pred_mat <- apply(DO10_pred_final, 2, scale)
DO10_pred_final <- data.frame(DO10_pred_mat)

DO10_training <- split_sample(DO10_pred_final, DO10_y)
DO10_train_x <- DO10_training[[1]]
DO10_train_y <- DO10_training[[2]]
DO10_test_x <- DO10_training[[3]]
DO10_test_y <- DO10_training[[4]]

DO10_out <- train_gjam(DO10_train_x, DO10_train_y)

DO10_eval <- evaluate_model(DO10_test_x, DO10_test_y, DO10_out)
