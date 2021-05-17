# about ------
# 04_data_prep.R
# this script perfroms data prep prior to use in model

# load available data -------
load(file = "output/ds_horses.rda")
load(file = "output/ds_races.rda")
load(file = "output/ds_runners.rda")

# select races we want to look at. Filter other data as required -----
trn_races <- ds_races %>%
  filter(
    type == "A/W" &
      grepl("andicap", race_name, TRUE) &
      min_age >= 3 &
      crse_country == "(GB)" &
      date_time >= as.Date("2019-01-01")
  )
# reset row ids
rownames(trn_races) <- NULL

# get list of remaining race ids
trn_runners <- ds_runners[ds_runners$race_id %in% trn_races$race_id[],]
rownames(trn_runners) <- NULL

# get list of remaining horses
trn_horses <- ds_horses[ds_horses$horse_id %in% trn_runners$horse_id[],]
rownames(trn_horses) <- NULL

# add data columns to trn_runners ----

trn_runners$lto_pr <- 0
trn_runners$med_pr <- 0
trn_runners$rec_med_pr <- 0
trn_runners$max_pr <- 0
trn_runners$lto_spd <- 0
trn_runners$med_spd <- 0
trn_runners$rec_med_spd <- 0
trn_runners$max_spd <- 0
trn_runners$days_since <- 0
trn_runners$num_runs <- 0

exc_race_ids <- 0

for (i in 1:nrow(trn_runners)) {
  # fill up the previous races dataframe
  prev_races <- data.frame(trn_horses$races[
    trn_horses$horse_id == trn_runners$horse_id[i]])
  colnames(prev_races) <- c("race_id")
  
  trn_runners$num_runs[i] <- nrow(prev_races)

  # remove races ahead of this timepoint
  prev_races <- prev_races %>%
    filter(
      race_id < trn_runners$race_id[i],
      prev_races$race_id %in% ds_runners$race_id
      )

  # check to make sure prev_races still have length (i.e. has ran before in
  # system)
  if(nrow(prev_races) > 0) {
    

    # get prs of previous races
    prev_races$pr <- ds_runners$pr[
      ds_runners$horse_id == trn_runners$horse_id[i] &
        ds_runners$race_id %in% prev_races$race_id]
    
    # performance ratings
    trn_runners$max_pr[i] <- max(prev_races$pr, na.rm = TRUE)
    trn_runners$med_pr[i] <- median(prev_races$pr, na.rm = TRUE)
    trn_runners$rec_med_pr[i] <- median(c(
      prev_races$pr[nrow(prev_races)], prev_races$pr[nrow(prev_races)-1],
      prev_races$pr[nrow(prev_races)-2]), na.rm = TRUE)

    trn_runners$lto_pr[i] <- prev_races$pr[nrow(prev_races)]

    # get spd ratings of previous races
    prev_races$spd <- ds_runners$pf_spd_rating[
      ds_runners$horse_id == trn_runners$horse_id[i] &
        ds_runners$race_id %in% prev_races$race_id]

    # performance ratings
    trn_runners$max_spd[i] <- max(prev_races$spd, na.rm = TRUE)
    trn_runners$med_spd[i] <- median(prev_races$spd, na.rm = TRUE)
    trn_runners$rec_med_spd[i] <- median(c(
      prev_races$spd[nrow(prev_races)], prev_races$spd[nrow(prev_races)-1],
      prev_races$spd[nrow(prev_races)-2]), na.rm = TRUE)
    trn_runners$lto_spd[i] <- prev_races$spd[nrow(prev_races)]
    
    trn_runners$days_since[i] <- trunc(trn_races$date_time[
      trn_races$race_id == trn_runners$race_id[i]] -
        ds_races$date_time[
          ds_races$race_id == prev_races$race_id[nrow(prev_races)]])
    
    print(i)
  }
  else {
    # add others to this exclusion list
    exc_race_ids <- c(exc_race_ids, ds_runners$race_id[i])
    print("not i")
  }
}

# set min spd_ratings to 0 ---
trn_runners$max_spd <- replace(
  trn_runners$max_spd, which(trn_runners$max_spd < 0), 0)
val_runners$max_spd <- replace(
  val_runners$max_spd, which(val_runners$max_spd < 0), 0)

trn_runners$med_spd <- replace(
  trn_runners$med_spd, which(is.na(trn_runners$med_spd)), 0)
val_runners$med_spd <- replace(
  val_runners$med_spd, which(is.na(val_runners$med_spd)), 0)

trn_runners$rec_med_spd <- replace(
  trn_runners$rec_med_spd, which(is.na(trn_runners$rec_med_spd)), 0)
val_runners$rec_med_spd <- replace(
  val_runners$rec_med_spd, which(is.na(val_runners$rec_med_spd)), 0)

trn_runners$lto_spd <- replace(
  trn_runners$lto_spd, which(is.na(trn_runners$lto_spd)), 0)
val_runners$lto_spd <- replace(
  val_runners$lto_spd, which(is.na(val_runners$lto_spd)), 0)

# remove exclusion list -----
trn_runners <- trn_runners[!(trn_runners$race_id %in% exc_race_ids),]
trn_races <- trn_races[!(trn_races$race_id %in% exc_race_ids),]
trn_horses <- trn_horses[trn_horses$horse_id %in% trn_runners$horse_id,]

# create training and validation datasets ---------
trn_race_id <- trn_races$race_id[
  createDataPartition(trn_races$race_id, p=0.7, list=FALSE)]

val_races <- trn_races[!trn_races$race_id %in% trn_race_id,]
val_runners <- trn_runners[!trn_runners$race_id %in% trn_race_id,]
trn_races <- trn_races[trn_races$race_id %in% trn_race_id,]
trn_runners <- trn_runners[trn_runners$race_id %in% trn_race_id,]

# save files -----
save(val_races, file = "output/val_races.rda")
save(val_runners, file = "output/val_runners.rda")
save(trn_races, file = "output/trn_races.rda")
save(trn_runners, file = "output/trn_runners.rda")

# # clear workspace ------
rm(list = ls())