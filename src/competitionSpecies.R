competitionspc <- c("316", "611", "111", "121", "131", "819", "827") #8441 Quercus Geminata
competitionnames <- paste(spcd_code[spcd_code$spcd %in% competitionspc, ]$genus, spcd_code[spcd_code$spcd %in% competitionspc, ]$species, sep=" ")

comp_y <- DO3_y[,competitionspc]

comp_training <- split_sample(DO3_pred_final, comp_y)

comp_train_x <- comp_training[[1]]
comp_train_y <- comp_training[[2]]
comp_test_x <- comp_training[[3]]
comp_test_y <- comp_training[[4]]

ml   <- list(ng =7500, burnin = 5000, typeNames = "DA")
form <- as.formula(paste("~", paste(colnames(comp_train_x), collapse = " + ")))
comp_out <- gjam(form, xdata=comp_train_x, ydata=comp_train_y, modelList=ml)

comp_eval <- evaluate_model(comp_test_x, comp_test_y, comp_out)
