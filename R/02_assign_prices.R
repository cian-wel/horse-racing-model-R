# about ------
# script assigns prices based on current model

# load available data -------

load(file = "data/proform_data.Rda")

race_runners <- proform_data


# calculate place probability based off BSP ------

# one place races
place_probability <- double(nrow(race_runners))
place_odds <- double(nrow(race_runners))
over_round <- 0.00
race_places <- 0.00

m <- 1
race_runners$win_probability <- double(nrow(race_runners))

# use while loop to go through database
while(m < nrow(race_runners)) {

  #define race as line m to line n
  n <- m + race_runners$number_runners[m] - 1
  
  #get over round for race
  over_round <- sum(1 / race_runners$bsp[m:n])
  # print(over_round)
  
  # add in no vig win probability
  race_runners$win_probability[m:n] <- (1 / race_runners$bsp[m:n]) / over_round
  
  # get number of places for the race
  race_places <- sum(race_runners$placed_bool[m:n]) + sum(race_runners$won_bool[m:n])
  # print(race_places)
  
  # get place probability for each race
  # one place
  place_probability[m:n] <- race_runners$win_probability[m:n]

  # two places and on nested
  if (race_places > 1) {
    for (i in m:n) {
      
      # probability horse j wins and i second
      # loops through all js and adds up probability
      for(j in m:n) {
        if (j != i) {
          #probability horse j wins and horse i places 2nd
          place_probability[i] <- place_probability[i] + race_runners$win_probability[j] * race_runners$win_probability[i] / (1 - race_runners$win_probability[j])
          
          #three places
          if (race_places > 2) {
            #probability horse j wins, horse k (not i or j) finish 2nd, and horse i places third
            for (k in m:n) {
              if (k != i && k != j) {
                place_probability[i] <- place_probability[i] + race_runners$win_probability[j] * race_runners$win_probability[k] / (1 - race_runners$win_probability[j]) * race_runners$win_probability[i] / (1 - race_runners$win_probability[j] - race_runners$win_probability[k])
                
                # four places
                if (race_places > 3) {
                  for (l in m:n) {
                    if (l != i && l != j && l != k) {
                      #probability horse j win, horse k (not i or j) finish 2nd, horse l (not i, j, or k) finish 3rd, and horse i places fourth
                      place_probability[i] <- place_probability[i] +  race_runners$win_probability[j] * race_runners$win_probability[k] / (1 - race_runners$win_probability[j]) * race_runners$win_probability[l] / (1 - race_runners$win_probability[j] - race_runners$win_probability[k]) * race_runners$win_probability[i] / (1 - race_runners$win_probability[j] - race_runners$win_probability[k] - race_runners$win_probability[l])
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  
  # move m on to next race    
  m <- n + 1

}

race_runners$place_probability <- place_probability
race_runners$place_odds <- 1 / place_probability

# save race data ------
save(race_runners, file = "data/race_runners.Rda")