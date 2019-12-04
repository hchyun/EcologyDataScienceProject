eval <- c(list(DO1_eval$eval),list(DO2_eval$eval),list(DO3_eval$eval),list(DO5_eval$eval),list(DO6_eval$eval),list(DO7_eval$eval),list(DO8_eval$eval),list(DO9_eval$eval),list(DO10_eval$eval),list(DO11_eval$eval),list(DO12_eval$eval),list(DO13_eval$eval),list(DO14_eval$eval),list(DO15_eval$eval),list(DO16_eval$eval),list(DO17_eval$eval))
for(i in 1:length(eval)){
  boxplot(eval[[i]][eval[[i]] > -1])
}

percentage <- c()
for(i in 1:length(eval)){
  pos <- length(eval[[i]][eval[[i]] > 0])
  total <- length(eval[[i]][eval[[i]] != -Inf])
  percentage <- c(percentage, pos/total)
}

cont_accuracy <- length(cont_eval$eval[cont_eval$eval > 0]) / length(cont_eval$eval)
percentage <- c(percentage, cont_accuracy)

barplot(percentage,ylim=c(0,1), ylab= "accuracy", xlab="Domain", names.arg = c("1","2","3","5","6","7","8","9","10","11","12","13","14","15","16","17", "cont"))

#Getting all spc codes from the domains
spc <- c()
for(i in 1:length(eval)){
 spc <- c(spc, colnames(eval[[i]]))
}
spc <- unique(spc)

#row 1 for the total r2
#row2 for the number of domains
spc.avg <- matrix(0, nrow = 2, ncol = length(spc))
spc.avg <- data.frame(spc.avg)
colnames(spc.avg) <- spc

for(i in 1:length(eval)){
  if(i == 4 | i == 10 | i == 19){
    next
  }
  for(j in 1:length(eval[[i]])){
    current.spc <- colnames(eval[[i]][j])
    col.index <- which(current.spc == spc)
    if(eval[[i]][j] != -Inf){
      spc.avg[1,col.index] <- spc.avg[1,col.index] + eval[[i]][j][1,1]
      spc.avg[2, col.index] <- 1 + spc.avg[2, col.index]
    }
    
  }
}

spc.avg <- spc.avg[,spc.avg[2,] != 0]
averages <- spc.avg[1,] / spc.avg[2,]


spc.median <- vector(length=length(spc), mode='list')
names(spc.median) <- spc

for(i in 1:length(eval)){
  for(j in 1:length(eval[[i]])){
    species <- colnames(eval[[i]][j])
    value <- eval[[i]][[j]]
    if(value != -Inf){
      if(is.null(spc.median[[species]])){
        spc.median[[species]] <- c(value)
      }else{
        spc.median[[species]] <- c(spc.median[[species]], value)
      }
    }
  }
}

medians <- matrix(0, nrow = 1, ncol = length(spc))
medians <- data.frame(medians)
colnames(medians) <- spc
rmcols <- c()
for(i in 1:length(spc.median)){
  if(is.null(spc.median[[i]])){
    rmcols <- c(rmcols, names(spc.median[i]))
  }else{
    medians[1,names(spc.median[i])] <- median(spc.median[[i]])
  }
}

medians <- medians[,!colnames(medians) %in% rmcols]

good.pred <- medians[,medians > 0.75]
ok.pred <- medians[,medians > 0.5 & medians < 0.75]
avg.pred <- medians[,medians > 0.25 & medians < 0.5]
notgood.pred <- medians[,medians > 0 & medians < 0.25]
bad.pred <-medians[,medians < 0]

spcd_code <- read_csv("../data/spcd.csv")

good.spcd <- spcd_code[spcd_code$spcd==631,]
ok.spcd <- spcd_code[spcd_code$spcd %in% colnames(ok.pred),]
avg.spcd <- spcd_code[spcd_code$spcd %in% colnames(avg.pred),]
notgood.spcd <- spcd_code[spcd_code$spcd %in% colnames(notgood.pred),]
bad.spcd <- spcd_code[spcd_code$spcd %in% colnames(bad.pred),]

pred.counts <- c(length(good.pred), length(ok.pred), length(avg.pred), length(notgood.pred))
barplot(pred.counts, names.arg = c('>0.75\nGreat', '0.5-0.75\nGood', '0.25-0.5\nAvg', '0-0.25\npoor'))

gjamPlot(output = DO1_out)
gjamPlot(output = DO2_out)
gjamPlot(output = DO3_out)
gjamPlot(output = DO4_out)
gjamPlot(output = DO5_out)
gjamPlot(output = DO6_out)
gjamPlot(output = DO7_out)
gjamPlot(output = DO8_out)
gjamPlot(output = DO9_out)
gjamPlot(output = DO10_out)
gjamPlot(output = DO11_out)
gjamPlot(output = DO12_out)
gjamPlot(output = DO13_out)
gjamPlot(output = DO14_out)
gjamPlot(output = DO15_out)
gjamPlot(output = DO16_out)
gjamPlot(output = DO17_out)
gjamPlot(output = DO19_out)
gjamPlot(output = cont_out)


daylength10_sensitivity <- c(median(DO1_out$parameters$betaStandXmu["daylength10",]),median(DO2_out$parameters$betaStandXmu["daylength10",]),median(DO3_out$parameters$betaStandXmu["daylength10",]),median(DO4_out$parameters$betaStandXmu["daylength10",]),median(DO5_out$parameters$betaStandXmu["daylength10",]),median(DO6_out$parameters$betaStandXmu["daylength10",]),median(DO7_out$parameters$betaStandXmu["daylength10",]),median(DO8_out$parameters$betaStandXmu["daylength10",]),median(DO9_out$parameters$betaStandXmu["daylength10",]),median(DO10_out$parameters$betaStandXmu["daylength10",]),median(DO11_out$parameters$betaStandXmu["daylength10",]),median(DO12_out$parameters$betaStandXmu["daylength10",]),median(DO13_out$parameters$betaStandXmu["daylength10",]),median(DO14_out$parameters$betaStandXmu["daylength10",]),median(DO15_out$parameters$betaStandXmu["daylength10",]),median(DO16_out$parameters$betaStandXmu["daylength10",]),median(DO17_out$parameters$betaStandXmu["daylength10",]),median(DO19_out$parameters$betaStandXmu["daylength10",]))
plot(daylength10_sensitivity, xlab="Domian")

cov <- c(0.66, 2210,1402,99)
covar <- data.frame(x=c('D1','D2','D7','D8'), y=cov)
plot(covar, xlab="Domain", ylab="Covariance")

col_x <- colnames(DO1_pred_final)
#Predictor comparison of beta mu in some of the domains
for(i in 1:length(col_x)){
  predictor.name = str_remove_all(col_x[i], '_')
  print(predictor.name)
  boxplot(cont_out$parameters$betaMu[predictor.name,], DO1_out$parameters$betaMu[predictor.name,],
          DO3_out$parameters$betaMu[predictor.name,], DO5_out$parameters$betaMu[predictor.name,],
          DO8_out$parameters$betaMu[predictor.name,], DO9_out$parameters$betaMu[predictor.name,],
          DO13_out$parameters$betaMu[predictor.name,], DO17_out$parameters$betaMu[predictor.name,],
          names=c('Cont', 'NE', 'SE','GL','OZ','NP','SROC','PSW'), main=predictor.name, ylim=c(-50,50))
}

for(i in 1:length(col_x)){
  predictor.name = str_remove_all(col_x[i], '_')
  print(predictor.name)
  boxplot(cont_out$parameters$fmatrix[predictor.name,], DO1_out$parameters$fmatrix[predictor.name,],
          DO3_out$parameters$fmatrix[predictor.name,], DO5_out$parameters$fmatrix[predictor.name,],
          DO8_out$parameters$fmatrix[predictor.name,], DO9_out$parameters$fmatrix[predictor.name,],
          DO13_out$parameters$fmatrix[predictor.name,], DO17_out$parameters$fmatrix[predictor.name,],
          names=c('Cont', 'NE', 'SE','GL','OZ','NP','SROC','PSW'), main=predictor.name, ylim=c(-0.05,0.05))
}


#Exploring some covariances

tsamp <- intersect(colnames(DO1_y), intersect(intersect(colnames(DO2_y), colnames(DO7_y)), colnames(DO8_y)))
tsamp <- sample(tsamp, 12)
spcn <- spcd_code[which(spcd_code$spcd %in% tsamp),]$common_name
ds <- c(1,2,7,8, 'cont')
colsn <- c(list(colnames(DO1_out$parameters$sigMu)),list(colnames(DO2_out$parameters$sigMu)),list(colnames(DO7_out$parameters$sigMu)),list(colnames(DO8_out$parameters$sigMu)), list(colnames(cont_out$parameters$sigMu))   )
cormus <- c(list(DO1_out$parameters$corMu),list(DO2_out$parameters$corMu),list(DO7_out$parameters$corMu),list(DO8_out$parameters$corMu), list(cont_out$parameters$corMu))
for(i in 1:5){
  test <- cormus[[i]]
  test <- test[which(colsn[[i]] %in% tsamp),which(colsn[[i]] %in% tsamp)]
  colnames(test) <- spcn
  rownames(test) <- spcn
  test[upper.tri(test, diag=T)] <- NA
  print(ggcorrplot(test))
}

t <- DO1_out$parameters$corMu
t[lower.tri(t, diag=T)] <- NA
plot(t)

mean_abs_diff <- function(pred, obs){
  diffs <- c()
  for(i in 1:ncol(obs)){
    curr.spc <- colnames(obs)[i]
    diffs<- c(mean(abs(pred[,curr.spc] - obs[,curr.spc])),diffs)
  }
  return(diffs)
}
