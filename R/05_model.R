# about ------
# script predicts rating horse will run to in race based on gbm model

# load available data -------
load(file = "output/trn_runners.rda")
load(file = "output/val_runners.rda")

# model -----
trn_predictors <- trn_runners %>%
  select(
    lto_pr,
    rec_med_pr,
    med_pr,
    max_pr,
    lto_spd,
    rec_med_spd,
    med_spd,
    max_spd,
    num_runs
  )

trn_output <- trn_runners$pr

val_predictors <- val_runners %>%
  select(
    lto_pr,
    rec_med_pr,
    med_pr,
    max_pr,
    lto_spd,
    rec_med_spd,
    med_spd,
    max_spd,
    num_runs
  )

val_output <- val_runners$pr

pr_model <- train(x = trn_predictors, y = trn_output, method = "gbm")

print("training set")
print(rmse(predict(pr_model, trn_predictors), trn_output))

print("validation set")
print(rmse(predict(pr_model, val_predictors), val_output))


# save predictions to datasets
trn_runners$pred_pr = predict(pr_model, trn_runners)
val_runners$pred_pr = predict(pr_model, val_runners)

# save file -----
saveRDS(pr_model, file = "output/pr_model.rds")
save(trn_runners, file = "output/trn_runners.rda")
save(val_runners, file = "output/val_runners.rda")

# clear workspace ----
rm(list = ls())