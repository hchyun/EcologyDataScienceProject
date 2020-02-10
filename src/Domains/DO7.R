DO7 <- read_csv("./outputs/plots_per_domain_7.csv")

colnames(DO7) <- tolower(colnames(DO7))

DO7 <- DO7 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO7_pred <- join(DO7, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO7_pred <- join(DO7_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO7_pred <- DO7_pred[, !duplicated(colnames(DO7_pred))] #removing duplicated column names
DO7_pred <- DO7_pred[complete.cases(DO7_pred),]

id <- DO7_pred$id_coords
DO7_pred$id_coords <- NULL
DO7_pred$id_coords <- id

DO7_clustered_x <- cluster_plots(DO7_pred, cols_cluster)
DO7_y <- get_responses(DO7_clustered_x, y_fia)

# DO7_y <- matrix(as.numeric(0), nrow=nrow(DO7_pred))
# DO7_y <- data.frame(DO7_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO7_pred$statecd == y_fia$statecd[i] & DO7_pred$countycd == y_fia$countycd[i] & DO7_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO7_y)) ){
#      DO7_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO7_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO7_y <- filter_sparse(DO7_y)


DO7_pred_final <- DO7_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO7_pred_final)[1:3] <- c("slope", "aspect", "elev")


DO7_pred_mat <- apply(DO7_pred_final, 2, scale)
DO7_pred_final <- data.frame(DO7_pred_mat)

DO7_training <- split_sample(DO7_pred_final, DO7_y)
DO7_train_x <- DO7_training[[1]]
DO7_train_y <- DO7_training[[2]]
DO7_test_x <- DO7_training[[3]]
DO7_test_y <- DO7_training[[4]]

DO7_out <- train_gjam(DO7_train_x, DO7_train_y)

DO7_eval <- evaluate_model(DO7_test_x, DO7_test_y, DO7_out)
