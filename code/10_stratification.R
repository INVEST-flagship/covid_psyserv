# Posthoc analyses for selected sex-stratified for outcomes with n>=5

# Load previous scripts ---------------------------------------------------

source("code//00_pkgs_utils.R")
source("code//02_model_functions.R")

# Load data ---------------------------------------------------------------

ts_m_out_sex <- read_rds("data/ts_aggregated_sex.rds")
# ts_m_out_sex %>% count(n<5)

# Model -------------------------------------------------------------------

ts_m_out1_m <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Males", lab_outcome == "Substance use disorders"))
ts_m_out3_m <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Males",lab_outcome == "Depression and anxiety disorders"))
ts_m_out5_m <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Males",lab_outcome == "Neurodevelopmental disorders"))
ts_m_out6_m <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Males",lab_outcome == "Conduct and oppositional disorders"))

ts_m_out1_f <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Females", lab_outcome == "Substance use disorders"))
ts_m_out3_f <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Females",lab_outcome == "Depression and anxiety disorders"))
ts_m_out5_f <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Females",lab_outcome == "Neurodevelopmental disorders"))
ts_m_out6_f <- ts_pred_month(ts_m_out_sex %>% filter(lab_sex == "Females",lab_outcome == "Conduct and oppositional disorders"))

# Combine results ---------------------------------------------------------

ts_m_combined_sex <- 
  bind_rows(
    ts_m_out1_m,
    ts_m_out3_m,
    ts_m_out5_m,
    ts_m_out6_m,
    ts_m_out1_f,
    ts_m_out3_f,
    ts_m_out5_f,
    ts_m_out6_f 
  ) %>% 
  select(
    ts, lab_ts, order_outcome, contains("lab_"), everything()
  ) %>% 
  arrange(ts, order_outcome)

write_rds(
  ts_m_combined_sex, 
  paste0(
    "results/",
    "ts_m_negbin_combined_sex",
    # "_", 
    # f_timestamp(), 
    ".rds"
  ))


# Plot --------------------------------------------------------------------

df_plot_long <- 
  ts_m_combined_sex %>% 
  pivot_longer(
    cols = c(
      rate1000,
      negbin_pred_rate, 
    )
  ) %>% 
  mutate(
    sex_order = case_when(
      lab_sex == "Males" ~ 1, 
      lab_sex == "Females" ~ 2
    )
  )

df_plot_long <- 
  df_plot_long %>% 
  mutate(
    Rate = case_when(
      name == "rate1000" ~ "Observed",
      name == "negbin_pred_rate" ~ "Predicted with 95% CI"
    )
  )

df_plot_long %>% 
  select(order_outcome, lab_outcome, lab_sex, sex_order) %>% 
  distinct()

df_plot_long <- 
  df_plot_long %>% 
  mutate(
    order_outcome_sex = case_when(
      order_outcome == 2 & sex_order == 1 ~ 1, 
      order_outcome == 2 & sex_order == 2 ~ 2, 
      order_outcome == 4 & sex_order == 1 ~ 3, 
      order_outcome == 4 & sex_order == 2 ~ 4, 
      order_outcome == 6 & sex_order == 1 ~ 5, 
      order_outcome == 6 & sex_order == 2 ~ 6, 
      order_outcome == 7 & sex_order == 1 ~ 7, 
      order_outcome == 7 & sex_order == 2 ~ 8
    )
  )

plot_sex <-
  df_plot_long %>%
  filter(yearmonday >= "2020-03-01", yearmonday <= "2021-10-01") %>% 
  ggplot(aes(x = yearmonday, y = value)) +
  
  geom_rect(
    xmin = "2020-03-15" %>% as.Date, 
    xmax = "2020-05-15" %>% as.Date,
    ymin  = -Inf,
    ymax = Inf,
    fill = "grey90"
  ) +
  
  facet_wrap(
    ~ order_outcome_sex, 
    labeller = as_labeller(c(
      '1' = "Males - Substance use disorders", 
      '3' = "Males - Depression and anxiety disorders", 
      '5' = "Males - Neurodevelopmental disorders", 
      '7' = "Males - Conduct and oppositional disorders",
      '2' = "Females - Substance use disorders", 
      '4' = "Females - Depression and anxiety disorders", 
      '6' = "Females - Neurodevelopmental disorders", 
      '8' = "Females - Conduct and oppositional disorders" 
      
    )),
    ncol = 2, 
    scales = "free_y"
  ) +
  
  geom_ribbon(aes(ymin = negbin_pred_rate_lo, ymax = negbin_pred_rate_hi), color = "grey50", fill = "grey50") +
  geom_line(aes(linetype = Rate)) +
  scale_linetype_manual(values = c(1, 2)) +
  scale_color_manual(
    values = 
      c(
        "grey50",
        "black"
      )
    
  ) +
  labs(
    title = "Supplemental Figure 2\nSex-stratifed results for selected outcomes",
    y = "Diagnosis rate per 1,000", 
    x = "Year and month",
    color = NULL
  ) +
  theme_minimal(base_size = 15) +
  theme(legend.position = "bottom")

plot_sex

# ggsave(
#   paste0(
#     "results/",
#     "fig_suppl_sex",
#     # "_",
#     # f_timestamp(),
#     ".pdf"
#   ),
#   h = 5, w = 5*1.6, s = 1.2)
