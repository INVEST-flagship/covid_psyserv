# Install pacman for easy loading of packages
suppressMessages(
  if(!require(pacman)) {install.packages("pacman");library(pacman)}
)

# Load packages; add other needed
p_load(
  MASS,
  tidyverse, 
  stringr, 
  openxlsx, 
  knitr, 
  lubridate,
  codebook,
  haven,
  broom
)

# Utils functions
f_timestamp <- function() Sys.time() %>% str_replace_all(":| |-", "")
