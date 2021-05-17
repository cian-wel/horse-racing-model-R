# horse-racing-model
Model to predict performance ratings of horses in GB & IRE. Takes data from proform database and betfair sp data files to create database. Performance ratings calculated based on next time out official ratings of the winner and performance ratings then calculated from lengths beaten.

Performance rating predicted using a gbm mode based on previous prs (condensed into last time out, recent, life, and max ratings), speed ratings, and days since last run. Performance rating predicted with rmse of 15. Races then simulated and winner priced using a monte carlo simulation.

Model is not profitable at any available price. Model provides marginally better ROI than betting random selections.

# Next steps
Likely source of bad results is due to "garbage in, garbage out". Basing performance ratings based on next time out official rating is highly flawed. Performance ratings can be assigned algorithmically on the principle of minimising future rating conflicts. This requires further investigation.
