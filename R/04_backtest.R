# about ------
# script back tests against actual results showing breakdown by probability
# and log loss
# tests both betfair place markets and estimates produced

# load file with data on races ----

load(file = "data/race_runners.Rda")
load(file = "data/betfair_place_data_2020.Rda")

# compare expected winners to actual winners based on estimated prices and betfair-----
# provides breakdown of expected winners and actual winners in each 10% probability interval

intervals <- 10

place_results <- data.frame(probability_fraction = double(intervals), estimate_actual = double(intervals), estimate_expected = double(intervals))
place_results$betfair_actual <- double(intervals)
place_results$betfair_expected <- double(intervals)

# temporary fix to ignore missing data fields
race_runners_temp <- race_runners %>% dplyr::filter(!is.na(isp))
race_runners_temp <- race_runners %>% dplyr::filter(!is.na(place_probability))

betfair_place_temp <- betfair_place_data_2020

for (i in 1:intervals) {
  place_results$probability_fraction[i] <- i/intervals
  place_results$estimate_actual[i] <- race_runners_temp %>% dplyr::filter(place_probability <= (i / intervals) & place_probability > ((i - 1) / intervals)) %$% sum(placed_bool)
  place_results$estimate_actual[i] <- place_results$estimate_actual[i] + race_runners_temp %>% dplyr::filter(place_probability <= (i / intervals) & place_probability > ((i - 1) / intervals)) %$% sum(won_bool)
  place_results$estimate_expected[i] <- race_runners_temp %>% dplyr::filter(place_probability <= (i / intervals) & place_probability > ((i - 1) / intervals)) %$% sum(place_probability)
  place_results$betfair_actual[i] <- betfair_place_temp %>% dplyr::filter(place_probability <= (i / intervals) & place_probability > ((i - 1) / intervals)) %$% sum(win_bool)
  place_results$betfair_expected[i] <- betfair_place_temp %>% dplyr::filter(place_probability <= (i / intervals) & place_probability > ((i - 1) / intervals)) %$% sum(place_probability)
}

place_results$estimate_aoe <- place_results$estimate_actual / place_results$estimate_expected
place_results$betfair_aoe <- place_results$betfair_actual / place_results$betfair_expected

# check both actual and expected match
# actual <- sum(race_runners_temp$placed_bool) + sum(race_runners_temp$won_bool)
# expected <- sum(race_runners_temp$place_probability)

# log loss calculation -------
# tests probability using log loss method

mean_log_loss <- data.frame(estimate=double(1), betfair=double(1))

# log loss of estimate
race_runners_temp$log_loss <- -(race_runners_temp$placed_bool * log(race_runners_temp$place_probability) + (1 - race_runners_temp$placed_bool)*log(1-race_runners_temp$place_probability))
mean_log_loss$estimate <- mean(race_runners_temp$log_loss)

# log loss of betfair
betfair_place_temp$log_loss <- -(betfair_place_temp$win_bool * log(betfair_place_temp$place_probability) + (1 - betfair_place_temp$win_bool)*log(1-betfair_place_temp$place_probability))
mean_log_loss$betfair <- mean(betfair_place_temp$log_loss)
