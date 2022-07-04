
source("code//00_pkgs_utils.R")

# ts_m_combined
# list.files("results/", "_combined")

# Neg bin
ts_m_combined <- read_rds("results/ts_m_negbin_combined.rds")


# Fig2 --------------------------------------------------------------------

# Stratified

# ts_m_combined %>% count(ts)
# ts_m_combined %>% count(lab_outcome, order_outcome) %>% arrange(order_outcome)

df_plot_long <- 
  ts_m_combined %>% 
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

# df_plot_long %>% 
#   select(
#     ts, 
#     yearmonday, 
#     value, 
#     name, 
#     negbin_pred_rate_lo,
#     negbin_pred_rate_hi
#   ) %>% 
#   tail()

df_plot_long <- 
  df_plot_long %>% 
  mutate(
    Rate = case_when(
      name == "rate1000" ~ "Observed",
      name == "negbin_pred_rate" ~ "Predicted with 95% CI"
    )
  )



plot2ab <-
  df_plot_long %>%
  filter(ts == "02_sex", yearmonday >= "2020-03-01", yearmonday <= "2021-10-01") %>% 
  ggplot(aes(x = yearmonday, 
             y = value, 
             # color = Rate
             )) +
  
  scale_y_continuous(limits = c(0, 2.7)) + # If same y-axis scale for all panels
  
  geom_rect(
    xmin = "2020-03-15" %>% as.Date, 
    xmax = "2020-05-15" %>% as.Date,
    ymin  = -Inf,
    ymax = Inf,
    fill = "grey90"
  ) +
  
  facet_wrap(
    ~ sex_order, 
    labeller = as_labeller(c('1' = "Males", '2' = "Females")),
    ncol = 2
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
      , 
    # labels = 
    #   c(
    #   "Predicted rate with 95% CI",
    #   "Observed rate"
    # )
  ) +
  labs(
    # y = "Incidence service use\nrate per 1000", 
    y = "Diagnosis rate per 1,000", 
    x = "Year and month",
    color = NULL
  ) +
  theme_minimal(base_size = 15) +
  theme(legend.position = "none")

# plot2ab

plot2cd <-
  df_plot_long %>%
  filter(ts == "03_age", yearmonday >= "2020-03-01", yearmonday <= "2021-10-01") %>% 
  ggplot(aes(x = yearmonday, y = value)) +
  
  scale_y_continuous(limits = c(0, 2.7)) + # If same y-axis scale for all panels
  
  geom_rect(
    xmin = "2020-03-15" %>% as.Date, 
    xmax = "2020-05-15" %>% as.Date,
    ymin  = -Inf,
    ymax = Inf,
    fill = "grey90"
  ) +
  
  facet_wrap(
    ~ lab_age, 
    ncol = 2
  ) +
  
  geom_ribbon(aes(ymin = negbin_pred_rate_lo, ymax = negbin_pred_rate_hi), color = "grey50", fill = "grey50") +
  geom_line(aes(linetype = Rate)) +
  scale_linetype_manual(values = c(1, 2)) +
  scale_color_manual(
    values = c(
      "grey50", 
      "black" 
    ), 
    # labels = 
    #   c(
    #   "Predicted rate with 95% CI",
    #   "Observed rate"
    # )
  ) +
  labs(
    # y = "Incidence service use\nrate per 1000", 
    y = "Diagnosis rate per 1,000", 
    x = "Year and month",
    color = NULL
  ) +
  theme_minimal(base_size = 15) +
  theme(legend.position = "none")

# plot2cd

plot2ef <-
  df_plot_long %>%
  filter(ts == "04_area", yearmonday >= "2020-03-01", yearmonday <= "2021-10-01") %>% 
  ggplot(aes(x = yearmonday, y = value)) +
  
  scale_y_continuous(limits = c(0, 2.7)) + # If same y-axis scale for all panels
  
  geom_rect(
    xmin = "2020-03-15" %>% as.Date, 
    xmax = "2020-05-15" %>% as.Date,
    ymin  = -Inf,
    ymax = Inf,
    fill = "grey90"
  ) +
  
  facet_wrap(
    ~ lab_area, 
    ncol = 2
  ) +
  
  geom_ribbon(aes(ymin = negbin_pred_rate_lo, ymax = negbin_pred_rate_hi), color = "grey50", fill = "grey50") +
  geom_line(aes(linetype = Rate)) +
  scale_linetype_manual(values = c(1, 2)) +
  scale_color_manual(
    values = c(
      "grey50", 
      "black" 
    ), 
    # labels = c(
    #   "Predicted rate with 95% CI", 
    #   "Observed rate"
    # )
  ) +
  labs(
    # y = "Incidence service use\nrate per 1000", 
    y = "Diagnosis rate per 1,000", 
    x = "Year and month",
    color = NULL
  ) +
  theme_minimal(base_size = 15) +
  # theme(legend.position = "none")
  theme(legend.position="bottom")

# plot2ef

fig2 <- cowplot::plot_grid(
  plot2ab, 
  plot2cd, 
  plot2ef, 
  ncol = 1,
  labels = "AUTO"
)

fig2

ggsave(
  paste0(
    "results/",
    "Fig2",
    # "_same_y-scale",
    ".eps"
  ),
  units = "cm",
  dpi = 600,
  h = as.integer(22.23),
  w = as.integer(22.23/1.6),
  s = 1.2)

# sc <- 1.35
# tiff(
#   "results/Fig2.tiff",
#   units = "px",
#   width = as.integer(2625/1.6/sc),
#   height = as.integer(2625/sc),
#   res = 350/(sc+0.5))
# fig2
# dev.off()

# fig2
# 
# ggsave(
#   paste0(
#     "results/",
#     "Fig2",
#     # "_",
#     # f_timestamp(),
#     ".pdf"
#   ),
#   # units = "cm",
#   # dpi = 600,
#   # h = as.integer(22.23),
#   # w = as.integer(22.23/1.6),
#   # s = 1.2
#   h = 6*1.6, w = 6, s = 1.5
#   )
# ggsave(
#   paste0(
#     "results/",
#     "Fig2",
#     # "_",
#     # f_timestamp(),
#     ".png"
#   ),
#   h = 6*1.6, w = 6, s = 1.5)


# Secondary outcomes ------------------------------------------------------

plot3 <-
  df_plot_long %>%
  filter(ts == "05_out", yearmonday >= "2020-03-01", yearmonday <= "2021-10-01") %>% 
  ggplot(aes(x = yearmonday, y = value)) +
  
  # scale_y_continuous(limits = c(0, 1.0)) + # If same y-axis scale for all panels
  
  geom_rect(
    xmin = "2020-03-15" %>% as.Date, 
    xmax = "2020-05-15" %>% as.Date,
    ymin  = -Inf,
    ymax = Inf,
    fill = "grey90"
  ) +
  
  facet_wrap(
    ~ order_outcome, 
    labeller = as_labeller(c(
      '2' = "Substance use disorders", 
      '3' = "Psychotic and bipolar disorders", 
      '4' = "Depression and anxiety disorders", 
      '5' = "Eating disorders", 
      '6' = "Neurodevelopmental disorders", 
      '7' = "Conduct and oppositional disorders", 
      '8' = "Self-harm"
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
    , 
    # labels = 
    #   c(
    #     "Predicted rate with 95% CI",
    #     "Observed rate"
    #   )
  ) +
  labs(
    # y = "Incidence service use\nrate per 1000", 
    y = "Diagnosis rate per 1,000", 
    x = "Year and month",
    color = NULL
  ) +
  theme_minimal(base_size = 15) +
  theme(
  legend.position = c(0.85, 0.025),
  # legend.position = c(0.95, 0.01),
  legend.justification = c(1, 0))
# theme(legend.position = "none")

plot3

ggsave(
  paste0(
    "results/",
    "Fig3",
    # "_same_y-scale",
    ".eps"
  ),
  units = "cm",
  dpi = 600,
  h = as.integer(22.23),
  w = as.integer(22.23/1.6),
  s = 1.3)

# sc <- 1.35
# tiff(
#   "results/Fig3.tiff",
#   units = "px",
#   width = as.integer(2625/1.6/sc),
#   height = as.integer(2625/sc),
#   res = 350/(sc+0.5))
# plot3
# dev.off()


# plot3

# ggsave(
#   paste0(
#     "results/",
#     "Fig3",
#     # "_",
#     # f_timestamp(),
#     ".pdf"
#   ),
#   h = 6*1.6, w = 6, s = 1.5)
# ggsave(
#   paste0(
#     "results/",
#     "Fig3",
#     # "_",
#     # f_timestamp(),
#     ".png"
#   ),
#   h = 6*1.6, w = 6, s = 1.5)
