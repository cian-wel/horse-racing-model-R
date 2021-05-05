# about ---------
# 01_proform_data_import.R
#
# This file links to the proform database as creates the database we want to
# work with
# saves this data to data/

# connect to proform database -----------
proform_db_connection <- dbConnect(odbc(), 
                                   Driver = "SQL Server", 
                                   Server = "localhost\\PROFORM_RACING", 
                                   Database = "PRODB",
                                   Trusted_Connection = TRUE)

# create new horse database -----

past_horses <- dbGetQuery(proform_db_connection, "SELECT H_No, H_Name,
                            H_country, H_Sex, H_FoalDate, H_Dam, H_Dam_yearBorn,
                            H_Dam_bred, H_Sire, H_Sire_yearBorn, H_Sire_bred,
                            H_DamSire, H_DamSire_yearBorn, H_DamSire_bred,
                            H_Breeders_Name
                           FROM NEW_H")
past_horses <- past_horses %>%
  rename(
    horse_id = H_No,
    name = H_Name,
    country = H_country,
    sex = H_Sex,
    dob = H_FoalDate,
    dam = H_Dam,
    dam_yob = H_Dam_yearBorn,
    dam_bred = H_Dam_bred,
    sire = H_Sire,
    sire_yob = H_Sire_yearBorn,
    sire_bred = H_Sire_bred,
    damsire = H_DamSire,
    damsire_yob = H_DamSire_yearBorn,
    damsire_bred = H_DamSire_bred,
    breeder = H_Breeders_Name
    )

# create new runners database -----------
past_runners <- dbGetQuery(proform_db_connection, "SELECT RH_RNo, HIR_HNo,
                            HIR_DistanceToWinner, HIR_Age, J_No,
                            HIR_JockeysClaim, T_No, HIR_Pounds, HIR_PositionNo,
                            HIR_TimeInSeconds, HIR_Rating, HIR_Drawn,
                            HIR_PaceAbbrev, HIR_FinPaceAbbrev, HIR_PrevRNo,
                            HIR_OfficialRating, HIR_UserRating10, HIR_PFR,
                            HIR_Headgear, HIR_Penalty, HIR_BSP
                           FROM vw_Races")
past_runners <- past_runners %>%
  rename(
    race_id = RH_RNo,
    horse_id = HIR_HNo,
    distance_to_winner = HIR_DistanceToWinner,
    age = HIR_Age,
    jockey_id = J_No,
    jockey_claim = HIR_JockeysClaim,
    trainer_id = T_No,
    weight = HIR_Pounds,
    finish_position = HIR_PositionNo,
    time = HIR_TimeInSeconds,
    pf_speed_rating = HIR_Rating,
    draw = HIR_Drawn,
    pace = HIR_PaceAbbrev,
    fin_pace = HIR_FinPaceAbbrev,
    prev_race = HIR_PrevRNo,
    or = HIR_OfficialRating,
    pf_power_rating = HIR_UserRating10,
    pf_rating = HIR_PFR,
    headgear = HIR_Headgear,
    penalty = HIR_Penalty,
    win_bsp = HIR_BSP,
    )

# create new races database ---------
past_races <- dbGetQuery(proform_db_connection, "SELECT RH_RNo, RH_CNo, RH_Name,
                            RH_Value, RH_NoOfRunners, RH_Class, RH_RaceTypeID,
                            RH_GoingID, RH_ActualGoingID, RH_DistanceID,
                            RH_MinAge, RH_MaxAge, RH_HandicapLimit, RH_DateTime,
                            RH_ClassNum
                           FROM NEW_RH")

past_races <- past_races %>%
  rename(
    race_id = RH_RNo,
    course_id = RH_CNo,
    race_name = RH_Name,
    value = RH_Value,
    num_runners = RH_NoOfRunners,
    race_class = RH_Class,
    type = RH_RaceTypeID,
    official_going = RH_GoingID,
    actual_going = RH_ActualGoingID,
    distance_id = RH_DistanceID,
    min_age = RH_MinAge,
    max_age = RH_MaxAge,
    hc_limit = RH_HandicapLimit,
    date_time = RH_DateTime,
    class_num = RH_ClassNum
  )

# get lookup tables and rename ----------
distance_lookup <- dbGetQuery(proform_db_connection, "SELECT D_ID, D_Distance,
                            D_TotalYards
                           FROM DistanceLookups")
distance_lookup <- distance_lookup %>%
  rename(
    id = D_ID,
    description = D_Distance,
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
     going_lookup, jockey_lookup, race_type_lookup,
     trainer_lookup, file = "data/data_lookups.rda")
save(past_races, file = "data/past_races.rda")
save(past_runners, file = "data/past_runners.rda")
save(past_horses, file = "data/past_horses.rda")

# clear workspace ------
rm(list = ls())