# about ----
# this script takes model for rating and simulates results

# variables -----
simulations = as.integer(20000)
stan_dev = as.integer(15)

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
load(file = "output/trn_runners.rda")
load(file = "output/val_runners.rda")

# adjust predicted pr ----
sim_runners <- rbind(trn_runners, val_runners)

sim_runners$adj_pred_pr <- sim_runners$pred_pr - sim_runners$or -
  sim_runners$pen

# run simulation -----
sim_runners = sim_runners[order(sim_runners$race_id, sim_runners$horse_id),]

print("start")
sim_runners$win_chance = (sim_race(sim_runners[
  ,c("race_id", "horse_id", "adj_pred_pr")], stan_dev, simulations) - 1) /
  simulations
sim_runners$win_price = 1 / sim_runners$win_chance
print("finished")

# save files ----
save(sim_runners, file = "output/sim_runners.rda")

# clear workspace ------
# rm(list = ls())