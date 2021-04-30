# about ------
# script models lengths to winner based on available data with aim

# load available data -------



# create training and validation datasets ---------

# create a list of 80% of the races in the original dataset we can use for
# training
training_race_id <- dataset_race_id[createDataPartition(dataset_race_id, p=0.01,
                                                        list=FALSE)]

validation_val <- dataset[!dataset$race_id %in% training_race_id,]
dataset_train <- dataset[dataset$race_id %in% training_race_id,]


# lengths_beaten_model -----
lengths_beaten_model = train(log(distance_to_winner+1) ~ bsp,
                  method = 'gbm', data = dataset_train ,verbose = F)

dataset_train$pred_lengths_beaten = predict(lengths_beaten_model, 
                                            dataset_train)