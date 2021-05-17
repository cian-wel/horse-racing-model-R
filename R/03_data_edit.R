# about ------
# 03_data_edit.R
# this script edits the data in data/ and outputs to outputs/
# this script cleans the data and calculates new data fields
# selects only flat races since 01 Jan 2016

# variables ----

# define lb/l scale
bha_a <- 1755.1
bha_b <- -0.897

# load data ----
load(file = "data/lookups.rda")
load(file = "data/races.rda")
load(file = "data/runners.rda")
load(file = "data/horses.rda")

# runners general data cleaning --------

# clean to N/A bsp = -1 (no BSP) or 0 (no BSP yet)
ds_runners <- runners
ds_runners <- ds_runners %>%
  replace_with_na(replace = list(win_bsp =c(-1, 0), pf_spd_rating = 0))

# add 1 to bsp (bsp not in true decimal odds)
ds_runners$win_bsp <- ds_runners$win_bsp + 1

# replace lookups
ds_runners <- ds_runners %>%
  left_join(select(jockey_lookup, name, id), by = c("jock_id" = "id")) %>%
  rename(jock_name = name) %>%
  select(-jock_id)

ds_runners <- ds_runners %>%
  left_join(select(trainer_lookup, name, id), by = c("trainer_id" = "id")) %>%
  rename(trainer_name = name) %>%
  select(-trainer_id)

# races general data cleaning ------
# replace lookups
ds_races <- races
ds_races <- ds_races %>%
  left_join(select(course_lookup, name, id, country, direct, character),
            by = c("course_id" = "id")) %>%
  rename(
    crse_name = name,
    crse_country = country,
    crse_direct = direct,
    crse_character = character
  ) %>%
  select(-course_id)

ds_races <- ds_races %>%
  left_join(select(distance_lookup, yard, id), by = c("dist_id" = "id")) %>%
  rename(dist = yard) %>%
  select(-dist_id)

ds_races <- ds_races %>%
  left_join(select(going_lookup, descr, id), by = c("off_going" = "id")) %>%
  select(-off_going) %>%
  rename(off_going = descr)

ds_races <- ds_races %>%
  left_join(select(going_lookup, descr, id), by = c("act_going" = "id")) %>%
  select(-act_going) %>%
  rename(act_going = descr)

ds_races <- ds_races %>%
  left_join(select(race_type_lookup, descr, id, jumps),
            by = c("type" = "id")) %>%
  select(-type) %>%
  rename(type = descr)

# horses general data cleaning -----
ds_horses <- horses
ds_horses$dob <- as.Date(ds_horses$dob, format = "%d/%m/%Y")

# assign number of places to data ----
places = as.vector(replicate(nrow(races), 0))

places[which(races$runners <= 4)] <- 1
places[which(races$runners > 4 & races$runners <= 7)] <- 2
# set all greater than 7 to 3 and then reset 4 if required
places[which(races$runners > 7)] <- 3
# temporary fix while race categories not available
places[which(races$runners > 15 & grepl("andicap", races$race_name, TRUE))] <- 4

ds_races$places <- places

# add number of places to runners data
ds_runners$places[ds_runners$race_id %in%
                    ds_races$race_id[ds_races$places == 1]] <- 1
ds_runners$places[ds_runners$race_id %in%
                    ds_races$race_id[ds_races$places == 2]] <- 2
ds_runners$places[ds_runners$race_id %in%
                    ds_races$race_id[ds_races$places == 3]] <- 3
ds_runners$places[ds_runners$race_id %in%
                    ds_races$race_id[ds_races$places == 4]] <- 4

# select races we want to look at. Filter other data as required -----
ds_races <- ds_races %>%
  filter(
    jumps == FALSE &
    type != "NHF" &
    date_time >= as.Date("2016-01-01")
  )

# get corresponding runners and horses
ds_runners <- ds_runners[ds_runners$race_id %in% ds_races$race_id[],]
ds_horses <- ds_horses[ds_horses$horse_id %in% ds_runners$horse_id[],]

# reset row ids
rownames(ds_races) <- NULL
rownames(ds_runners) <- NULL
rownames(ds_horses) <- NULL

# add horse races column to horses db-----
ds_horses$races <- 0

for (i in 1:nrow(ds_horses)) {
  ds_horses$races[i] <- I(list(ds_runners$race_id[
    ds_runners$horse_id == ds_horses$horse_id[i]]))
  print(i)
}

# get prs of winners and assign to runners db -----

# get dataframe on winners
ds_winners <- as.data.frame(ds_runners$horse_id[ds_runners$fin_pos == 1])
colnames(ds_winners) <- c("horse_id")
ds_winners$race_id <- ds_runners$race_id[ds_runners$fin_pos == 1]
ds_winners$ran <- TRUE
ds_winners$pr <- 0

ds_runners$winner_pr <- 0

for (i in 1:(nrow(ds_winners))) {
  # check if has next run
  winner_races <- as.data.frame(ds_horses$races[
    ds_horses$horse_id == ds_winners$horse_id[i]])
  ds_winners$ran[i] <- isTRUE(
    ds_winners$race_id[i] < winner_races[nrow(winner_races),1])
  
  # get pr of winner
  if (ds_winners$ran[i]) {
    idx <- which(ds_runners$race_id == winner_races[(
      which(winner_races[,1] == ds_winners$race_id[i]) + 1),] &
        ds_runners$horse_id == ds_winners$horse_id[i])
    
    if(length(ds_runners$or[idx]) > 0) {
      ds_winners$pr[i] <- ds_runners$or[idx] + ds_runners$pen[idx]
    }
    else {
      ds_winners$pr[i] <- NA
    }
    
    # assign pr to race and winner_pr
    ds_runners$winner_pr[ds_runners$race_id == ds_winners$race_id[i]] <-
      ds_winners$pr[i]
  }
  print(i)
}

# exclude races in which winner pr == 0
ds_runners <- ds_runners[ds_runners$winner_pr != 0,]
ds_races <- ds_races[ds_races$race_id %in% ds_runners$race_id[],]
ds_horses <- ds_horses[ds_horses$horse_id %in% ds_runners$horse_id[],]

rownames(ds_races) <- NULL
rownames(ds_runners) <- NULL
rownames(ds_horses) <- NULL

# assign pr to each runner
ds_runners <- ds_runners %>%
  left_join(select(ds_races, dist, race_id), by = c("race_id"))
ds_runners$pr <- ds_runners$winner_pr -
  ds_runners$dist_to_winr * bha_a * (ds_runners$dist ^ bha_b)
ds_runners <- ds_runners %>% select(-winner_pr)

ds_runners$pr <- replace(ds_runners$pr, which(ds_runners$pr <= 0), 0)


# save files ------
save(ds_runners, file = "output/ds_runners.rda")
save(ds_races, file = "output/ds_races.rda")
save(ds_horses, file = "output/ds_horses.rda")

# clear workspace ------
rm(list = ls())