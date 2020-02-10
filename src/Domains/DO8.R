DO8 <- read_csv("./outputs/plots_per_domain_8.csv")

colnames(DO8) <- tolower(colnames(DO8))

DO8 <- DO8 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO8_pred <- join(DO8, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO8_pred <- join(DO8_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO8_pred <- DO8_pred[, !duplicated(colnames(DO8_pred))] #removing duplicated column names
DO8_pred <- DO8_pred[complete.cases(DO8_pred),]

id <- DO8_pred$id_coords
DO8_pred$id_coords <- NULL
DO8_pred$id_coords <- id

DO8_clustered_x <- cluster_plots(DO8_pred, cols_cluster)
DO8_y <- get_responses(DO8_clustered_x, y_fia)

# DO8_y <- matrix(as.numeric(0), nrow=nrow(DO8_pred))
# DO8_y <- data.frame(DO8_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO8_pred$statecd == y_fia$statecd[i] & DO8_pred$countycd == y_fia$countycd[i] & DO8_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO8_y)) ){
#      DO8_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO8_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO8_y <- filter_sparse(DO8_y)


DO8_pred_final <- DO8_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO8_pred_final)[1:3] <- c("slope", "aspect", "elev")


DO8_pred_mat <- apply(DO8_pred_final, 2, scale)
DO8_pred_final <- data.frame(DO8_pred_mat)

DO8_training <- split_sample(DO8_pred_final, DO8_y)
DO8_train_x <- DO8_training[[1]]
DO8_train_y <- DO8_training[[2]]
DO8_test_x <- DO8_training[[3]]
DO8_test_y <- DO8_training[[4]]

DO8_out <- train_gjam(DO8_train_x, DO8_train_y)

DO8_eval <- evaluate_model(DO8_test_x, DO8_test_y, DO8_out)