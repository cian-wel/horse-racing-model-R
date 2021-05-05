# about ------
# script predicts rating horse will run to in race

# load available data -------
load(file = "output/ds_past_horses.rda")
load(file = "output/trn_past_races.rda")
load(file = "output/trn_past_runners.rda")
load(file = "output/val_past_races.rda")
load(file = "output/val_past_runners.rda")


trn_past_runners <- trn_past_runners %>%
  filter(!is.na(trn_past_runners$pf_speed_rating) &
           !is.na(lto_rating) &
           !is.na(three_mon_rating) &
           !is.na(six_mon_rating) &
           !is.na(life_rating) &
           !is.na(max_rating))

# model -----
rating_model = train(pf_speed_rating ~ lto_rating + three_mon_rating +
                       six_mon_rating + life_rating + max_rating,
                     method = 'gbm', data = trn_past_runners, verbose = F)

# save predictions to datasets
trn_past_runners$predicted_rating = predict(rating_model, trn_past_runners)

# save file -----
saveRDS(rating_model, "output/rating_model.rds")
save(trn_past_runners, file = "output/trn_past_runners.rda")

# clear workspace ----
# rm(list = ls())