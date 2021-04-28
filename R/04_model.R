# about ------
# script models lengths to winner based on available data with aim

# load available data -------

load(file = "data/data_lookups.rda")
load(file = "data/past_races.rda")
load(file = "data/past_runners.rda")

# clean data as required --------

# rename the dataset
dataset <- past_runners

# remove nas
dataset <- dataset %>%
  dplyr::filter(!is.na(bsp))

# replace lookups
dataset <- dataset %>%
  left_join(select(jockey_lookup, name, id), by = c("jockey_id" = "id")) %>%
  rename(jockey_name = name) %>%
  select(-jockey_id)

dataset <- dataset %>%
  left_join(select(trainer_lookup, name, id), by = c("trainer_id" = "id")) %>%
  rename(trainer_name = name) %>%
  select(-trainer_id)

# get list of remaining race ids
dataset_race_id <- dataset$race_id[!duplicated(dataset$race_id)]

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