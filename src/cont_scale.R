load_packages()

cont_predictors <- read_csv("cont_climate.csv")
fia_response <- read_csv("fia_response.csv")

cols_cluster <- c("lat","lon")
cont_clustered <- cluster_plots(cont_predictors, cols_cluster)

cont_response <- get_responses(cont_clustered, fia_response)

train <- sample(1:nrow(cont_predictors),nrow(cont_predictors)*0.8)
cont_train_x <- cont_predictors[train,]
cont_train_y <- cont_response[train,]

cont_out <- train_gjam(cont_train_x, cont_train_y)

cont_test_x <- cont_predictors[-train,]
cont_test_y <- cont_response[-train,]

cont_newdata <- list(xdata=cont_test_x, nsim=100)
cont_pred <- gjamPredict(output=cont_out, newdata=cont_newdata)
cont_predictions <- cont_pred$sdList$yMu

cont_eval <- evaluate_model(cont_predictions, cont_test_y)

cont_newdata <- list(xdata = cont_test_x, nsim=100)
cont_prediction <- gjamPredict(output = cont_gjam, newdata = cont_newdata)
cont_pred <- cont_prediction$sdList$yMu