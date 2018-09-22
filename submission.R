setwd('C:/dev/data_science/google-analytics')

# Import data cleaning function
source('clean.R')

# Import cleaned data RDS files or create them
if (file.exists('train_cleaned.rds')){
  train_cleaned <- readRDS('train_cleaned.rds')
} else {
  train <- read.csv('train.csv', colClasses=c(fullVisitorId = 'character'))
  train_cleaned <- clean(train)
  saveRDS(train_cleaned, 'train_cleaned.rds')  
}

if (file.exists('test_cleaned.rds')){
  test_cleaned <- readRDS('test_cleaned.rds')
} else {
  test <- read.csv('test.csv', colClasses=c(fullVisitorId = 'character'))
  test_cleaned <- clean(test)
  saveRDS(test_cleaned, 'test_cleaned.rds')  
}






# Implement LightGBM
library(lightgbm)

# Split into test/train
set.seed(385)
smp_size <- floor(0.8 * nrow(train_cleaned))
train_ind <- sample(seq_len(nrow(train_cleaned)), size = smp_size)
train_set <- train_cleaned[train_ind,]
valid_set <- train_cleaned[-train_ind,]

# Separate data frames for inputs and labels
train_inputs <- as.matrix(train_set %>% select(-c(fullVisitorId,transactionRevenue)))
train_labels <- as.matrix(train_set %>% select(transactionRevenue))
valid_inputs <- as.matrix(valid_set %>% select(-c(fullVisitorId,transactionRevenue)))
valid_labels <- as.matrix(valid_set %>% select(transactionRevenue))

dtrain <- lgb.Dataset(data = train_inputs, label = train_labels)
dtest <- lgb.Dataset.create.valid(dtrain, data = valid_inputs, label = valid_labels)
valids <- list(test = dtest)

# Grid search
grid_search <- expand.grid(
  learning_rate = c(0.001, 0.0001),
  num_iterations = c(10000, 100000),
  num_leaves = c(31, 50, 100, 150)
  )

# default very high min rmse to be replaced
min_rmse <- 1000

for(i in 1:nrow(grid_search)) {

  print(paste('grid search', i, 'of', nrow(grid_search), sep = ' '))
  
  model <- lgb.train(objective = 'regression', 
                     metric = 'rmse',
                     data = dtrain,
                     num_iterations = grid_search[i, 'num_iterations'],
                     valid = valids,
                     learning_rate = grid_search[i, 'learning_rate'],
                     num_leaves = grid_search[i, 'num_leaves'])
  
  # Predict on the validation set
  predicted <- predict(model, valid_inputs)
  
  # Calculate rmse
  rmse <- sqrt(mean((predicted - valid_labels)^2))
  
  if(rmse < min_rmse) {
    min_rmse <- rmse
    selected_model <- model
    selected_params <- grid_search[i,]
  }
    
}

min_rmse
grid_search[i,]


sumission_inputs <- as.matrix(test_cleaned %>% select(-c(fullVisitorId,transactionRevenue)))

submit_predicted <- predict(selected_model, sumission_inputs)

submission <- data.frame(fullVisitorId = test_cleaned$fullVisitorId, 
                         PredictedLogRevenue = submit_predicted)


write.csv(submission, 'submission_smallgrid.csv', row.names = FALSE)
