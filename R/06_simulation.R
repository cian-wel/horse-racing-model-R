# about ----
# this script takes model for rating and simulates results

# variables -----
simulations = as.integer(1000)
stan_dev = as.integer(10)

# functions ------
monte_carlo = function(val, stan_dev, n) {
  result = val + rnorm(n, mean = val, sd = stan_dev)
  return(result)
}

sim_race = function(x, stan_dev, n) {
  results = vector("numeric", 0)
  for (i in 1:length(unique(x$race_id))) {
    x_race = subset(x, x$race_id == unique(x$race_id)[i])
    sim = vector()
    for (j in 1:length(x_race$horse_id)) {
      sim = cbind(sim, monte_carlo(as.numeric(x_race[j,3]), stan_dev, n))
    }
    winners = as.vector(1:length(x_race$race_id))
    for (k in 1:n) {
      winners = c(winners, which.max(sim[k,]))
    }
    results = c(results, as.vector(table(winners)))
  }
  return(results)
}

# load available data -----
load(file = "output/ds_past_horses.rda")
load(file = "output/trn_past_races.rda")
load(file = "output/trn_past_runners.rda")
load(file = "output/val_past_races.rda")
load(file = "output/val_past_runners.rda")

# run simulation -----

trn_past_runners = trn_past_runners[
  order(trn_past_runners$race_id, trn_past_runners$horse_id),]

trn_past_runners$win_chance = (sim_race(trn_past_runners[
  ,c("race_id", "horse_id", "predicted_rating")], stan_dev, simulations) - 1) /
  simulations

trn_past_runners$win_price = 1 / trn_past_runners$win_chance

# save files ----
save(trn_past_runners, file = "output/trn_past_runners.rda")

# clear workspace ------
rm(list = ls())