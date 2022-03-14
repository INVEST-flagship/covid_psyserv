# Model needed time series and save all results into one file

# Load previous scripts ---------------------------------------------------

source("code//00_pkgs_utils.R")
source("code//02_model_functions.R")

# Model all time series ---------------------------------------------------

# ls()

list.files("data/", "ts_")

ts_m <- read_rds("data/ts_aggregated.rds")

# Check Ns
ts_m %>% 
  filter(yearmonday >= "2020-03-01") %>% 
  group_by(lab_outcome, yearmonday >= "2020-06-01") %>% 
  summarise(sum(n))

ts_m %>% count(ts, lab_ts)

ts_m_main1 <- ts_pred_month(ts_m %>% filter(ts == "01_any"))

ts_m_sex1 <- ts_pred_month(ts_m %>% filter(ts == "02_sex", lab_sex == "Males")) # alternation limit reached
ts_m_sex2 <- ts_pred_month(ts_m %>% filter(ts == "02_sex", lab_sex == "Females"))

ts_m_age1 <- ts_pred_month(ts_m %>% filter(ts == "03_age", lab_age == "0 - 12 years"))
ts_m_age2 <- ts_pred_month(ts_m %>% filter(ts == "03_age", lab_age == "13 - 17 years"))

ts_m_area1 <- ts_pred_month(ts_m %>% filter(ts == "04_area", lab_area == "Helsinki University Hospital area"))
ts_m_area2 <- ts_pred_month(ts_m %>% filter(ts == "04_area", lab_area == "Rest of Finland"))

ts_m_out1 <- ts_pred_month(ts_m %>% filter(ts == "05_out", lab_outcome == "Substance use disorders"))
ts_m_out2 <- ts_pred_month(ts_m %>% filter(ts == "05_out", lab_outcome == "Psychotic and bipolar disorders"))
ts_m_out3 <- ts_pred_month(ts_m %>% filter(ts == "05_out", lab_outcome == "Depression and anxiety disorders"))
ts_m_out4 <- ts_pred_month(ts_m %>% filter(ts == "05_out", lab_outcome == "Eating disorders"))
ts_m_out5 <- ts_pred_month(ts_m %>% filter(ts == "05_out", lab_outcome == "Neurodevelopmental disorders"))
ts_m_out6 <- ts_pred_month(ts_m %>% filter(ts == "05_out", lab_outcome == "Conduct and oppositional disorders")) # iteration limit reached
ts_m_out7 <- ts_pred_month(ts_m %>% filter(ts == "05_out", lab_outcome == "Self-harm"))

# Check Ns
ts_m_out5 %>% 
  filter(yearmonday >= "2020-03-01") %>% 
  group_by(lab_outcome, yearmonday >= "2020-06-01") %>% 
  summarise(sum(n))

# Combine results ---------------------------------------------------------

ts_m_combined <- 
  bind_rows(
    ts_m_main1,
    ts_m_sex1 ,
    ts_m_sex2 ,
    ts_m_age1 ,
    ts_m_age2 ,
    ts_m_area1,
    ts_m_area2,
    ts_m_out1 ,
    ts_m_out2 ,
    ts_m_out3 ,
    ts_m_out4 ,
    ts_m_out5 ,
    ts_m_out6 ,
    ts_m_out7 
  ) %>% 
  select(
    ts, lab_ts, order_outcome, contains("lab_"), everything()
  ) %>% 
  arrange(ts, order_outcome)

# Check Ns
ts_m_combined %>% 
  filter(yearmonday >= "2020-03-01") %>% 
  group_by(lab_outcome, yearmonday >= "2020-06-01") %>% 
  summarise(sum(n))

# Write results -----------------------------------------------------------

write.xlsx(
  ts_m_combined, 
  paste0(
    "results/",
    "ts_m_negbin_combined",
    # "_", 
    # f_timestamp(), 
    ".xlsx"
  ))

write_rds(
  ts_m_combined, 
  paste0(
    "results/",
    "ts_m_negbin_combined",
    # "_", 
    # f_timestamp(), 
    ".rds"
  ))


# Run with Poisson distribution instead of neg bin ------------------------

ts_pred_month_poi(ts_m %>% filter(ts == "02_sex", lab_sex == "Males"))
ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Conduct and oppositional disorders")) 
# -> no problems with alteration limit or iteration

ts_m_main1 <- ts_pred_month_poi(ts_m %>% filter(ts == "01_any"))

ts_m_sex1 <- ts_pred_month_poi(ts_m %>% filter(ts == "02_sex", lab_sex == "Males")) 
ts_m_sex2 <- ts_pred_month_poi(ts_m %>% filter(ts == "02_sex", lab_sex == "Females"))

ts_m_age1 <- ts_pred_month_poi(ts_m %>% filter(ts == "03_age", lab_age == "0 - 12 years"))
ts_m_age2 <- ts_pred_month_poi(ts_m %>% filter(ts == "03_age", lab_age == "13 - 17 years"))

ts_m_area1 <- ts_pred_month_poi(ts_m %>% filter(ts == "04_area", lab_area == "Helsinki University Hospital area"))
ts_m_area2 <- ts_pred_month_poi(ts_m %>% filter(ts == "04_area", lab_area == "Rest of Finland"))

ts_m_out1 <- ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Substance use disorders"))
ts_m_out2 <- ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Psychotic and bipolar disorders"))
ts_m_out3 <- ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Depression and anxiety disorders"))
ts_m_out4 <- ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Eating disorders"))
ts_m_out5 <- ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Neurodevelopmental disorders"))
ts_m_out6 <- ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Conduct and oppositional disorders"))  
ts_m_out7 <- ts_pred_month_poi(ts_m %>% filter(ts == "05_out", lab_outcome == "Self-harm"))

ts_m_combined <- 
  bind_rows(
    ts_m_main1,
    ts_m_sex1 ,
    ts_m_sex2 ,
    ts_m_age1 ,
    ts_m_age2 ,
    ts_m_area1,
    ts_m_area2,
    ts_m_out1 ,
    ts_m_out2 ,
    ts_m_out3 ,
    ts_m_out4 ,
    ts_m_out5 ,
    ts_m_out6 ,
    ts_m_out7 
  ) %>% 
  select(
    ts, lab_ts, order_outcome, contains("lab_"), everything()
  ) %>% 
  arrange(ts, order_outcome)

write.xlsx(
  ts_m_combined, 
  paste0(
    "results/",
    "ts_m_poisson_combined",
    # "_",
    # f_timestamp(), 
    ".xlsx"
  ))

write_rds(
  ts_m_combined, 
  paste0(
    "results/",
    "ts_m_poisson_combined",
    # "_", 
    # f_timestamp(), 
    ".rds"
  ))
