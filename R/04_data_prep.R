# about ------
# preps data for model

# load available data -------
load(file = "output/ds_past_horses.rda")
load(file = "output/ds_past_races.rda")
load(file = "output/ds_past_runners.rda")

load(file = "data/past_horses.rda")
load(file = "data/past_races.rda")
load(file = "data/past_runners.rda")

# add data columns to ds_past_runners ----

ds_past_runners$lto_rating <- 0
ds_past_runners$three_mon_rating <- 0
ds_past_runners$six_mon_rating <- 0
ds_past_runners$life_rating <- 0
ds_past_runners$max_rating <- 0

for (i in 1:nrow(ds_past_runners)) {
  
  # check to make sure there is a previous race for this runner
  # to be fixed
  if(!is.na(ds_past_runners$prev_race[i])) {
    
    # fill up the previous races dataframe
    prev_races <- data.frame(ds_past_horses$races[
      ds_past_horses$horse_id == ds_past_runners$horse_id[i]])
    colnames(prev_races) <- c("race_id")
    prev_races <- prev_races %>%
      filter(race_id < ds_past_runners$race_id[i])
    
    prev_races$rating <- past_runners$pf_speed_rating[
      past_runners$horse_id == ds_past_runners$horse_id[i] &
        past_runners$race_id %in% prev_races$race_id]
    
    prev_races$days_since <- trunc(past_races$date_time[
      past_races$race_id == ds_past_runners$race_id[i]] - past_races$date_time[
        past_races$race_id %in% prev_races$race_id])
    
    # set ratings
    ds_past_runners$max_rating[i] <- max(prev_races$rating)
    ds_past_runners$life_rating[i] <- mean(prev_races$rating)
    
    if(prev_races$days_since[nrow(prev_races)] > 180) {
      ds_past_runners$six_mon_rating[i] <- NA
      ds_past_runners$three_mon_rating[i] <- NA
      ds_past_runners$lto_rating[i] <- NA
    }
    else if(prev_races$days_since[nrow(prev_races)] > 90) {
      ds_past_runners$six_mon_rating[i] <- mean(prev_races$rating[
        prev_races$days_since < 180])
      ds_past_runners$three_mon_rating[i] <- NA
      ds_past_runners$lto_rating[i] <- NA
    }
    else {
      ds_past_runners$six_mon_rating[i] <- mean(prev_races$rating[
        prev_races$days_since < 180])
      ds_past_runners$three_mon_rating[i] <- mean(prev_races$rating[
        prev_races$days_since < 90])
      ds_past_runners$lto_rating[i] <- prev_races$rating[nrow(prev_races)]    
    }
    print(i)
  }
}

# create training and validation datasets ---------

# create a list of 70% of the races in the original dataset we can use for
# training
training_race_id <- ds_past_races$race_id[
  createDataPartition(ds_past_races$race_id, p=0.7, list=FALSE)]

val_past_races <- ds_past_races[!ds_past_races$race_id %in% training_race_id,]
val_past_runners <- ds_past_runners[!ds_past_runners$race_id
                                    %in% training_race_id,]
trn_past_races <- ds_past_races[ds_past_races$race_id %in% training_race_id,]
trn_past_runners <- ds_past_runners[ds_past_runners$race_id
                                    %in% training_race_id,]

# save files -----
save(val_past_races, file = "output/val_past_races.rda")
save(val_past_runners, file = "output/val_past_runners.rda")
save(trn_past_races, file = "output/trn_past_races.rda")
save(trn_past_runners, file = "output/trn_past_runners.rda")

# clear workspace ------
rm(list = ls())