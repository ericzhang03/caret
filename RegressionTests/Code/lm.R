timestamp <- Sys.time()
library(caret)

model <- "lm"

#########################################################################

SLC14_1 <- function(n = 100) {
  dat <- matrix(rnorm(n*20, sd = 3), ncol = 20)
  foo <- function(x) x[1] + sin(x[2]) + log(abs(x[3])) + x[4]^2 + x[5]*x[6] + 
    ifelse(x[7]*x[8]*x[9] < 0, 1, 0) +
    ifelse(x[10] > 0, 1, 0) + x[11]*ifelse(x[11] > 0, 1, 0) + 
    sqrt(abs(x[12])) + cos(x[13]) + 2*x[14] + abs(x[15]) + 
    ifelse(x[16] < -1, 1, 0) + x[17]*ifelse(x[17] < -1, 1, 0) -
    2 * x[18] - x[19]*x[20]
  dat <- as.data.frame(dat)
  colnames(dat) <- paste0("Var", 1:ncol(dat))
  dat$y <- apply(dat[, 1:20], 1, foo) + rnorm(n, sd = 3)
  dat
}

set.seed(1)
training <- SLC14_1(30)
testing <- SLC14_1(100)
trainX <- training[, -ncol(training)]
trainY <- training$y
testX <- trainX[, -ncol(training)]
testY <- trainX$y 

weight_test <- function (data, lev = NULL, model = NULL)  {
  mean(data$weights)
  postResample(data[, "pred"], data[, "obs"])
}

rctrl1 <- trainControl(method = "cv", number = 3, returnResamp = "all")
rctrl2 <- trainControl(method = "LOOCV")
rctrl3 <- trainControl(method = "none")
rctrl4 <- trainControl(method = "cv", summaryFunction = weight_test)
rctrl5 <- trainControl(method = "LOOCV", summaryFunction = weight_test)



set.seed(849)
test_reg_cv_model <- train(trainX, trainY, method = "lm", trControl = rctrl1)
test_reg_pred <- predict(test_reg_cv_model, testX)

set.seed(849)
test_reg_cv_form <- train(y ~ ., data = training, method = "lm", trControl = rctrl1)
test_reg_pred_form <- predict(test_reg_cv_form, testX)

set.seed(849)
test_reg_loo_model <- train(trainX, trainY, method = "lm", trControl = rctrl2)

set.seed(849)
test_reg_none_model <- train(trainX, trainY, 
                             method = "lm", 
                             trControl = rctrl3,
                             tuneLength = 1,
                             preProc = c("center", "scale"))
test_reg_none_pred <- predict(test_reg_none_model, testX)

set.seed(849)
test_reg_cv_weights <- train(trainX, trainY, weights = runif(nrow(trainX)), method = "lm", trControl = rctrl4)

set.seed(849)
test_reg_loo_weights <- train(trainX, trainY, weights = runif(nrow(trainX)), method = "lm", trControl = rctrl5)


#########################################################################

test_reg_predictors1 <- predictors(test_reg_cv_model)

#########################################################################

test_reg_imp <- varImp(test_reg_cv_model)

#########################################################################

tests <- grep("test_", ls(), fixed = TRUE, value = TRUE)

sInfo <- sessionInfo()
timestamp_end <- Sys.time()

save(list = c(tests, "sInfo", "timestamp", "timestamp_end"),
     file = file.path(getwd(), paste(model, ".RData", sep = "")))

q("no")


