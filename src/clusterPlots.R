library(tidyverse)
library(gjam)

climate_plot <- read_csv("../data/FIA_Plots_db.csv")
#climate_plot <- climate_plot[complete.cases(climate_plot[-c(1:8)]),]

#climate_plot["tmean_winter"] <- rowMeans(climate_plot[c("1_tmax","2_tmax","12_tmax","1_tmin","2_tmin","12_tmin")])
#climate_plot["tmean_summer"] <- rowMeans(climate_plot[c("6_tmax","7_tmax","8_tmax","6_tmin","7_tmin","8_tmin")])

predictors_plot <- climate_plot %>%
  dplyr::select(-one_of(c("lat","lon", "coords_id"))) %>%
  unique

predictors_plot <- predictors_plot[c(1:7)]

#creating sub sets of the data and grouping by state and county
grouped_counties <- dlply(predictors_plot, c("statecd", "countycd"))

clustered_predictors <- data.frame(matrix(ncol=ncol(predictors_plot) + 1, nrow=0))
colnames(clustered_predictors) <- c(colnames(predictors_plot), "plots")
clustered_predictors$plot <- NULL

#effort vector will hold the number of counties in a cluster
eff <- c()
r = 1
for(i in 1:length(grouped_counties)){
  temp <- data.frame(grouped_counties[i])
  #Taking out plot in the kmeans clustering
  temp[,3] <- NULL
  #Have around 16 plots per cluster
  num_clusters <- ceiling(nrow(temp)/16)
  clusters <- tryCatch({kmeans(temp, num_clusters)},error = function(e){kmeans(temp,1)})
  #for each cluster append to the clustered data frame
  for(j in 1:nrow(clusters$centers)){
    plots <- list(which(j == clusters$cluster))
    clustered_predictors[r,] <- c(clusters$centers[j,], list(plots))
    r <- r + 1
  }
  #add the number of plots to the effort vector
  tbl <- data.frame(table(clusters$cluster))
  eff <- c(eff, tbl[,"Freq"])
}
rm(temp,r,num_clusters,clusters,tbl)

FIA_response <- read_csv("data/FIA_Plots_db2.csv")

responses_plot <- FIA_response %>%
  dplyr::select(c("statecd","countycd","plot", "spcd", "count"))

responses_plot$count <- ceiling(responses_plot$count)

spc <- sort(unique(responses_plot$spcd))

rsp_plot <- matrix(as.numeric(0), ncol = length(spc), nrow = nrow(clustered_predictors))
rsp_plot <- data.frame(rsp_plot)
colnames(rsp_plot) <- spc
rsp_plot_count <- rsp_plot

for(i in 1:nrow(responses_plot)){
  #Finding the indices that are in the state and county
  cot <- which(clustered_predictors$statecd == responses_plot$statecd[i] & clustered_predictors$countycd == responses_plot$countycd[i])
  index <- clustered_predictors$plots[ct]
  #Within the indices finding the plot that correspond to the row of the plot
  for(j in 1:length(index)){
    if(responses_plot$plot[i] %in% index[[j]]){
      ct <- cot[j]
      break
    }
  }
  rsp_plot_count[ct,as.character(responses_plot$spcd[i])] <- (responses_plot$count[i]) + rsp_plot_count[ct,as.character(responses_plot$spcd[i])]
}
rm(cot,ct,index)

test_labels_plot <- sample(clustered_predictors$countycd, 15)
#: STAND AGE (from FIA); Mean Temperature, Slope, Aspect, Altitude)
not_test_index_plot <- which(!(clustered_predictors$countycd %in% test_labels_plot))

predictor_names <- c("stand_age","slope","aspect","elevation")

training_predictors_plot <- clustered_predictors[not_test_index_plot,] %>%
  dplyr::select(c("AVG(STDAGE)","AVG(slope)","AVG(aspect)", "AVG(elev)"))

colnames(training_predictors_plot) <- predictor_names

training_responses_plot <- rsp_plot_count[not_test_index_plot,]
#Getting rid of species not in the data
training_responses_plot <- training_responses_plot[,!apply(training_responses_plot, 2, sum)==0]

eff <- eff[not_test_index_plot]
ef <- list(columns=1:ncol(training_responses_plot), values=eff)
rl   <- list(r = 8, N = 12)
ml   <- list(ng = 2500, burnin = 500, typeNames = "DA", reductList = rl, effort=ef)
form <- as.formula(paste("~", paste(colnames(training_predictors_plot)[-1], collapse = " + ")))
out_plot <- gjam(form, xdata=training_predictors_plot, ydata=training_responses_plot, modelList=ml)

test_predictors_plot <- predictors_plot[-not_test_index_plot, ] %>%
  dplyr::select(predictor_names)

test_responses_plot <- rsp_plot_count[-not_test_index_plot, ]

newdata_plot <- list(xdata = test_predictors_plot, nsim=100)
prediction_plot <- gjamPredict(output = out_plot, newdata = newdata_plot)
pred_plot <- prediction_plot$sdList$yMu

test_responses_plot <- test_responses_plot[colnames(test_responses_plot) %in% colnames(pred_plot)]
rownames(test_responses_plot) <- NULL

evaluate_plot <- t(evaluate_model(pred_plot, test_responses_plot))
evaluate_plot <- evaluate_plot[evaluate_plot != -Inf]
plot(evaluate_plot, ylim=c(-1,1))
summary(evaluate_plot)

