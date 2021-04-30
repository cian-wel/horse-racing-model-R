# about ------
# 03_data_edit.R
# this script edits the data in data/ and outputs to outputs/
# this script cleans the data and calculates new data fields

# functions ----

# load data ----

load(file = "data/data_lookups.rda")
load(file = "data/past_races.rda")
load(file = "data/past_runners.rda")

# general data cleanning --------
# clean to N/A bsp = -1 (no BSP) or 0 (no BSP yet)
past_runners <- past_runners %>%
  replace_with_na(replace = list(bsp =c(-1, 0)))

# assign placed = true to winners
past_runners$placed <- past_runners$placed + past_runners$won

# remove nas
past_runners <- past_runners %>%
  dplyr::filter(!is.na(bsp))

# assign number of places to each
past_races$num_places <- integer(nrow(past_races))

past_races$num_places[which(past_races$num_runners <= 4)] <- 1
past_races$num_places[which(past_races$num_runners > 4 & 
                              past_races$num_runners <= 7)] <- 2
# set all greater than 7 to 3 and then reset
past_races$num_places[which(past_races$num_runners > 7)] <- 3
# temporary fix while race categories not available
past_races$num_places[which(past_races$num_runners > 15 & 
                              grepl("andicap", past_races$name, TRUE))] <- 4


# replace lookups
past_runners <- past_runners %>%
  left_join(select(jockey_lookup, name, id), by = c("jockey_id" = "id")) %>%
  rename(jockey_name = name) %>%
  select(-jockey_id)

past_runners <- past_runners %>%
  left_join(select(trainer_lookup, name, id), by = c("trainer_id" = "id")) %>%
  rename(trainer_name = name) %>%
  select(-trainer_id)

# get list of remaining race ids
# dataset_race_id <- dataset$race_id[!duplicated(dataset$race_id)]