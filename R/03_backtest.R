# about ------
# script back tests against actual results

# load file with data on races ----


load(file = "data/race_runners.Rda")

# compare expected winners to actual winners
place_results <- data.frame(probability_fraction=double(10), actual=double(10), expected=double(10))

race_runners_temp <- race_runners %>% dplyr::filter(!is.na(isp))
race_runners_temp <- race_runners %>% dplyr::filter(!is.na(place_probability))

for (i in 1:10) {
  place_results$probability_fraction[i] <- i/10
  place_results$actual[i] <- race_runners_temp %>% dplyr::filter(place_probability <= (i / 10) & place_probability > ((i - 1) / 10)) %$% sum(placed_bool)
  place_results$actual[i] <- place_results$actual[i] + race_runners_temp %>% dplyr::filter(place_probability <= (i / 10) & place_probability > ((i - 1) / 10)) %$% sum(won_bool)
  place_results$expected[i] <- race_runners_temp %>% dplyr::filter(place_probability <= (i / 10) & place_probability > ((i - 1) / 10)) %$% sum(place_probability)
  }

print(sum(place_results$actual))
print(sum(place_results$expected))

place_results$aoe <- place_results$actual / place_results$expected

actual <- sum(race_runners_temp$placed_bool) + sum(race_runners_temp$won_bool)
expected <- sum(race_runners_temp$place_probability)