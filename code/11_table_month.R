
# Edit results to table ---------------------------------------------------

# Similar to Table 2, but by month

source("code//00_pkgs_utils.R")

ts_m_combined
list.files("results/", "_combined")

# Neg bin
ts_m_combined <- read_rds("results/ts_m_negbin_combined.rds")

ts_m_combined %>% names

ts_m_combined %>% 
  filter(YEAR == 2021) %>% 
  select(
    yearmonday,
    ts, 
    n, 
    contains("negbin_") # decimal values of count predictions
  ) 

t_m <- 
  ts_m_combined %>% 
  arrange(ts, yearmonday, desc(lab_sex), order_outcome) %>% 
  filter(!is.na(negbin_pred)) %>%
  mutate(
    expected_ci = 
      paste0(
        negbin_pred %>% round(0), 
        " (", 
        negbin_pred_lo %>% round(0), 
        " \u2013 ", 
        negbin_pred_hi %>% round(0), 
        ")"
      ),
    diff_abs = 
      paste0(
        n - negbin_pred %>% round(0), 
        " (", 
        n - negbin_pred_hi %>% round(0), 
        " \u2013 ", 
        n - negbin_pred_lo %>% round(0), 
        ")"
      ), 
    diff_rel_perc = 
      paste0(
        (((n / negbin_pred) - 1)*100) %>% round(1),
        " (", 
        (((n / negbin_pred_hi) - 1)*100) %>% round(1),
        " \u2013 ", 
        (((n / negbin_pred_lo) - 1)*100) %>% round(1),
        ")"
      )
  ) %>%
  mutate(
    Year = year(yearmonday), 
    Month = month(yearmonday)
  ) %>% 
  select(
    Year, Month,
    n, 
    ts, 
    contains("lab_"),
    expected_ci, 
    diff_abs, 
    diff_rel_perc
  ) %>% 
  rename(
    Observed = n, 
    `Predicted No. (95% CI)` = expected_ci,
    `Absolute difference No. (95% CI)` = diff_abs,
    `Relative difference % (95% CI)` = diff_rel_perc
  )


t_m %>% 
  filter(ts == "01_any") %>% 
  select(-ts, 
         -contains("lab")
  ) 



# Write results -----------------------------------------------------------

# write.xlsx(
#   t_m, 
#   paste0(
#     "results/",
#     "t_month",
#     "_negbin",
#     # "_",
#     # f_timestamp(),
#     ".xlsx"
#   ))
