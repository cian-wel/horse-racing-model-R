# 03_combine_datasets ------
# this script combines data sets download from betfair and proform

# betfair dataset -----
betfair_files <- c("data/betfair_place_data_2021.Rda", "data/betfair_place_data_2020.Rda")
lapply(betfair_files, load, .GlobalEnv)

# combine into single file
betfair_place_data <- rbind(betfair_place_data_2020, betfair_place_data_2021)