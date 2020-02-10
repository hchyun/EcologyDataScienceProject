DO6 <- read_csv("./outputs/plots_per_domain_6.csv")
colnames(DO6) <- tolower(colnames(DO6))

DO6 <- DO6 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO6_pred <- join(DO6, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO6_pred <- join(DO6_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO6_pred <- DO6_pred[, !duplicated(colnames(DO6_pred))] #removing duplicated column names
DO6_pred <- DO6_pred[complete.cases(DO6_pred),]

id <- DO6_pred$id_coords
DO6_pred$id_coords <- NULL
DO6_pred$id_coords <- id

DO6_clustered_x <- cluster_plots(DO6_pred, cols_cluster)
DO6_y <- get_responses(DO6_clustered_x, y_fia)

# DO6_y <- matrix(as.numeric(0), nrow=nrow(DO6_pred))
# DO6_y <- data.frame(DO6_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO6_pred$statecd == y_fia$statecd[i] & DO6_pred$countycd == y_fia$countycd[i] & DO6_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO6_y)) ){
#      DO6_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO6_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO6_y <- filter_sparse(DO6_y)


DO6_pred_final <- DO6_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO6_pred_final)[1:3] <- c("slope", "aspect", "elev")


DO6_pred_mat <- apply(DO6_pred_final, 2, scale)
DO6_pred_final <- data.frame(DO6_pred_mat)

DO6_training <- split_sample(DO6_pred_final, DO6_y)
DO6_train_x <- DO6_training[[1]]
DO6_train_y <- DO6_training[[2]]
DO6_test_x <- DO6_training[[3]]

DO6_test_y <- DO6_training[[4]]

DO6_out <- train_gjam(DO6_train_x, DO6_train_y)

DO6_eval <- evaluate_model(DO6_test_x, DO6_test_y, DO6_out)
