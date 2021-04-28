# about ---------
# This file links to the proform database as creates the database we want to
# work with
# saves this data to data/

# connect to proform database -----------
proform_db_connection <- dbConnect(odbc(), 
                                   Driver = "SQL Server", 
                                   Server = "localhost\\PROFORM_RACING", 
                                   Database = "PRODB",
                                   Trusted_Connection = TRUE)

# create new runners database -----------
past_runners <- dbGetQuery(proform_db_connection, "SELECT RH_Rno, HIR_HNo,
                            HIR_Won, HIR_Placed, J_No, T_No, HIR_BSP,
                            HIR_DistanceToWinner, HIR_PositionNo, HIR_Rating,
                            HIR_Drawn
                           FROM vw_Races")
past_runners <- past_runners %>%
  rename(
    race_id = RH_Rno,
    horse_id = HIR_HNo,
    won = HIR_Won,
    placed = HIR_Placed,
    jockey_id = J_No,
    trainer_id = T_No,
    bsp = HIR_BSP,
    distance_to_winner = HIR_DistanceToWinner,
    finish_position = HIR_PositionNo,
    pf_speed_rating = HIR_Rating,
    draw =HIR_Drawn
    )

# clean to N/A bsp = -1 (no BSP) or 0 (no BSP yet)
past_runners <- past_runners %>%
  replace_with_na(replace = list(bsp =c(-1, 0)))

# assign placed = true to winners
past_runners$placed <- past_runners$placed + past_runners$won

# create new races database ---------
past_races <- dbGetQuery(proform_db_connection, "SELECT RH_RNo, RH_CNo,
                            RH_NoOfRunners, RH_DateTime, RH_RaceTypeID, RH_Name
                           FROM NEW_RH")
# 
past_races <- past_races %>%
  rename(
    race_id = RH_RNo,
    course_id = RH_CNo,
    num_runners = RH_NoOfRunners,
    race_datetime = RH_DateTime,
    race_type = RH_RaceTypeID,
    name = RH_Name
  )

# assign number of places to each
past_races$num_places <- integer(nrow(past_races))

past_races$num_places[which(past_races$num_runners <= 4)] <- 1
past_races$num_places[which(past_races$num_runners > 4 & 
                              past_races$num_runners <= 7)] <- 2
# set all greater than 7 to 3 and then reset
past_races$num_places[which(past_races$num_runners > 7)] <- 3
# temporary fix while race categories not available
past_races$num_places[which(past_races$num_runners > 15 & 
                              grepl("andicap", past_races$name, TRUE))] <- 4


# get lookup tables and rename ----------
distance_lookup <- dbGetQuery(proform_db_connection, "SELECT D_ID, D_Distance, 
                            D_TotalYards
                           FROM DistanceLookups")
distance_lookup <- distance_lookup %>%
  rename(
    id = D_ID,
    words = D_Distance,
    yard = D_TotalYards
  )

going_lookup <- dbGetQuery(proform_db_connection, "SELECT G_ID, G_Going
                           FROM GoingLookups")
going_lookup <- going_lookup %>%
  rename(
    id = G_ID,
    description = G_Going
  )

classification_lookup <- dbGetQuery(proform_db_connection, "SELECT CLK_ID, 
                            CLK_Desc
                           FROM ClassificationLookups")
classification_lookup <- classification_lookup %>%
  rename(
    id = CLK_ID,
    description = CLK_Desc
  )

form_letters_lookup <- dbGetQuery(proform_db_connection, "SELECT FPL_ID, 
                            FPL_Text
                           FROM FinishingPositionLookups")
form_letters_lookup <- form_letters_lookup %>%
  rename(
    id = FPL_ID,
    description = FPL_Text
  )

course_lookup <- dbGetQuery(proform_db_connection, "SELECT C_ID, C_Name, 
                              C_Country, C_Direction, C_Characteristics
                            FROM NEW_C")
course_lookup <- course_lookup %>%
  rename(
    id = C_ID,
    name = C_Name,
    country = C_Country,
    direction = C_Direction,
    characteristics = C_Characteristics
  )

race_type_lookup <- dbGetQuery(proform_db_connection, "SELECT RTL_ID, 
                              RTL_Description, RTL_Jumps
                            FROM RaceTypeLookups")
race_type_lookup <- race_type_lookup %>%
  rename(
    id = RTL_ID,
    description = RTL_Description,
    jumps_bool = RTL_Jumps
  )

horse_lookup <- dbGetQuery(proform_db_connection, "SELECT H_No, H_Name, H_Sex, 
                            H_Dam, H_Sire, H_DamSire, H_FoalDate
                           FROM NEW_H")
horse_lookup <- horse_lookup %>%
  rename(
    id = H_No,
    name = H_Name,
    sex = H_Sex,
    dam = H_Dam,
    sire = H_Sire,
    damsire = H_DamSire,
    dob = H_FoalDate
  )


jockey_lookup <- dbGetQuery(proform_db_connection, "SELECT J_No, J_Name
                           FROM NEW_J")
jockey_lookup <- jockey_lookup %>%
  rename(
    id = J_No,
    name = J_Name
  )

trainer_lookup <- dbGetQuery(proform_db_connection, "SELECT T_No, T_Name
                           FROM NEW_T")
trainer_lookup <- trainer_lookup %>%
  rename(
    id = T_No,
    name = T_Name
  )

# save data to .Rda files ---------
save(classification_lookup, course_lookup, distance_lookup, form_letters_lookup,
     going_lookup, horse_lookup, jockey_lookup, race_type_lookup, 
     trainer_lookup, file = "data/data_lookups.rda")
save(past_races, file = "data/past_races.rda")
save(past_runners, file = "data/past_runners.rda")