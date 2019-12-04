#Cross scale components


temporal_fia <- read.csv("../data/temporal_fia.csv")

temporal_fia <- temporal_fia %>%
  filter(!temporal_fia$spcd %in% c(998,999))
temporal_fia$id_coords <- paste(temporal_fia$statecd, temporal_fia$countycd, temporal_fia$plot, sep='_')

temporal_fia2 <- join(temporal_fia, cont_x, type="left",by=c("statecd","unitcd","countycd","plot"),match="first")

years <- split(temporal_fia, f=temporal_fia$invyr)

find_plots <- function(year_list, data){
  same_plots <- c()
  for(i in 1:length(year_list)){
    if(i == 1){
      same_plots <- data[[as.character(year_list[i])]]$id_coords
    }else{
      same_plots <- intersect(same_plots,data[[as.character(year_list[i])]]$id_coords)
    }
  }
  
  return(same_plots)
}

overlap <- find_plots(c(2000,2005,2010,2015), years)

temporal_fia_2000 <- years$`2000` %>%
  filter(years$`2000`$id_coords %in% overlap)

temporal_fia_2005 <- years$`2005` %>%
  filter(years$`2005`$id_coords %in% overlap)

temporal_fia_2010 <- years$`2010` %>%
  filter(years$`2010`$id_coords %in% overlap)

temporal_fia_2015 <- years$`2015` %>%
  filter(years$`2015`$id_coords %in% overlap)

colnames(temporal_fia_2000)[1] <- "count"
colnames(temporal_fia_2005)[1] <- "count"
colnames(temporal_fia_2010)[1] <- "count"
colnames(temporal_fia_2015)[1] <- "count"

time_abundance <- function(data, spc_interest){
  counts <- c()
  for(i in 1:length(data)){
    counts <- c(counts, sum(data[[i]][data[[i]]$spcd==spc_interest,'count']))
  }
  plot(x=c('2000','2005','2010','2015'),y=counts, type='o',col='green')
}

spci_i <- 12
plot(x=c(temporal_fia_2000[temporal_fia_2000$spcd==spci_i,]$invyr,temporal_fia_2005[temporal_fia_2005$spcd==spci_i,]$invyr,
         temporal_fia_2010[temporal_fia_2010$spcd==spci_i,]$invyr,temporal_fia_2015[temporal_fia_2015$spcd==spci_i,]$invyr),
     y=c(temporal_fia_2000[temporal_fia_2000$spcd==spci_i,]$count,temporal_fia_2005[temporal_fia_2005$spcd==spci_i,]$count,
         temporal_fia_2010[temporal_fia_2010$spcd==spci_i,]$count,temporal_fia_2015[temporal_fia_2015$spcd==spci_i,]$count), xlab='years', ylab='count')
dim(temporal_fia_2015[temporal_fia_2015==spci_i,])
time_abundance(list(temporal_fia_2000,temporal_fia_2005,temporal_fia_2010,temporal_fia_2015), 12)


cont_pred$id_coords2 <- paste(cont_pred$statecd, cont_pred$countycd, cont_pred$plot, sep="_")
#2000 Predictor setup
cont_pred_2000 <- get_cont_pred_year(2000, cont_pred[cont_pred$id_coords2 %in% overlap,], daymet)
#2005 Predictor setup
cont_pred_2005 <- get_cont_pred_year(2005, cont_pred[cont_pred$id_coords2 %in% overlap,], daymet)
#2010 Predictor setup
cont_pred_2010 <- get_cont_pred_year(2010, cont_pred[cont_pred$id_coords2 %in% overlap,], daymet)
#2015 Predictor setup
cont_pred_2015 <- get_cont_pred_year(2015, cont_pred[cont_pred$id_coords2 %in% overlap,],daymet)

cont_pred$id_coords2 <- NULL


cont_pred_2000 <- cont_pred_2000 %>%
  group_by(statecd, countycd) %>%
  dplyr::mutate(tmin_1_county = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_county = mean(tmax_8), prec_6_county = mean(prec_6), prec7_county = mean(prec_7), rad_8_county = mean(rad_8))

cont_pred_2005 <- cont_pred_2005 %>%
  group_by(statecd, countycd) %>%
  dplyr::mutate(tmin_1_county = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_county = mean(tmax_8), prec_6_county = mean(prec_6), prec7_county = mean(prec_7), rad_8_county = mean(rad_8))

cont_pred_2010 <- cont_pred_2010 %>%
  group_by(statecd, countycd) %>%
  dplyr::mutate(tmin_1_county = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_county = mean(tmax_8), prec_6_county = mean(prec_6), prec7_county = mean(prec_7), rad_8_county = mean(rad_8))

cont_pred_2015 <- cont_pred_2015 %>%
  group_by(statecd, countycd) %>%
  dplyr::mutate(tmin_1_county = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_county = mean(tmax_8), prec_6_county = mean(prec_6), prec7_county = mean(prec_7), rad_8_county = mean(rad_8))


cont_pred_2000 <- cont_pred_2000 %>%
  group_by(statecd) %>%
  dplyr::mutate(tmin_1_state = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_state = mean(tmax_8), prec_6_state = mean(prec_6), prec7_state = mean(prec_7), rad_8_state = mean(rad_8))

cont_pred_2005 <- cont_pred_2005 %>%
  group_by(statecd) %>%
  dplyr::mutate(tmin_1_state = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_state = mean(tmax_8), prec_6_state = mean(prec_6), prec7_state = mean(prec_7), rad_8_state = mean(rad_8))

cont_pred_2010 <- cont_pred_2010 %>%
  group_by(statecd) %>%
  dplyr::mutate(tmin_1_state = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_state = mean(tmax_8), prec_6_state = mean(prec_6), prec7_state = mean(prec_7), rad_8_state = mean(rad_8))


cont_pred_2015 <- cont_pred_2015 %>%
  group_by(statecd) %>%
  dplyr::mutate(tmin_1_state = mean(tmin_1[!is.infinite(tmin_1)]), tmax_8_state = mean(tmax_8), prec_6_state = mean(prec_6), prec7_state = mean(prec_7), rad_8_state = mean(rad_8))

id_2000 <- cont_pred_2000$id_coords
cont_pred_2000$id_coords <- NULL
cont_pred_2000$id_coords <- id_2000

id_2005 <- cont_pred_2005$id_coords
cont_pred_2005$id_coords <- NULL
cont_pred_2005$id_coords <- id_2005

cont_pred_2010$id_coords <- NULL
cont_pred_2010$id_coords <- id_2010

id_2015 <- cont_pred_2015$id_coords
cont_pred_2015$id_coords <- NULL
cont_pred_2015$id_coords <- id_2015

cont_pred_2000_clustered <- cluster_plots(cont_pred_2000, cols_cluster)
cont_pred_2005_clustered <- cluster_plots(cont_pred_2005, cols_cluster)
cont_pred_2015_clustered <- cluster_plots(cont_pred_2015, cols_cluster)

cont_pred_2000_clustered <- cont_pred_2000_clustered[!is.infinite(cont_pred_2000_clustered$tmax_8) & !is.infinite(cont_pred_2000_clustered$tmin_1),]
cont_pred_2005_clustered <- cont_pred_2005_clustered[!is.infinite(cont_pred_2005_clustered$tmax_8) & !is.infinite(cont_pred_2005_clustered$tmin_1),]
cont_pred_2015_clustered <- cont_pred_2015_clustered[!is.infinite(cont_pred_2015_clustered$tmax_8) & !is.infinite(cont_pred_2015_clustered$tmin_1),]


cont_y_2000 <- get_responses(cont_pred_2000_clustered, temporal_fia_2000)
cont_y_2005 <- get_responses(cont_pred_2005_clustered, temporal_fia_2005)
cont_y_2015 <- get_responses(cont_pred_2015_clustered, temporal_fia_2015)
intersect_spc <- intersect(intersect(colnames(cont_y_2000), colnames(cont_y_2005)), colnames(cont_y_2015))
cont_y_2000 <- cont_y_2000[,intersect_spc]
cont_y_2005 <- cont_y_2005[,intersect_spc]
cont_y_2015 <- cont_y_2015[,intersect_spc]

cont_pred_2000_final <- cont_pred_2000_clustered %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred_2000_final)[1:3] <- c("slope", "aspect", "elev")

cont_pred_2005_final <- cont_pred_2005_clustered %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred_2005_final)[1:3] <- c("slope", "aspect", "elev")

cont_pred_2015_final <- cont_pred_2015_clustered %>%
  dplyr::select(-c("statecd","unitcd", "countycd","id_coords","plot","elev","lat","lon","isoth","trange","preccold_quart","precwarm_quart","invyr"))
colnames(cont_pred_2015_final)[1:3] <- c("slope", "aspect", "elev")

col_select<- c(col_x, c('tmin_1_county','tmin_1_state','tmax_8_county', 'tmax_8_state',"prec_6_county", "prec7_county","rad_8_county","prec_6_state",  "prec7_state","rad_8_state" ))

cont_pred_2000_final <- cont_pred_2000_final[,col_select]
cont_pred_2000_mat <- apply(cont_pred_2000_final, 2, scale)
cont_pred_2000_final <- data.frame(cont_pred_2000_mat)

cont_pred_2005_final <- cont_pred_2005_final[,col_select]
cont_pred_2005_mat <- apply(cont_pred_2005_final, 2, scale)
cont_pred_2005_final <- data.frame(cont_pred_2005_mat)

cont_pred_2015_final <- cont_pred_2015_final[,col_select]
cont_pred_2015_mat <- apply(cont_pred_2015_final, 2, scale)
cont_pred_2015_final <- data.frame(cont_pred_2015_mat)

spcd_genus <- spcd_code[spcd_code$spcd %in% colnames(cont_y_2005),c('genus', 'species')]
spcd_genus$full <- paste(spcd_genus$genus, spcd_genus$species, sep=' ')
colnames(cont_y_2000) <- spcd_genus$full
colnames(cont_y_2005) <- spcd_genus$full
colnames(cont_y_2015) <- spcd_genus$full

cont_out_2000 <- train_gjam(cont_pred_2000_final, cont_y_2000)
cont_out_2005 <- train_gjam(cont_pred_2005_final, cont_y_2005)
cont_out_2015 <- train_gjam(cont_pred_2015_final, cont_y_2015)

cont_eval_2000 <- evaluate_model(cont_pred_2005_final, cont_y_2005, cont_out_2000)
cont_eval_200015 <- evaluate_model(cont_pred_2015_final, cont_y_2015, cont_out_2000)

plt_2000 <- gjamPlot(output=cont_out_2000)
gjamPlot(output=cont_out_2005)
gjamPlot(output=cont_out_2015)

specNames <- colnames(cont_y_2000)
specColor <- rep('black',ncol(cont_y_2000))
specColor[ c(grep('Quer',specNames),grep('Cary',specNames)) ] <- 'brown'
specColor[ c(grep('Acer',specNames),grep('Frax',specNames)) ] <- 'darkgreen'
specColor[ c(grep('Abie',specNames),grep('Pice',specNames)) ] <- 'blue'
specColor[ c(grep('Pinu', specNames), grep('Magn',specNames))] <- 'yellow'

pl   <- list(GRIDPLOTS=T, specColor = specColor)
gjamPlot(output = cont_out_2000, plotPars = pl)

#report either sig or cor
samples <- sample(1:185, 12)
test <- r1
test <- test[tsamp,tsamp]
test[lower.tri(test, diag=T)] <- NA
plot(test)

tsamp <- intersect(colnames(DO1_y), intersect(intersect(colnames(DO2_y), colnames(DO7_y)), colnames(DO8_y)))
tsamp <- sample(tsamp, 12)
ds <- c(1,2,7,8, 'cont')
colsn <- c(list(colnames(DO1_out$parameters$sigMu)),list(colnames(DO2_out$parameters$sigMu)),list(colnames(DO7_out$parameters$sigMu)),list(colnames(DO8_out$parameters$sigMu)), list(colnames(cont_out$parameters$sigMu))   )
cormus <- c(list(DO1_out$parameters$corMu),list(DO2_out$parameters$corMu),list(DO7_out$parameters$corMu),list(DO8_out$parameters$corMu), list(cont_out$parameters$corMu))
for(i in 1:5){
  test <- cormus[[i]]
  test <- test[which(colsn[[i]] %in% tsamp),which(colsn[[i]] %in% tsamp)]
  colnames(test) <- tsamp
  rownames(test) <- tsamp
  test[lower.tri(test, diag=T)] <- NA
  plot(test, xlab='spc', ylab='spc',main=paste('Correlation', ds[i]))
}

