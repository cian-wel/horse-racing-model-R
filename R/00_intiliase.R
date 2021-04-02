# set working directory -------
working_directory <- dirname(rstudioapi::getSourceEditorContext()$path)
working_directory <- paste(working_directory, "/..", sep = "")
setwd(working_directory)

# load library programs ---------------
library(tidyverse)