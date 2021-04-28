# about -----
# this file imports data from betfair databases (online csv files) and saves
# to .rda files in data/
# due to time constraints saves by year

# assign year we're looking for------

# define year we're looking for
year <- "2008"

# access website ------

# save url location
betfair_url <- "https://promo.betfair.com/betfairsp/prices/"

# read webpage, get table, save as dataframe
betfair_webpage <- read_html(betfair_url)

betfair_info_table <- betfair_webpage %>% html_table()
betfair_info_table <- betfair_info_table[[2]]

betfair_info_table <- betfair_info_table %>%
  row_to_names(row_number = 1) %>%
  rename(
    file_name = Filename,
    date_created = `Date Created`,
    date_last_accessed = `Date Last Accessed`,
    date_last_modified = `Date Last Modified`,
    file_size = `Size (kB)`
  )

# update variable types
betfair_info_table$file_size <- as.numeric(betfair_info_table$file_size)
betfair_info_table$date_created <- as.Date(betfair_info_table$date_created, format = "%b %d, %Y")
betfair_info_table$date_last_accessed <- as.POSIXct(betfair_info_table$date_last_accessed, format = "%b %d, %Y, %H:%M:%S")
betfair_info_table$date_last_modified <- as.POSIXct(betfair_info_table$date_last_modified, format = "%b %d, %Y, %H:%M:%S")

# filter to just irish and uk racing
betfair_horse_racing <- betfair_info_table %>%
  dplyr::filter(str_detect(file_name, 'dwbfpricesire|dwbfpricesuk'))

# filter out blank files (size 0.0)
betfair_horse_racing <- betfair_horse_racing %>%
  dplyr::filter(file_size!=0)

# add in links column to table
betfair_horse_racing$links <- paste("https://promo.betfair.com/betfairsp/prices/", betfair_horse_racing$file_name, sep ="")

# define year we're looking for
betfair_horse_racing <- betfair_horse_racing %>%
  dplyr::filter(str_detect(links, paste(year, ".csv", sep = "")))

# access win data and save to data folder ----------

# add win data to dataframe and save to data folder
betfair_win_links <- betfair_horse_racing %>%
  dplyr::filter(!str_detect(links, 'place'))
betfair_win_links <- betfair_win_links$links

betfair_win_data <- vroom(betfair_win_links)

betfair_win_data <- betfair_win_data %>%
  rename(
    event_id = EVENT_ID,
    menu_hint = MENU_HINT,
    market = EVENT_NAME,
    start_time = EVENT_DT,
    selection_id = SELECTION_ID,
    name = SELECTION_NAME,
    win_bool = WIN_LOSE,
    bsp = BSP,
    avg_pre_off = PPWAP,
    avg_morning = MORNINGWAP,
    max_pre_off = PPMAX,
    min_pre_off = PPMIN,
    max_in_play = IPMAX,
    min_in_play = IPMIN,
    volume_morning = MORNINGTRADEDVOL,
    volume_pre_off = PPTRADEDVOL,
    volume_in_play = IPTRADEDVOL
  )

# save to file

assign(paste0("betfair_win_data_", year),betfair_win_data)
Object = get(paste0("betfair_win_data_", year))
save(Object, file = paste0("data/betfair_win_data_", year, ".rda"))

# save place data to file in data ----------

# add place data to dataframe and save to data folder
betfair_place_links <- betfair_horse_racing %>%
  dplyr::filter(str_detect(links, 'place'))
betfair_place_links <- betfair_place_links$links

betfair_place_data <- vroom(betfair_place_links)

betfair_place_data <- betfair_place_data %>%
  rename(
    event_id = EVENT_ID,
    menu_hint = MENU_HINT,
    market = EVENT_NAME,
    start_time = EVENT_DT,
    selection_id = SELECTION_ID,
    name = SELECTION_NAME,
    win_bool = WIN_LOSE,
    bsp = BSP,
    avg_pre_off = PPWAP,
    avg_morning = MORNINGWAP,
    max_pre_off = PPMAX,
    min_pre_off = PPMIN,
    max_in_play = IPMAX,
    min_in_play = IPMIN,
    volume_morning = MORNINGTRADEDVOL,
    volume_pre_off = PPTRADEDVOL,
    volume_in_play = IPTRADEDVOL
  )

# identify year and save to file

assign(paste0("betfair_place_data_", year),betfair_place_data)
Object = get(paste0("betfair_place_data_", year))
save(Object, file = paste0("data/betfair_place_data_", year, ".rda"))