DO15 <- read_csv("./outputs/plots_per_domain_15.csv")

colnames(DO15) <- tolower(colnames(DO15))

DO15 <- DO15 %>%
  dplyr::select(-c("lon.1", "lat.1", "invyr"))

DO15_pred <- join(DO15, cont_pred, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
DO15_pred <- join(DO15_pred, daymet_used, type="left", by=c("statecd","unitcd","countycd","plot"), match="first")
DO15_pred <- DO15_pred[, !duplicated(colnames(DO15_pred))] #removing duplicated column names
DO15_pred <- DO15_pred[complete.cases(DO15_pred),]

id <- DO15_pred$id_coords
DO15_pred$id_coords <- NULL
DO15_pred$id_coords <- id

DO15_clustered_x <- cluster_plots(DO15_pred, cols_cluster)
DO15_y <- get_responses(DO15_clustered_x, y_fia)

# DO15_y <- matrix(as.numeric(0), nrow=nrow(DO15_pred))
# DO15_y <- data.frame(DO15_y)

# for(i in 1:nrow(y_fia)){
#  ind <- which(DO15_pred$statecd == y_fia$statecd[i] & DO15_pred$countycd == y_fia$countycd[i] & DO15_pred$plot == y_fia$plot[i])
#  if(!identical(ind,integer(0))){
#    if(! (y_fia$spcd[i] %in% colnames(DO15_y)) ){
#      DO15_y[,as.character(y_fia$spcd[i])] <- 0
#    }
#    DO15_y[ind, as.character(y_fia$spcd[i])] <- as.numeric(y_fia$count[i])
#  }
# }

# DO15_y <- filter_sparse(DO15_y)


DO15_pred_final <- DO15_clustered_x %>%
  dplyr::select(-c("statecd", "unitcd", "countycd","id_coords","plot","lat","lon","invyr","physclcd"))
#colnames(DO15_pred_final)[1:3] <- c("slope", "aspect", "elev")

DO15_pred_mat <- apply(DO15_pred_final, 2, scale)
DO15_pred_final <- data.frame(DO15_pred_mat)

DO15_training <- split_sample(DO15_pred_final, DO15_y)
DO15_train_x <- DO15_training[[1]]
DO15_train_y <- DO15_training[[2]]
DO15_test_x <- DO15_training[[3]]
DO15_test_y <- DO15_training[[4]]

DO15_out <- train_gjam(DO15_train_x, DO15_train_y)

DO15_eval <- evaluate_model(DO15_test_x, DO15_test_y, DO15_out)