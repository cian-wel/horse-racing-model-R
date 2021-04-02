# proform data ---------
# load data and save to file
proform_data <- read_csv("data/proform_data.csv")

# rename columns
proform_data <- proform_data %>%
  rename(
    race_time = `Race Time`,
    course = Course,
    course_type = `Course Characteristics`,
    prize = Prize,
    distance = `Distance (y)`,
    race_type = `Race Type`,
    number_runners = Runners,
    hc_limit = `Handicap Limit`,
    going = Going,
    draw = Draw,
    finish_position = Position,
    horse = Horse,
    distance_to_next = DTN,
    distance_to_winner = DTW,
    jockey = Jockey,
    trainer = Trainer,
    age = Age,
    weight = `Weight (pounds)`,
    days_since_last_run = DSLR,
    equipment = Equip,
    sex = `Sex Abbrev`,
    sire = Sire,
    form = `Form String`,
    pace_history = `Pace String`,
    isp = `SP Odds Decimal`,
    bsp = `BF Decimal SP`,
    comments = `Comments In Running`,
    won_bool = `Won (1=Won, 0=Lost)`,
    placed_bool = `Place (1=Placed, 0=UnPlaced)`,
    official_rating = OR,
    evening_price = `Evening Price`,
    breakfast_price = `Breakfast Price`,
    morning_price = `Morning Price`
  )

# save data to data folder
save(proform_data, file = "data/proform_data.Rda")
