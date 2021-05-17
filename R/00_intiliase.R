# about ---------
# 00_initialise.R
#
# this file initialises the workspace

# clear workspace ------
rm(list = ls())

# set working directory -------
working_directory <- dirname(rstudioapi::getSourceEditorContext()$path)
working_directory <- paste(working_directory, "/..", sep = "")
setwd(working_directory)

# load library programs ---------------
library(tidyverse)
library(magrittr)
library(vroom)
library(httr)
library(XML)
library(rvest)
library(janitor)
library(odbc)
library(DBI)
library(naniar)
library(caret)
library(randomForest)
library(Metrics)
library(Hmisc)

# clear workspace ------
rm(list = ls())