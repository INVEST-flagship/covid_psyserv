# Load previous scripts ---------------------------------------------------

# library(tidyverse)

source("code//00_pkgs_utils.R")

Sys.setlocale(locale="UTF-8")

# Read data ---------------------------------------------------------------

# https://pxnet2.stat.fi/PXWeb/pxweb/en/StatFin/StatFin__vrm__muutl/statfin_muutl_pxt_11a7.px/table/tableViewLayout1/

im_csv <- read_csv(
  "data/emigration_immigration/008_11a7_2020_20220526-211620.csv"
)

em_csv <- read_csv(
  "data/emigration_immigration/008_11a7_2020_20220526-211652.csv"
)

# https://pxnet2.stat.fi/PXWeb/pxweb/en/StatFin/StatFin__vrm__vaerak/statfin_vaerak_pxt_11rc.px/table/tableViewLayout1/

pop_csv <- read_csv(
  "/Users/David/Documents/git/covid_psyserv/data/emigration_immigration/001_11rc_2021_20220526-210404.csv"
)


# Data management ---------------------------------------------------------

im_csv %>% 
  select(-Area) %>% 
  pivot_longer(
    2:5
  ) %>% 
  rename(n = value) %>% 
  group_by(Year) %>% 
  summarise(tot_im = sum(n)) %>% 
  left_join(
    em_csv %>% 
      select(-Area) %>% 
      pivot_longer(
        2:5
      ) %>% 
      rename(n = value) %>% 
      group_by(Year) %>% 
      summarise(tot_em = sum(n))
  ) %>% 
  left_join(
    pop_csv %>% 
      pivot_longer(
        2:5
      ) %>% 
      rename(pop = value) %>% 
      group_by(Year) %>% 
      summarise(tot_pop = sum(pop))
  ) %>% 
  mutate(
    perc_im = tot_im / tot_pop * 100,
    perc_em = tot_em / tot_pop * 100
  )




