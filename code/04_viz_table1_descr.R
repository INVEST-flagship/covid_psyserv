source("code//00_pkgs_utils.R")

ts_m_combined
list.files("results/", "_combined")

# Neg bin
ts_m_combined <- read_rds("results/ts_m_negbin_combined.rds")

t1_nrisk <- 
  ts_m_combined %>% 
  select(
    ts, lab_ts, order_outcome, lab_sex, lab_age, lab_area, YEAR,
    nrisk) %>% 
  filter(ts != "05_out") %>% 
  distinct() 

t1_yearly_n <- 
  ts_m_combined %>% 
  group_by(
    ts, lab_ts, order_outcome, lab_sex, lab_age, lab_area, lab_outcome, YEAR
  ) %>% 
  summarise(
    sum(n)
  )

write.xlsx(
  t1_nrisk, 
  paste0(
    "results/",
    "t1_nrisk",
    # "_",
    # f_timestamp(),
    ".xlsx"
  ))

write.xlsx(
  t1_yearly_n, 
  paste0(
    "results/",
    "t1_yearly_n",
    # "_",
    # f_timestamp(),
    ".xlsx"
  ))
