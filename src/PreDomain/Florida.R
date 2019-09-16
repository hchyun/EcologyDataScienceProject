#load dataset
library(tidyverse)
library(gjam)
FIA_Climate <- read_csv("~/Desktop/ECOproject/data/FIA_Counties_db.csv")
FIA_Climate <-  FIA_Climate[complete.cases(FIA_Climate[-c(1:8)]), ]

predictors <- FIA_Climate %>%
  dplyr::select(-one_of(c("id_features", "coords_id","countycd", "unitcd",
                          "spcd", "count","n", "dbh","height"))) %>%
  unique

predictors_fl <- predictors[predictors$statecd == 12,]
responses <- FIA_Climate %>%
  dplyr::select(c("id_coords", "statecd","spcd", "count", "dbh","height", "n" )) 

responses$count <- ceiling(responses$count)
responses <- responses[responses$statecd %in% c(1,2,4,5,6,8,9,10,11,12,13,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56),]
plants_per_county <- responses %>%
  group_by(id_coords) %>%
  summarize(tot_n = sum(count))
plants_percounty <- left_join(responses, plants_per_county)
responses$count <- plants_percounty$count


#Getting the codes of all of the species
spc <- unique(responses$spcd)
spc <- sort(spc)

#Creating a data frame with column names as species code and row numbers as the counties
rsp_county <- matrix(as.numeric(0), ncol = length(spc), nrow = nrow(predictors_fl))
rsp_county <- data.frame(rsp_county)
colnames(rsp_county) <- spc
rsp_county_count <- rsp_county
for(i in 1:nrow(responses)){
  #The row that will be corresponding to the environmental variables
  count <- which(predictors_fl$id_coords == responses$id_coords[i])
  rsp_county_count[count,as.character(responses$spcd[i])] <- (responses$count[i])
}

training_predictors_fl <- predictors[which(!(predictors$id_coords %in% test_labels_fl) & predictors$statecd == 12), ] %>%
  # dplyr::select(-one_of(c("1_snow_melt","2_snow_melt","3_snow_melt","4_snow_melt","5_snow_melt",
  #                         "6_snow_melt","7_snow_melt","8_snow_melt","9_snow_melt","10_snow_melt",
  #                         "11_snow_melt", "12_snow_melt")))
  dplyr::select("id_coords","slope","aspect","elevation", "3_daylength","4_daylength","10_daylength", 
                "6_prec","7_prec", "8_rad", "8_tmax" , "1_tmin")
colnames(training_predictors_fl)[-1] <- paste("f",colnames(training_predictors_fl)[-1], sep="_") 


training_responses_fl <- rsp_county_count[which(!(predictors$id_coords %in% test_labels_fl)&predictors$statecd==12), ]
training_responses_fl <- training_responses_fl[,!apply(training_responses_fl, 2, sum)==0]

#Xpra <- prcomp(as.matrix(training_predictors[-c(1)]))
#X <- data.frame(Xpra$x[,1:10])


#Dimenstion reduction list total covariance parameter estimates reduced to N x r, N is response groups, r is the dimensionality of those response groups
#X <- data.frame(Xpra$x[,1:10])
rl   <- list(r = 12, N = 56)
ml   <- list(ng = 2500, burnin = 500, typeNames = "DA", reductList = rl)
form <- as.formula(paste("~", paste(colnames(training_predictors)[-1], collapse = " + ")))
#form <- as.formula(paste("~", paste(colnames(X), collapse = " + ")))



out_fl  <- gjam(form, xdata = training_predictors_fl, ydata = training_responses_fl, modelList = ml)

test_predictions_fl <- predictors[which((predictors$id_coords %in% test_labels_fl)), ] %>%
  dplyr::select("id_coords","slope","aspect","elevation", "3_daylength","4_daylength","10_daylength", 
                "6_prec","7_prec", "8_rad", "8_tmax" , "1_tmin")
colnames(test_predictions_fl)[-1] <- paste("f",colnames(test_predictions_fl)[-1], sep="_")
test_responses_fl <- rsp_county_count[which((predictors$id_coords %in% test_labels_fl)), ]
test_responses_fl <- test_responses_fl[,!apply(training_responses, 2, sum)==0]

newdata_fl <- list(xdata = test_predictions_fl, nsim=100)
pred_count_count_fl <- gjamPredict(output = out_fl, newdata = newdata_fl)
pred_fl <- pred_count_count_fl$sdList$yMu

ts_county_fl <- test_responses_fl[colnames(test_responses_fl) %in% colnames(pred_fl)]
rownames(ts_county_fl) <- NULL

eval_fl <- evaluate_model(pred_fl, ts_county_fl)
eval_fl <- eval_fl[!is.na(eval_fl)]
eval_fl <- eval_fl[eval_fl != -Inf]
