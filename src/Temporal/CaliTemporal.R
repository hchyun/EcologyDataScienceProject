cont_pred_cali_2000 <- cont_pred_2000[cont_pred_2000$statecd == 6, ]
cont_pred_cali_2005 <- cont_pred_2005[cont_pred_2005$statecd == 6, ]
cont_pred_cali_2015 <- cont_pred_2015[cont_pred_2015$statecd == 6, ]

temporal_fia_cali_2000 <- temporal_fia_2000[temporal_fia_2000$statecd == 6, ]
temporal_fia_cali_2005 <- temporal_fia_2005[temporal_fia_2005$statecd == 6, ]
temporal_fia_cali_2015 <- temporal_fia_2015[temporal_fia_2015$statecd == 6, ]

spc_cali <- sort(unique(temporal_fia_cali_2005$spcd))
cali_y_2005 <- matrix(as.numeric(0), ncol=length(spc_cali), nrow=nrow(cont_pred_cali_2005))
cali_y_2005 <- data.frame(cali_y_2005)
colnames(cali_y_2005) <- spc_cali

for(i in 1:nrow(temporal_fia_cali_2005)){
 ind <- which(cont_pred_cali_2005$countycd == temporal_fia_cali_2005$countycd[i] & cont_pred_cali_2005$plot == temporal_fia_cali_2005$plot[i])
 if(!identical(ind,integer(0))){
   cali_y_2005[ind, as.character(temporal_fia_cali_2005$spcd[i])] <- as.numeric(temporal_fia_cali_2005$count[i])
 }
}
cali_y_2005 <- cali_y_2005[,!apply(cali_y_2005, 2, sum)==0]
cont_pred_cali_2005 <- cont_pred_cali_2005[as.logical(rowSums(cali_y_2005 != 0)), ]
cali_y_2005 <- cali_y_2005[as.logical(rowSums(cali_y_2005 != 0)), ]

spc_cali <- sort(unique(temporal_fia_cali_2015$spcd))
cali_y_2015 <- matrix(as.numeric(0), ncol=length(spc_cali), nrow=nrow(cont_pred_cali_2015))
cali_y_2015 <- data.frame(cali_y_2015)
colnames(cali_y_2015) <- spc_cali

for(i in 1:nrow(temporal_fia_cali_2015)){
  ind <- which(cont_pred_cali_2015$countycd == temporal_fia_cali_2015$countycd[i] & cont_pred_cali_2015$plot == temporal_fia_cali_2015$plot[i])
  if(!identical(ind,integer(0))){
    cali_y_2015[ind, as.character(temporal_fia_cali_2015$spcd[i])] <- as.numeric(temporal_fia_cali_2015$count[i])
  }
}
cali_y_2015 <- cali_y_2015[,!apply(cali_y_2015, 2, sum)==0]
cont_pred_cali_2015 <- cont_pred_cali_2015[as.logical(rowSums(cali_y_2005 != 0)), ]
cali_y_2015 <- cali_y_2015[as.logical(rowSums(cali_y_2005 != 0)), ]

colnames(cont_pred_cali_2005)[c(8,9,10)] <- c('slope','aspect','elev')
colnames(cont_pred_cali_2015)[c(8,9,10)] <- c('slope','aspect','elev')

cali_y_2005 <- cali_y_2005[!is.infinite(cont_pred_cali_2005$tmax_8) & !is.infinite(cont_pred_cali_2005$tmin_1),]
cali_x_2005 <- cont_pred_cali_2005[!is.infinite(cont_pred_cali_2005$tmax_8) & !is.infinite(cont_pred_cali_2005$tmin_1),]
cali_y_2015 <- cali_y_2015[!is.infinite(cont_pred_cali_2015$tmax_8) & !is.infinite(cont_pred_cali_2015$tmin_1),]
cali_x_2015 <- cont_pred_cali_2015[!is.infinite(cont_pred_cali_2015$tmax_8) & !is.infinite(cont_pred_cali_2015$tmin_1),]

cali_x_2005 <- cali_x_2005[, col_x]
cali_x_2005_mat <- apply(cali_x_2005, 2, scale)
cali_x_2005 <- data.frame(cali_x_2005_mat)

cali_x_2015 <- cali_x_2015[, col_x]
cali_x_2015_mat <- apply(cali_x_2015, 2, scale)
cali_x_2015 <- data.frame(cali_x_2015_mat)

cali_out_2005 <- train_gjam(cali_x_2005, cali_y_2005)
cali_out_2015 <- train_gjam(cali_x_2015, cali_y_2015)
