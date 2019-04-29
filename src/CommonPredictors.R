library(tidyverse)
library(gjam)

climate <- read_csv("../data/FIA_Counties_db2.csv")
climate <- climate[complete.cases(climate[-c(1:8)]),]

climate["tmean_winter"] <- rowMeans(climate[c("1_tmax","2_tmax","12_tmax","1_tmin","2_tmin","12_tmin")])
climate["tmean_summer"] <- rowMeans(climate[c("6_tmax","7_tmax","8_tmax","6_tmin","7_tmin","8_tmin")])

predictors <- climate %>%
  dplyr::select(-one_of(c("id_features", "coords_id", 
                          #"countycd", 
                          "spcd", "count","n", "dbh","height"))) %>%
  unique

responses <- climate %>%
  dplyr::select(c("id_coords", "spcd", "count"))

responses$count <- ceiling(responses$count)

spc <- sort(unique(responses$spcd))

rsp_county <- matrix(as.numeric(0), ncol = length(spc), nrow = nrow(predictors))
rsp_county <- data.frame(rsp_county)
colnames(rsp_county) <- spc
rsp_county_count <- rsp_county

for(i in 1:nrow(responses)){
  #The row that will be corresponding to the environmental variables
  ct <- which(predictors$id_coords == responses$id_coords[i])
  rsp_county_count[ct,as.character(responses$spcd[i])] <- (responses$count[i])
}

test_labels <- sample(predictors$id_coords, nrow(predictors)*0.3)
#: STAND AGE (from FIA); Mean Temperature, Slope, Aspect, Altitude)
not_test_index <- which(!(predictors$id_coords %in% test_labels))
predictor_names <- c("stand_age","tmean_winter", "tmean_summer","slope","aspect","elevation")

training_predictors <- predictors[not_test_index,] %>%
  dplyr::select(predictor_names)

training_responses <- rsp_county_count[not_test_index,]
#Getting rid of species not in the data
training_responses <- training_responses[,!apply(training_responses, 2, sum)==0]

rl   <- list(r = 12, N = 56)
ml   <- list(ng = 2500, burnin = 500, typeNames = "DA", reductList = rl)
form <- as.formula(paste("~", paste(colnames(training_predictors)[-1], collapse = " + ")))
out <- gjam(form, xdata=training_predictors, ydata=training_responses, modelList=ml)

test_predictors <- predictors[-not_test_index, ] %>%
  dplyr::select(predictor_names)

test_responses <- rsp_county_count[-not_test_index, ]

newdata <- list(xdata = test_predictors, nsim=100)
prediction <- gjamPredict(output = out, newdata = newdata)
pred <- prediction$sdList$yMu

test_responses <- test_responses[colnames(test_responses) %in% colnames(pred)]
rownames(test_responses) <- NULL

evaluate_model <- function(prediction, observation){
  eval <- rep(NA,ncol(observation))
  eval <- data.frame(t(eval))
  colnames(eval) <- colnames(observation)
  for(j in 1:ncol(observation)){
    eval[j] <- 1 - sum((prediction[,j] - observation[,j])^2, na.rm=T) / 
      sum((observation[,j] - mean(observation[,j], na.rm = T))^2, na.rm = T)
  }
  return(eval)
}

evaluate <- t(evaluate_model(pred, test_responses))
evaluate <- evaluate[evaluate != -Inf]
plot(evaluate, ylim=c(-1,1))
summary(evaluate)

