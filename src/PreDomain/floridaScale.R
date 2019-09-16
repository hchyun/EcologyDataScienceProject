load_packages()

files <- c("bioclim_fia.csv", "fiaClimate.csv", "fiaResponse.csv")
data_eco <- load_data(files)
x <- get_mat(data_eco[[1]],colnames(data_eco[[1]])[-1])      #Removing index column
x_fia <- get_mat(data_eco[[2]], colnames(data_eco[[2]])[-1]) #Removing invyr column
y_fia <- get_mat(data_eco[[3]], colnames(data_eco[[3]])[-7]) #Removing invyr column
colnames(y_fia)[1] <- "count"

fl_y <- y_fia[y_fia$statecd==12,]
fl_x <- x_fia[x_fia$statecd==12,]

fl_pred <- join(fl_x, x, type="left",by=c("statecd","unitcd", "countycd","plot"),match="first")
#removing duplicate columns
fl_pred <- fl_pred[, !duplicated(colnames(fl_pred))]
#moving id_coords to the last index
id <- fl_pred$id_coords
fl_pred$id_coords <- NULL
fl_pred$id_coords <- id

cols_cluster <- c("lat", "lon")
fl_clustered_x <- cluster_plots(fl_pred, cols_cluster)

fl_y <- get_responses(fl_clustered_x, fl_y)
#Removing non environmental variables and elev is a duplicate column
fl_clustered_x <- fl_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev"))
colnames(fl_clustered_x)[3:5] <- c("slope", "aspect", "elev")

train <- sample(1:nrow(fl_y),nrow(fl_y)*0.8)
fl_train_x <- fl_clustered_x[train,]
fl_train_y <- fl_y[train,]
fl_gjam <- train_gjam(fl_train_x[,-c(12, 16)], fl_train_y[,!colnames(fl_train_y) %in% c("411","520","740")])

test_pca <- prcomp(fl_train_x)
fl_gjam <- train_gjam(data.frame(test_pca$x[,1:15]), fl_train_y[,!colnames(fl_train_y) %in% c("411","520","740")])
test_gjam <- train_gjam(fl_train_x[,c(3:5,12:ncol(fl_train_x))],fl_train_y[,!colnames(fl_train_y) %in% c("411","520","740")])
fl_test_x <- fl_clustered_x[-train,]
fl_test_y <-fl_y[-train,]
fl_newdata <- list(xdata = fl_test_x, nsim=100)
fl_prediction <- gjamPredict(output = test_gjam, newdata = fl_newdata)
fl_pred <- fl_prediction$sdList$yMu
t <- evaluate_model(fl_pred, fl_test_y[,!colnames(fl_train_y) %in% c("411","520","740")])
