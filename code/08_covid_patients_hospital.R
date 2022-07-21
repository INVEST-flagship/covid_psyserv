# Source:
#   
# Population at risk
# 
# https://sampo.thl.fi/pivot/prod/en/epirapo/covid19care/fact_epirapo_covid19care?&row=erva-456367&column=measure-547523.547516.456732.445344.
# 
# Helsinki University Hospital area: 2213707
# Finland: 5559655
# Rest of Finland: 3345948
# 
# COVID patients treated in hospitals
# 
# Finland:
#   https://sampo.thl.fi/pivot/prod/en/epirapo/covid19care/fact_epirapo_covid19care?&row=dateweek20200101-509093L&column=measure-547523.547516.547531.456732.&fo
# 
# Helsinki University Hospital area:
#   https://sampo.thl.fi/pivot/prod/en/epirapo/covid19care/fact_epirapo_covid19care?&row=dateweek20200101-509093L&column=measure-547523.547516.547531.456732.&filter=erva-456369&fo


source("code//00_pkgs_utils.R")

list.files("data/", "covid")

cfin <- read_csv2("data/covid_patients_in_hospitals_finland.csv")
chuh <- read_csv2("data/covid_patients_in_hospitals_helsinki_uni_area.csv")

# cfin %>% count(Measure)
# chuh %>% count(Measure)

# cfin %>% summary()
# chuh %>% summary()

# cfin %>% View()
# chuh %>% View()

df <- 
  bind_rows(
    cfin %>% mutate(area = "fin"), 
    chuh %>% mutate(area = "huh")
  ) %>% 
  filter(Measure %in% 
           c(
             "Ongoing treatment periods at inpatient wards (until 7 Dec 2020)", 
             "Ongoing treatment periods at specialised medical care wards"
           )
  ) %>% 
  select(-Measure) %>% 
  filter(!is.na(val)) %>%
  mutate(
    pop = case_when(
      area == "fin" ~ 5559655, 
      area == "huh" ~ 2213707
    )
  ) %>% 
  pivot_wider(id_cols = Time, names_from = area, values_from = c(val, pop)) %>% 
  mutate(
    val_rest = val_fin - val_huh, 
    pop_rest = pop_fin - pop_huh, 
    rate1000_huh = val_huh / pop_huh * 1000,
    rate1000_rest = val_rest / pop_rest * 1000
  ) %>% 
  select(Time, rate1000_huh, rate1000_rest) %>% 
  pivot_longer(-Time)

# df %>% 
#   filter(Time < "2021-10-01") %>% 
#   summary()

# df %>%filter(Time < "2021-10-01") %>% View()

plot_s <- 
  df %>% 
  filter(Time < "2021-10-01") %>%
  ggplot(aes(x = Time, y = value, color = name)) +
  geom_line() +
  # scale_x_date(date_breaks = "6 month") +
  scale_color_manual(
    values = c(
      "red", 
      "blue" 
    ), 
    labels = c(
      "Helsinki Univeristy Hospital area", 
      "Rest of Finland"
    )
  ) +
  
  labs(
    title = "S1 Figure \nWeekly rate of COVID-19 patients treated in hospitals",
    # subtitle = "Source: Finnish Institute for Health and Welfare",
    caption = "Data source: Finnish Institute for Health and Welfare",    
    # caption = "Data source: Finnish Institute for Health and Welfare\nData management: https://github.com/davgyl/covid_psyserv/blob/main/code/08_covid_patients_hospital.R",
    y = "Hospital rate per 1,000", 
    x = "Year and month",
    color = NULL
  ) +
  theme_minimal(base_size = 15) +
  theme(legend.position="bottom")

plot_s

# ggsave(
#   paste0(
#     "results/",
#     "S1_Fig",
#     # "_",
#     # f_timestamp(),
#     ".pdf"
#   ),
#   h = 5, w = 5*1.6, s = 1.2)
