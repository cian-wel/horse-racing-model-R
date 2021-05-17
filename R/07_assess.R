# about ------
# script assesses model:
# profitability at evening prices (EP),
# breakfast prices (BP), and morning prices (MP)
# log loss (compared to BSP)

# variables -----
bet_multiple <- 1.5
bank <- 1
kelly_multiple <- 0.25
comm <- 0.02

# load files ----
load(file = "output/sim_runners.rda")

# data edit -----
# add won to data
sim_runners$won <- 0
sim_runners$won[sim_runners$fin_pos == 1] <- 1

sim_runners$win_chance[sim_runners$win_chance < 0.001001] <- 0.0001001
sim_runners$win_price[sim_runners$win_price > 999] <- 999

# get random bets
set.seed(42)
rand_bets <- sim_runners[sample(nrow(sim_runners)),] %>%
  distinct(race_id, .keep_all = TRUE)

# assess data set -----

sim_ass <- as.data.frame(matrix(0, ncol = 6, nrow = 2))
rownames(sim_ass) <- c("main", "all")
colnames(sim_ass) <- c("log_loss", "bsp_log_loss", "eve_price", "break_price",
                       "morn_price", "win_bsp")

# log loss
log_loss <- as.vector(-(sim_runners$won * log(sim_runners$win_chance)
                      + (1 - sim_runners$won) *
                        log(1 - sim_runners$win_chance)))
sim_ass$log_loss[1] <- mean(log_loss)
bsp_log_loss <- as.vector(-(sim_runners$won * log(1 / sim_runners$win_bsp)
                        + (1 - sim_runners$won) *
                          log(1 - (1 / sim_runners$win_bsp))))
sim_ass$bsp_log_loss[1] <- mean(bsp_log_loss)

# evening price
eve_bets <- sim_runners %>%
  select(race_id, horse_id, eve_price, win_price, win_chance, won) %>%
  filter((eve_price - 1) / 1.5 > (win_price-1))

eve_bets$stake <- kelly_multiple * bank *
  (eve_bets$win_chance * eve_bets$eve_price - 1) / (eve_bets$eve_price - 1)
eve_bets$profit <- - eve_bets$stake +
  eve_bets$stake * eve_bets$eve_price * eve_bets$won

sim_ass$eve_price[1] <- summarise(eve_bets, sum(profit)/sum(stake))
sim_ass$eve_price[2] <- sum(-1 + rand_bets$eve_price * rand_bets$won) /
  nrow(rand_bets)

# breakfast price
break_bets <- sim_runners %>%
  select(race_id, horse_id, break_price, win_price, win_chance, won) %>%
  filter((break_price - 1) / 1.5 > (win_price-1))

break_bets$stake <- kelly_multiple * bank *
  (break_bets$win_chance * break_bets$break_price - 1) /
  (break_bets$break_price - 1)
break_bets$profit <- - break_bets$stake +
  break_bets$stake * break_bets$break_price * break_bets$won

sim_ass$break_price[1] <- summarise(break_bets, sum(profit)/sum(stake))
sim_ass$break_price[2] <- sum(-1 + rand_bets$break_price * rand_bets$won) /
  nrow(rand_bets)

# morning price
morn_bets <- sim_runners %>%
  select(race_id, horse_id, morn_price, win_price, win_chance, won) %>%
  filter((morn_price - 1) / 1.5 > (win_price-1))

morn_bets$stake <- kelly_multiple * bank *
  (morn_bets$win_chance * morn_bets$morn_price - 1) / (morn_bets$morn_price - 1)
morn_bets$profit <- - morn_bets$stake +
  morn_bets$stake * morn_bets$morn_price * morn_bets$won

sim_ass$morn_price[1] <- summarise(morn_bets, sum(profit)/sum(stake))
sim_ass$morn_price[2] <- sum(-1 + rand_bets$morn_price * rand_bets$won) /
  nrow(rand_bets)

# bsp
bsp_bets <- sim_runners %>%
  select(race_id, horse_id, win_bsp, win_price, win_chance, won) %>%
  filter((win_bsp - 1) / 1.5 > (win_price-1))

bsp_bets$stake <- kelly_multiple * bank *
  (bsp_bets$win_chance * bsp_bets$win_bsp - 1) / (bsp_bets$win_bsp - 1)
bsp_bets$profit <- - bsp_bets$stake +
  bsp_bets$stake * bsp_bets$win_bsp * bsp_bets$won
bsp_bets$profit[bsp_bets$profit > 0] <-
  bsp_bets$profit[bsp_bets$profit > 0] * (1 - comm)

sim_ass$win_bsp[1] <- summarise(bsp_bets, sum(profit)/sum(stake))
sim_ass$win_bsp[2] <- sum(-1 + (rand_bets$win_bsp * (1-comm)) * rand_bets$won) /
  nrow(rand_bets)

# save files ----
save(sim_ass, file = "output/sim_ass.rda")