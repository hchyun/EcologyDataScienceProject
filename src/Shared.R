library(maptools)
library(sp)
library(rgdal)
load_packages()


subscales_fia("../data/fiaClimate.csv")
daymet <- read_csv("../data/climate_daymet.csv")
daymet_used <- daymet[,c("countycd", "unitcd","statecd","plot","daylength_3", "daylength_4","daylength_10","prec_6","prec_7","rad_8","tmax_8","tmin_1")]

files <- c("../data/bioclim_fia.csv", "../data/fiaClimate.csv", "../data/fiaResponse.csv")
data_eco <- load_data(files)

x <- get_mat(data_eco[[1]],colnames(data_eco[[1]])[-1])   #Getting rid of row indexer column
x_fia <- get_mat(data_eco[[2]], colnames(data_eco[[2]]))
y_fia <- get_mat(data_eco[[3]], colnames(data_eco[[3]]))

colnames(y_fia)[1] <- "count"
cont_y <- y_fia
cont_x <- x_fia

cont_pred <- join(x_fia, x, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")
cont_pred <- cont_pred[, !duplicated(colnames(cont_pred))] #removing duplicated column names
cont_pred <- cont_pred[complete.cases(cont_pred),]

#moving id_coords to the last column of the dataframe
id <- cont_pred$id_coords
cont_pred$id_coords <- NULL
cont_pred$id_coords <- id

cols_cluster <- c("lat", "lon")
cont_clustered_x <- cluster_plots(cont_pred, cols_cluster)

cont_y <- get_responses(cont_clustered_x, y_fia)

cont_pred_final <- cont_clustered_x %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred)[1:3] <- c("slope", "aspect", "elev")

spcd_code <- read.csv("../data/spcd.csv")


