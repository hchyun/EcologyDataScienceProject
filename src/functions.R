load_packages <- function(){
  library(tidyverse)
  library(gjam)
  library(plyr)
}

load_data <- function(file_names){
  data <- list()
  for(i in 1:length(file_names)){
    new_df <- read_csv(file_names[i])
    data[[i]] <- new_df
  }
  return(data)
}

get_mat <- function(data, colnames=colnames(data)){
  df <- data %>%
    dplyr::select(one_of(colnames))
  colnames(df) <- tolower(colnames(df))
    df$id_coords <- paste(df$statecd, df$unitcd, df$countycd, df$plot,  sep="_")
  return(df)
}

cluster_plots <- function(data, cols_to_cluster){
  clustered <- data.frame(matrix(ncol=ncol(data), nrow=0))
  colnames(clustered) <- c(colnames(data))
  grouped_units <- dlply(data, c("statecd", "unitcd"))
  r <- 1
  for(i in 1:length(grouped_units)){
    temp <- data.frame(grouped_units[i])
    colnames(temp) <- colnames(data)
    temp_id <- temp$id_coords
    temp$id_coords <- NULL
    temp_clust <- temp[,cols_to_cluster]
    clust_groups <- kmvar(temp_clust)
    num <- max(clust_groups)
    for(j in 1:num){
      plots <- which(j == clust_groups)
      ids <- list(temp_id[plots])
      clustered[r, ] <- c(colMeans(temp[plots,], na.rm=T), list(ids))
      r <- r + 1
    }
  }

  return(clustered)
}

get_responses <- function(x_d, y){
  spc <- sort(unique(y$spcd))
  rsp_plot <- matrix(as.numeric(0), ncol = length(spc), nrow = nrow(x_d))
  rsp_plot <- data.frame(rsp_plot)
  colnames(rsp_plot) <- spc

  for(i in 1:nrow(y)){
    #Finding the indices that are in the state and county
    cot <- which(x_d$statecd == y$statecd[i] & x_d$unitcd == y$unitcd[i])
    index <- x_d$id_coords[cot]
    #Within the indices finding the plot that correspond to the row of the plot
    if(length(index) > 0){
      for(j in 1:length(index)){
        if(y$id_coords[i] %in% index[[j]]){
          ct <- cot[j]
          rsp_plot[ct,as.character(y$spcd[i])] <- (y$count[i]) + rsp_plot[ct,as.character(y$spcd[i])]
          
          break
        }
      }
    }
  }
  rsp_plot <- rsp_plot[,!apply(rsp_plot, 2, sum)==0]
  return(rsp_plot)
}

train_gjam <- function(x_data,y_data, R=8,n=10,Typenames="DA",Ng=2500,Burnin=500){
  rl   <- list(r = R, N = n)
  ml   <- list(ng = Ng, burnin = Burnin, typeNames = Typenames, reductList = rl)
  form <- as.formula(paste("~", paste(colnames(x_data), collapse = " + ")))
  out <- gjam(form, xdata=x_data, ydata=y_data, modelList=ml)
  return(out)
}

kmvar <- function(mat, clsize=16, method=c('random','maxd', 'mind', 'elki')){
  k = ceiling(nrow(mat)/clsize)
  km.o = kmeans(mat, k)
  labs = rep(NA, nrow(mat))
  centd = lapply(1:k, function(kk){
    euc = t(mat)-km.o$centers[kk,]
    sqrt(apply(euc, 2, function(x) sum(x^2)))
  })
  centd = matrix(unlist(centd), ncol=k)
  clsizes = rep(0, k)
  if(method[1]=='random'){
    ptord = sample.int(nrow(mat))
  } else if(method[1]=='elki'){
    ptord = order(apply(centd, 1, min) - apply(centd, 1, max))
  } else if(method[1]=='maxd'){
    ptord = order(-apply(centd, 1, max))
  } else if(method[1]=='mind'){
    ptord = order(apply(centd, 1, min))
  } else {
    stop('unknown method')
  }
  for(ii in ptord){
    bestcl = which.max(centd[ii,])
    labs[ii] = bestcl
    clsizes[bestcl] = clsizes[bestcl] + 1
    if(clsizes[bestcl] >= clsize){
      centd[,bestcl] = NA
    }
  }
  return(labs)
}
evaluate_model_ <- function(prediction, observation){
  eval <- rep(NA,ncol(observation))
  eval <- data.frame(t(eval))
  colnames(eval) <- colnames(observation)
  for(j in 1:ncol(observation)){
    eval[j] <- 1 - sum((prediction[,j] - observation[,j])^2, na.rm=T) / 
      sum((observation[,j] - mean(observation[,j], na.rm = T))^2, na.rm = T)
  }
  return(eval)
}

split_sample <- function(x_, y_){
  ret <- list()
  train <- sample(1:nrow(y_),nrow(y_)*0.8)
  x_ret <- x_[train,]
  y_ret <- y_[train,]
  x_ret_ <- x_[-train,]
  y_ret_ <- y_[-train,]
  y_ret <- y_ret[,!apply(y_ret,2,sum)==0]
  ret[[1]] <- x_ret
  ret[[2]] <- y_ret
  ret[[3]] <- x_ret_
  ret[[4]] <- y_ret_
  return(ret)
}

evaluate_model <- function(x_, y_, model){
  newdata <- list(xdata = x_, nsim=100)
  prediction <- gjamPredict(output = model, newdata = newdata)
  prediction <- prediction$sdList$yMu
  test_y <- y_[,colnames(prediction)]
  eval <- evaluate_model_(prediction, test_y)
  return(eval)
}

