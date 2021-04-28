# about ----
# this script takes model for lengths beaten and turns it into a place
# probability

# functions ------
monte_carlo = function(val, StD, n) {
  result = val + rnorm(n, mean = val, sd = StD)
  return(result)
}

sim_day_min = function(x, StD, n) {
  results = vector("numeric", 0)
  for (i in 1:length(unique(x$race_id))) {
    x_race = subset(x, x$race_id == as.character(unique(x$race_id))[i])
    sim = vector()
    for (j in 1:length(x_race$draw)) {
      sim = cbind(sim, monte_carlo(as.numeric(x_race[j,3]), StD, n))
    }
    winners = as.vector(1:length(x_race$race_id))
    for (k in 1:n) {
      winners = c(winners, which.min(sim[k,]))
    }
    results = c(results, as.vector(table(winners)))
  }
  return(results)
}


dataset_train = dataset_train[order(dataset_train$race_id,
                                    dataset_training$draw),]
sim_train = dataset_training[,c("race_id", "draw",
                                "predicted_beaten_lengths")]

dataset_training$wins871 = sim_day_min(sim_train[,c(1,2,3)], 1.321, 200) -1
