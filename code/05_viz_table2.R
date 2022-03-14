
# Edit results to table ---------------------------------------------------

source("code//00_pkgs_utils.R")

ts_m_combined
list.files("results/", "_combined")

# Neg bin
ts_m_combined <- read_rds("results/ts_m_negbin_combined.rds")

ts_m_combined %>% names

ts_m_combined %>% 
  filter(YEAR == 2021) %>% 
  select(
  n, 
  # contains("n_"), # integer values, not rounded
  contains("negbin_") # decimal values of count predictions
) 

t2 <- 
  ts_m_combined %>% 
  mutate(
    school_lock = case_when(
      yearmonday >= "2020-03-01" & yearmonday <= "2020-05-30" ~ "01_school_lock", 
      yearmonday >= "2020-06-01" ~ "02_post_school_lock", 
      T ~ NA_character_
    )
  ) %>% 
  group_by(
    school_lock,
    ts, 
    lab_ts,
    lab_sex, lab_age, lab_area, order_outcome, lab_outcome
  ) %>% 
  summarise(
    expected = sum(negbin_pred),
    expected_lo = sum(negbin_pred_lo),
    expected_hi = sum(negbin_pred_hi),
    observed = sum(n) 
  ) %>% 
  arrange(ts, school_lock, desc(lab_sex), order_outcome) %>% 
  filter(!is.na(school_lock)) %>%
  mutate(
    expected_ci = 
      paste0(
        expected %>% round(0), 
        " (", 
        expected_lo %>% round(0), 
        " \u2013 ", 
        expected_hi %>% round(0), 
        ")"
      ),
    diff_abs = 
      paste0(
        observed - expected %>% round(0), 
        " (", 
        observed - expected_hi %>% round(0), 
        " \u2013 ", 
        observed - expected_lo %>% round(0), 
        ")"
      ), 
    diff_rel_perc = 
      paste0(
        (((observed / expected) - 1)*100) %>% round(1),
        " (", 
        (((observed / expected_hi) - 1)*100) %>% round(1),
        " \u2013 ", 
        (((observed / expected_lo) - 1)*100) %>% round(1),
        ")"
      )
  ) %>%
  ungroup() %>% 
  select(
    -expected, 
    -expected_lo, 
    -expected_hi, 
    -order_outcome
  ) %>% 
  pivot_wider(
    names_from = school_lock, 
    values_from = c(
      observed,
      expected_ci,
      diff_abs,
      diff_rel_perc
    )
  ) %>% 
  select(
    contains("lab_"), 
    contains("01_school_"), 
    contains("02_post_")
  )

# Write results -----------------------------------------------------------

write.xlsx(
  t2, 
  paste0(
    "results/",
    "t2",
    "_negbin",
    # "_",
    # f_timestamp(),
    ".xlsx"
  ))


# Poisson distribution ----------------------------------------------------

# Poisson
ts_m_combined <- read_rds("results/ts_m_poisson_combined.rds")

ts_m_combined %>% 
  filter(YEAR == 2021) %>% 
  select(
    n, 
    # contains("n_"), # integer values, not rounded
    contains("poi_") # decimal values of count predictions
  ) 

t_suppl <- 
  ts_m_combined %>% 
  mutate(
    school_lock = case_when(
      yearmonday >= "2020-03-01" & yearmonday <= "2020-05-30" ~ "01_school_lock", 
      yearmonday >= "2020-06-01" ~ "02_post_school_lock", 
      T ~ NA_character_
    )
  ) %>% 
  group_by(
    school_lock,
    ts, 
    lab_ts,
    lab_sex, lab_age, lab_area, order_outcome, lab_outcome
  ) %>% 
  summarise(
    expected = sum(poi_pred),
    expected_lo = sum(poi_pred_lo),
    expected_hi = sum(poi_pred_hi),
    observed = sum(n) 
  ) %>% 
  arrange(ts, school_lock, desc(lab_sex), order_outcome) %>% 
  filter(!is.na(school_lock)) %>%
  mutate(
    expected_ci = 
      paste0(
        expected %>% round(0), 
        " (", 
        expected_lo %>% round(0), 
        " \u2013 ", 
        expected_hi %>% round(0), 
        ")"
      ),
    diff_abs = 
      paste0(
        observed - expected %>% round(0), 
        " (", 
        observed - expected_hi %>% round(0), 
        " \u2013 ", 
        observed - expected_lo %>% round(0), 
        ")"
      ), 
    diff_rel_perc = 
      paste0(
        (((observed / expected) - 1)*100) %>% round(1),
        " (", 
        (((observed / expected_hi) - 1)*100) %>% round(1),
        " \u2013 ", 
        (((observed / expected_lo) - 1)*100) %>% round(1),
        ")"
      )
  ) %>%
  ungroup() %>% 
  select(
    -expected, 
    -expected_lo, 
    -expected_hi, 
    -order_outcome
  ) %>% 
  pivot_wider(
    names_from = school_lock, 
    values_from = c(
      observed,
      expected_ci,
      diff_abs,
      diff_rel_perc
    )
  ) %>% 
  select(
    contains("lab_"), 
    contains("01_school_"), 
    contains("02_post_")
  )

write.xlsx(
  t_suppl, 
  paste0(
    "results/",
    "t_suppl_poisson",
    # "_",
    # f_timestamp(),
    ".xlsx"
  ))

