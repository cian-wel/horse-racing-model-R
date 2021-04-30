# about ------
# 03_data_edit.R
# this script edits the data in data/ and outputs to outputs/
# this script cleans the data and calculates new data fields

# functions ----

# load data ----

load(file = "data/data_lookups.rda")
load(file = "data/past_races.rda")
load(file = "data/past_runners.rda")

# past_runners general data cleaning --------
# clean to N/A bsp = -1 (no BSP) or 0 (no BSP yet)
past_runners <- past_runners %>%
  replace_with_na(replace = list(win_bsp =c(-1, 0)))

# assign number of places to each race
num_places <- integer(nrow(past_races))

num_places[which(past_races$num_runners <= 4)] <- 1
num_places[which(past_races$num_runners > 4 & 
                              past_races$num_runners <= 7)] <- 2
# set all greater than 7 to 3 and then reset
num_places[which(past_races$num_runners > 7)] <- 3
# temporary fix while race categories not available
num_places[which(past_races$num_runners > 15 & 
                              grepl("andicap", past_races$race_name, TRUE))] <- 4

past_races$num_places <- num_places

# replace lookups
past_runners <- past_runners %>%
  left_join(select(jockey_lookup, name, id), by = c("jockey_id" = "id")) %>%
  rename(jockey_name = name) %>%
  select(-jockey_id)

past_runners <- past_runners %>%
  left_join(select(trainer_lookup, name, id), by = c("trainer_id" = "id")) %>%
  rename(trainer_name = name) %>%
  select(-trainer_id)

# past race general data cleaning ------
# replace lookups 
past_races <- past_races %>%
  left_join(select(course_lookup, name, id, country, direction,
                   characteristics), by = c("course_id" = "id")) %>%
  rename(
    course_name = name,
    course_country = country,
    course_direction = direction,
    course_characteristics = characteristics
    ) %>%
  select(-course_id)

past_races <- past_races %>%
  left_join(select(distance_lookup, yard, id), by = c("distance_id" = "id")) %>%
  rename(distance = yard) %>%
  select(-distance_id)

past_races <- past_races %>%
  left_join(select(going_lookup, description, id),
            by = c("official_going" = "id")) %>%
  select(-official_going) %>%
  rename(official_going = description)

past_races <- past_races %>%
  left_join(select(going_lookup, description, id),
            by = c("actual_going" = "id")) %>%
  select(-actual_going) %>%
  rename(actual_going = description)

past_races <- past_races %>%
  left_join(select(race_type_lookup, description, id),
            by = c("type" = "id")) %>%
  select(-type) %>%
  rename(type = description)

# select races we want to look at -----

ds_past_races <- past_races %>%
  filter(
    type == "A/W" &
    grepl("andicap", race_name, TRUE) &
    min_age >= 3 &
    course_country == "(GB)" &
    date_time >= as.Date("2019-01-01")
    )

# get list of remaining race ids
race_ids <- ds_past_races$race_id[] 
ds_past_runners <- past_runners[past_runners$race_id %in% race_ids,]

# final data cleaning steps -----

# remove bsp nas
past_runners <- past_runners %>%
  dplyr::filter(!is.na(win_bsp))

# save files ------
save(ds_past_runners, file = "output/ds_past_runners.rda")
save(ds_past_races, file = "output/ds_past_races.rda")

# clear workspace ------
rm(list = ls())