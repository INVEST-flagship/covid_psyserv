
source("code//00_pkgs_utils.R")

# ts_m_combined
# list.files("results/", "_combined")

# Neg bin
ts_m_combined <- read_rds("results/ts_m_negbin_combined.rds")


# Fig1 A (whole serie) ----------------------------------------------------

# Data frame for plotting

# ts_m_combined %>% count(ts)

plot1a <-
  ts_m_combined %>%
  filter(
    ts == "01_any",
    yearmonday <= "2021-10-01"
  ) %>%
  ggplot(aes(x = yearmonday, y = rate1000)) +
  geom_line() +
  
  labs(
    y = "Incidence service use rate per 1000", 
    x = "Year and month"
  ) +
  theme_minimal(base_size = 15) 
 
# plot1a

# ggsave(
#   paste0(
#     "results/",
#     "INITIAL_obs_vs_pred_wide_",
#     f_timestamp(),
#     ".pdf"
#   ),
#   h = 6, w = 6*1.6, s = 0.8)


# Fig1 (obs vs pred after lockdown) -------------------------------------

# Separate observed rates for pre and post-COVID

df_plot_long <- 
  ts_m_combined %>% 
  pivot_longer(
    cols = c(
      rate1000,
      negbin_pred_rate, 
    )
  )

# df_plot_long %>%
#   filter(ts == "01_any", yearmonday >= "2020-03-01", yearmonday <= "2021-10-01") %>% 
#   select(yearmonday, value, name)

plot1b <-
  df_plot_long %>%
  filter(ts == "01_any", yearmonday >= "2020-03-01", yearmonday <= "2021-10-01") %>%
  ggplot(aes(x = yearmonday, y = value, color = name)) +
  geom_ribbon(aes(ymin = negbin_pred_rate_lo, ymax = negbin_pred_rate_hi), color = "grey70", fill = "grey70") +
  geom_line() +
  scale_y_continuous(limits = c(0, 2.2)) +
  scale_color_manual(
    values = c(
      "grey50", 
      "black" 
    ), 
    labels = c(
      "Predicted rate with 95% CI", 
      "Observed rate"
    )
  ) +
  
  annotate("text",
           x = "2020-03-15" %>% as.Date + 5, 
           y = 2,
           hjust = 0,
           label = "March\n2020") +
  
  geom_vline(xintercept = "2020-03-15" %>% as.Date, linetype = "dashed") +
  
  annotate("text",
           x = "2021-09-15" %>% as.Date - 5, 
           y = 2,
           hjust = 1,
           label = "September\n2021") +
  
  geom_vline(xintercept = "2021-09-15" %>% as.Date, linetype = "dashed") +
  
  labs(
    # title = "Observed versus Predicted incidence rates",
    # subtitle = "Any diagnosis in specialized services",
    # y = "Incidence service use\nrate per 1000", 
    y = "Diagnosis rate for 1,000", 
    x = "Year",
    # x = "Year and month",
    color = NULL
  ) +
  theme_minimal(base_size = 15) +
  theme(legend.position="bottom")

# plot1b

# ggsave(
#   paste0(
#     "results/",
#     "INITIAL_obs_vs_pred_wide_",
#     f_timestamp(),
#     ".pdf"
#   ),
#   h = 6, w = 6*1.6, s = 0.8)

# plot1b %+%
#   list(data = df_plot_long %>% 
#          filter(ts == "01_any", yearmonday >= "2017-01-01", yearmonday <= "2021-10-01"))

# ggsave(
#   paste0(
#     "results/",
#     "INITIAL_obs_vs_pred_lm_zoom_",
#     f_timestamp(),
#     ".pdf"
#   ),
#   h = 6, w = 6*1.6, s = 0.8)

# Fig1 (rel change per month as bar chart) ------------------------------

# ts_m_combined %>% 
#   mutate(
#     diff_rate_rel_perc_lo = (1 - (negbin_pred_rate_hi / rate1000)) * 100,
#     diff_rate_rel_perc_hi = (1 - (negbin_pred_rate_lo / rate1000)) * 100,
#   )

boxes <- 
  read.xlsx(
    "data/Milestones_COVID-19.xlsx", 
    sheet = "boxes", detectDates = T) %>% as_tibble()

plot1c <- 
  ts_m_combined %>%
  mutate(
    diff_rate_rel_perc_lo = (1 - (negbin_pred_rate_hi / rate1000)) * 100,
    diff_rate_rel_perc_hi = (1 - (negbin_pred_rate_lo / rate1000)) * 100,
  ) %>% 
  filter(
    ts == "01_any",
    yearmonday >= "2020-03-01",
    yearmonday <= "2021-10-01"
  ) %>% 

    ggplot(
    aes(
      x = yearmonday, 
      y = diff_rate_rel_perc 
    )
  ) + 

  scale_y_continuous(limits = c(-40, 40)) +
  
  geom_bar(stat = "identity", color = "grey50", fill = "grey50") + 
  
  geom_errorbar(
    aes(
      ymin = diff_rate_rel_perc_lo, 
      ymax = diff_rate_rel_perc_hi
    ), 
    width=7,
    position=position_dodge(.9)
  ) +

  
  annotate("segment",
           x = boxes %>% filter(box_nr == 1) %>% select(xmin) %>% pull %>% as.Date,
           xend = boxes %>% filter(box_nr == 1) %>% select(xmax) %>% pull %>% as.Date, 
           y = boxes %>% filter(box_nr == 1) %>% select(ymax) %>% pull, 
           yend = boxes %>% filter(box_nr == 1) %>% select(ymax) %>% pull,
           arrow=arrow(ends = "both", angle = 90, length = unit(.15,"cm"))) +
  
  annotate("text",
           x = "2020-04-01" %>% as.Date, 
           y = boxes %>% filter(box_nr == 1) %>% select(ymin) %>% pull + 2.5,
           hjust = 0,
           label = boxes %>% filter(box_nr == 1) %>% select(label) %>% pull) +
  
  annotate("segment",
           x = boxes %>% filter(box_nr == 2) %>% select(xmin) %>% pull %>% as.Date,
           xend = boxes %>% filter(box_nr == 2) %>% select(xmax) %>% pull %>% as.Date, 
           y = boxes %>% filter(box_nr == 2) %>% select(ymax) %>% pull, 
           yend = boxes %>% filter(box_nr == 2) %>% select(ymax) %>% pull,
           arrow=arrow(ends = "both", angle = 90, length = unit(.15,"cm"))) +
  
  annotate("text",
           x = "2020-04-01" %>% as.Date, 
           y = boxes %>% filter(box_nr == 2) %>% select(ymin) %>% pull + 2.5,
           hjust = 0,
           label = boxes %>% filter(box_nr == 2) %>% select(label) %>% pull) +
  
  annotate("segment",
           x = boxes %>% filter(box_nr == 3) %>% select(xmin) %>% pull %>% as.Date,
           xend = boxes %>% filter(box_nr == 3) %>% select(xmax) %>% pull %>% as.Date, 
           y = boxes %>% filter(box_nr == 3) %>% select(ymax) %>% pull, 
           yend = boxes %>% filter(box_nr == 3) %>% select(ymax) %>% pull,
           arrow=arrow(ends = "both", angle = 90, length = unit(.15,"cm"))) +
  
  annotate("text",
           x = "2020-04-01" %>% as.Date, 
           y = boxes %>% filter(box_nr == 3) %>% select(ymin) %>% pull + 2.5,
           hjust = 0,
           label = boxes %>% filter(box_nr == 3) %>% select(label) %>% pull) +
  
 
  
  labs(
    # title = "Difference between observed versus predicted rates",
    # subtitle = "Any diagnosis in specialized services",
    y = "Relative difference between\nobseved and predicted rates (%)", 
    x = "Year and month", 
    fill = "Significant difference"
  ) +
  theme_minimal(base_size = 15) +
  theme(legend.position="bottom")


# plot1c

# ggsave(
#   paste0(
#     "results/",
#     "INITIAL_obs_vs_pred_diff_",
#     f_timestamp(),
#     ".pdf"
#   ),
#   h = 6, w = 6*1.6, s = 0.8)

fig1 <- 
  cowplot::plot_grid(
  plot1b %+%
    list(data = df_plot_long %>% 
           filter(ts == "01_any", yearmonday >= "2017-01-01", yearmonday <= "2022-01-01")), 
  plot1c, 
  ncol = 1,
  rel_heights = c(0.4, 0.6),
  labels = "AUTO"
) 


# fig1
# 
# ggsave(
#   paste0(
#     "results/",
#     "Fig1",
#     ".eps"
#   ),
#   units = "cm",
#   dpi = 600,
#   h = as.integer(22.23), 
#   w = as.integer(22.23/1.6), 
#   s = 1.2)

# sc <- 1
# ggsave(
#   paste0(
#     "results/",
#     "Fig1",
#     ".tiff"
#   ),
#   units = "cm",
#   dpi = 300,
#   h = as.integer(22.23*sc), 
#   w = as.integer(22.23/1.6*sc), 
#   s = 1.2*sc)
# ggsave(
#   paste0(
#     "results/",
#     "Fig1",
#     ".tiff"
#   ),
#   h = 6*1.6, w = 6, s = 1.2)
# ggsave(
#   paste0(
#     "results/",
#     "fig1_ab",
#     # "_",
#     # f_timestamp(),
#     ".pdf"
#   ),
#   h = 6*1.6, w = 6, s = 1.2)
# ggsave(
#   paste0(
#     "results/",
#     "fig1_ab",
#     # "_",
#     # f_timestamp(),
#     ".png"
#   ),
#   h = 6*1.6, w = 6, s = 1.2)

# sc <- 1.2
# point_sc = 0.1
# tiff(
#   "results/Fig1.tiff",
#   units = "px",
#   width = as.integer(2625/1.6*sc),
#   height = as.integer(2625*sc),
#   # units = "cm",
#   # width = as.integer(22.23/1.6*sc),
#   # height = as.integer(22.23*sc),
#   res = 300
#   )
# fig1
# dev.off()

# Table of relative difference by month -----------------------------------


write.xlsx(
  
  ts_m_combined %>%
    mutate(
      diff_rate_rel_perc_lo = (1 - (negbin_pred_rate_hi / rate1000)) * 100,
      diff_rate_rel_perc_hi = (1 - (negbin_pred_rate_lo / rate1000)) * 100,
    ) %>% 
    filter(
      ts == "01_any",
      yearmonday >= "2020-03-01",
      yearmonday <= "2021-10-01"
    ) %>% 
    select(
      YEAR, MONTH, 
      diff_rate_rel_perc,
      diff_rate_rel_perc_lo, 
      diff_rate_rel_perc_hi
    )
  , 
  paste0(
    "results/",
    "table_fig1b_numbers",
    # "_",
    # f_timestamp(),
    ".xlsx"
  ))
