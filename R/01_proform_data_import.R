# about ---------
# 01_proform_data_import.R
#
# This file links to the proform database as creates the database we want to
# work with
# saves this data to data/

# connect to proform database -----------
pf_db_con <- dbConnect(odbc(), 
                       Driver = "SQL Server", 
                       Server = "localhost\\PROFORM_RACING", 
                       Database = "PRODB",
                       Trusted_Connection = TRUE)

# create new horse database -----

horses <- dbGetQuery(pf_db_con, "SELECT H_No, H_Name, H_country, H_Sex,
                            H_FoalDate, H_Dam, H_Dam_yearBorn, H_Dam_bred,
                            H_Sire, H_Sire_yearBorn, H_Sire_bred, H_DamSire,
                            H_DamSire_yearBorn, H_DamSire_bred, H_Breeders_Name
                           FROM NEW_H")
horses <- horses %>%
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
runners <- dbGetQuery(pf_db_con, "SELECT RH_RNo, HIR_HNo, HIR_DistanceToWinner,
                            HIR_Age, J_No, HIR_JockeysClaim, T_No, HIR_Pounds,
                            HIR_PositionNo,HIR_TimeInSeconds, HIR_Rating,
                            HIR_Drawn, HIR_PaceAbbrev, HIR_FinPaceAbbrev,
                            HIR_PrevRNo, HIR_OfficialRating, HIR_UserRating10,
                            HIR_PFR, HIR_Headgear, HIR_Penalty, HIR_BSP,
                            HIR_EveningPrice, HIR_BreakfastPrice,
                            HIR_MorningPrice
                           FROM vw_Races")
runners <- runners %>%
  rename(
    race_id = RH_RNo,
    horse_id = HIR_HNo,
    dist_to_winr = HIR_DistanceToWinner,
    age = HIR_Age,
    jock_id = J_No,
    jock_claim = HIR_JockeysClaim,
    trainer_id = T_No,
    weight = HIR_Pounds,
    fin_pos = HIR_PositionNo,
    time = HIR_TimeInSeconds,
    pf_spd_rating = HIR_Rating,
    draw = HIR_Drawn,
    pace = HIR_PaceAbbrev,
    fin_pace = HIR_FinPaceAbbrev,
    prev_race = HIR_PrevRNo,
    or = HIR_OfficialRating,
    pf_pwr_rating = HIR_UserRating10,
    pf_rating = HIR_PFR,
    headgr = HIR_Headgear,
    pen = HIR_Penalty,
    win_bsp = HIR_BSP,
    eve_price = HIR_EveningPrice,
    break_price = HIR_BreakfastPrice,
    morn_price = HIR_MorningPrice
    )

# create new races database ---------
races <- dbGetQuery(pf_db_con, "SELECT RH_RNo, RH_CNo, RH_Name, RH_Value,
                            RH_NoOfRunners, RH_Class, RH_RaceTypeID, RH_GoingID,
                            RH_ActualGoingID, RH_DistanceID, RH_MinAge,
                            RH_MaxAge, RH_HandicapLimit, RH_DateTime,
                            RH_ClassNum
                           FROM NEW_RH")

races <- races %>%
  rename(
    race_id = RH_RNo,
    course_id = RH_CNo,
    race_name = RH_Name,
    value = RH_Value,
    runners = RH_NoOfRunners,
    class = RH_Class,
    type = RH_RaceTypeID,
    off_going = RH_GoingID,
    act_going = RH_ActualGoingID,
    dist_id = RH_DistanceID,
    min_age = RH_MinAge,
    max_age = RH_MaxAge,
    hc_limit = RH_HandicapLimit,
    date_time = RH_DateTime,
    class_num = RH_ClassNum
  )

# get lookup tables and rename ----------
distance_lookup <- dbGetQuery(pf_db_con, "SELECT D_ID, D_Distance, D_TotalYards
                           FROM DistanceLookups")
distance_lookup <- distance_lookup %>%
  rename(
    id = D_ID,
    descr = D_Distance,
    yard = D_TotalYards
  )

going_lookup <- dbGetQuery(pf_db_con, "SELECT G_ID, G_Going
                           FROM GoingLookups")
going_lookup <- going_lookup %>%
  rename(
    id = G_ID,
    descr = G_Going
  )

classification_lookup <- dbGetQuery(pf_db_con, "SELECT CLK_ID, CLK_Desc
                           FROM ClassificationLookups")
classification_lookup <- classification_lookup %>%
  rename(
    id = CLK_ID,
    descr = CLK_Desc
  )

form_letters_lookup <- dbGetQuery(pf_db_con, "SELECT FPL_ID, FPL_Text
                           FROM FinishingPositionLookups")
form_letters_lookup <- form_letters_lookup %>%
  rename(
    id = FPL_ID,
    descr = FPL_Text
  )

course_lookup <- dbGetQuery(pf_db_con, "SELECT C_ID, C_Name, C_Country,
                              C_Direction, C_Characteristics
                            FROM NEW_C")
course_lookup <- course_lookup %>%
  rename(
    id = C_ID,
    name = C_Name,
    country = C_Country,
    direct = C_Direction,
    character = C_Characteristics
  )

race_type_lookup <- dbGetQuery(pf_db_con, "SELECT RTL_ID, RTL_Description,
                              RTL_Jumps
                            FROM RaceTypeLookups")
race_type_lookup <- race_type_lookup %>%
  rename(
    id = RTL_ID,
    descr = RTL_Description,
    jumps = RTL_Jumps
  )

jockey_lookup <- dbGetQuery(pf_db_con, "SELECT J_No, J_Name
                           FROM NEW_J")
jockey_lookup <- jockey_lookup %>%
  rename(
    id = J_No,
    name = J_Name
  )

trainer_lookup <- dbGetQuery(pf_db_con, "SELECT T_No, T_Name
                           FROM NEW_T")
trainer_lookup <- trainer_lookup %>%
  rename(
    id = T_No,
    name = T_Name
  )

# save data to .Rda files ---------
save(classification_lookup, course_lookup, distance_lookup, form_letters_lookup,
     going_lookup, jockey_lookup, race_type_lookup, trainer_lookup,
     file = "data/lookups.rda")
save(races, file = "data/races.rda")
save(runners, file = "data/runners.rda")
save(horses, file = "data/horses.rda")

# clear workspace ------
rm(list = ls())