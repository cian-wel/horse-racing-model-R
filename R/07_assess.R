# about ------
# script assesses model:
# profitability at evening prices (EP),
# breakfast prices (BP), and morning prices (MP)
# log loss (compared to BSP)
#
# tests both training and validation data sets

# load files ----

load(file = "output/trn_past_runners.rda")

# data edit -----
# add won to data
trn_past_runners$won <- 0
trn_past_runners$won[trn_past_runners$finish_position == 1] <- 1
trn_past_runners$win_bsp <- trn_past_runners$win_bsp + 1

# assess training data set -----

assessment <- as.data.frame(matrix(0, ncol = 6, nrow = 1))
rownames(assessment) <- "main"
colnames(assessment) <- c("log_loss", "bsp_log_loss", "ep", "bp", "mp", "bsp")

# log loss of estimated prices
log_loss <- as.vector(-(trn_past_runners$won * log(trn_past_runners$win_chance)
                      + (1 - trn_past_runners$won) *
                        log(1 - trn_past_runners$win_chance)))
log_loss <- log_loss[is.finite(log_loss)]
assessment$log_loss <- mean(log_loss)

# log loss of bsp
bsp_log_loss <- as.vector(-(trn_past_runners$won * log(1 / trn_past_runners$win_bsp)
                        + (1 - trn_past_runners$won) *
                          log(1 - (1 / trn_past_runners$win_bsp))))
assessment$bsp_log_loss <- mean(bsp_log_loss)

