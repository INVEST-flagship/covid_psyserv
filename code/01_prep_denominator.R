
# Load previous scripts ---------------------------------------------------

# library(tidyverse)

source("code//00_pkgs_utils.R")

Sys.setlocale(locale="UTF-8")

# Read data ---------------------------------------------------------------


cens_csv <- read_csv(
  "data/denominator/005_11re_2020_20210916-103128.csv",
  skip = 1 # skip first row
)

# Origin: 
# https://pxnet2.stat.fi/PXWeb/pxweb/en/StatFin/StatFin__vrm__vaerak/statfin_vaerak_pxt_11re.px/

# https://pxnet2.stat.fi:443/PXWeb/sq/8d93e5b0-12ac-4bc0-8665-4822a723e47b
# https://pxnet2.stat.fi:443/PXWeb/sq/30476ccf-2900-49ca-b03e-6320a46b675f

# Updated 2022-05-17:

# https://pxnet2.stat.fi:443/PXWeb/api/v1/en/StatFin/vrm/vaerak/statfin_vaerak_pxt_11re.px
# https://pxnet2.stat.fi:443/PXWeb/sq/94de3166-3b27-43fb-b17b-2c151cd534a3

cens_csv <- read_csv(
  "data/denominator/001_11re_2021_20220517-160323.csv"
)

# Tidy data ---------------------------------------------------------------

# Rename

cens_m <- 
  cens_csv %>% 
  select(1:2, starts_with("Males"))

cens_f <- 
  cens_csv %>% 
  select(1:2, starts_with("Females"))

cens_t <- 
  cens_csv %>% 
  select(1:2, starts_with("Total"))

# colnames(cens_m) <- 
#   c("Area", "Age", 2016:2020)
# 
# colnames(cens_f) <- 
#   c("Area", "Age", 2016:2020)
# 
# colnames(cens_t) <- 
#   c("Area", "Age", 2016:2020)

colnames(cens_m) <- 
  c("Area", "Age", 2016:2021)

colnames(cens_f) <- 
  c("Area", "Age", 2016:2021)

colnames(cens_t) <- 
  c("Area", "Age", 2016:2021)

# Make long data and bind rows

# cens_tidy <- 
#   bind_rows(
#     cens_m %>% 
#       pivot_longer(3:7, "year") %>% 
#       pivot_longer(3:7, "year") %>% 
#       mutate(gender = "Males"),
#     cens_f %>% 
#       pivot_longer(3:7, "year") %>% 
#       pivot_longer(3:7, "year") %>% 
#       mutate(gender = "Females"),
#     cens_t %>% 
#       pivot_longer(3:7, "year") %>% 
#       mutate(gender = "Total")
#   )

cens_tidy <- 
  bind_rows(
    cens_m %>% 
      pivot_longer(3:8, "year") %>% 
      mutate(gender = "Males"),
    cens_f %>% 
      pivot_longer(3:8, "year") %>% 
      mutate(gender = "Females"),
    cens_t %>% 
      pivot_longer(3:8, "year") %>% 
      mutate(gender = "Total")
  )
# Summarise by age group and other stratifiers

cens_sum <- 
  cens_tidy %>% 
  rename(area = Area) %>% 
  mutate(
    year = as.numeric(year), 
    age_group = case_when(
      Age <= 12 ~ "0-12", 
      Age > 12 & Age <= 17 ~ "13-17"
    )
  ) %>% 
  group_by(area, year, gender, age_group) %>% 
  summarise(n_at_risk = sum(value)) %>% 
  ungroup()

cens_sum

# Proportion of whole country

# cens_sum <- 
#   cens_sum %>% 
#   left_join(
#     cens_sum %>% 
#       filter(area == "WHOLE COUNTRY") %>% 
#       select(-area) %>% 
#       rename(whole_n_at_risk = n_at_risk)
#   ) %>% 
#   mutate(
#     prop_whole = n_at_risk / whole_n_at_risk 
# )

# Write file

cens_sum

write_csv(
  cens_sum, 
  paste0(
    "/Users/David/Documents/GitHub/covid_psyserv",
    "/data/denominator/",
    "child_adol_living_fin_2021_",
    f_timestamp(),
    ".csv"
  )
)


# Estimated for 2021 ------------------------------------------------------

# For Sept 2021

# https://pxnet2.stat.fi:443/PXWeb/sq/4b8a9c32-e596-4659-a728-0bf013688306
# https://pxnet2.stat.fi:443/PXWeb/api/v1/en/StatFin/vrm/vamuu/statfin_vamuu_pxt_11lj.px

est_csv <- read_csv(
  "data/denominator/005_11lj_2021m10_20211202-203532.csv",
  skip = 1 # skip first row
)

est_csv 

# Tidy data ---------------------------------------------------------------

# Rename

est_m <- 
  est_csv %>% 
  select(2:3, contains(" Males"))

est_f <- 
  est_csv %>% 
  select(2:3, contains(" Females"))

est_t <- 
  est_csv %>% 
  select(2:3, contains(" Total"))

colnames(est_m) <- 
  c("Area", "Age", 2021)

colnames(est_f) <- 
  c("Area", "Age", 2021)

colnames(est_t) <- 
  c("Area", "Age", 2021)

# Make long data and bind rows

est_tidy <- 
  bind_rows(
    est_m %>% 
      pivot_longer(3, "year") %>% 
      mutate(gender = "Males"),
    est_f %>% 
      pivot_longer(3, "year") %>% 
      mutate(gender = "Females"),
    est_t %>% 
      pivot_longer(3, "year") %>% 
      mutate(gender = "Total")
  )

# Summarise by age group and other stratifiers

est_sum <- 
  est_tidy %>% 
  rename(area = Area) %>% 
  mutate(
    year = as.numeric(year), 
    age_group = case_when(
      Age <= 12 ~ "0-12", 
      Age > 12 & Age <= 17 ~ "13-17"
    )
  ) %>% 
  group_by(area, year, gender, age_group) %>% 
  summarise(n_at_risk = sum(value)) %>% 
  ungroup()

est_sum

# Write file

est_sum

write_csv(
  est_sum, 
  paste0(
    "data/denomintor/",
    "child_adol_living_fin_estimated_sept_2021_",
    f_timestamp(),
    ".csv"
  )
)


# Combine official census na destimated numbers  --------------------------

cens_sum
est_sum

bind_rows(
  cens_sum,
  est_sum
)

write_csv(
  bind_rows(
    cens_sum,
    est_sum
  ), 
  paste0(
    "data/denomintor/",
    "child_adol_living_fin_2017_2021_",
    f_timestamp(),
    ".csv"
  )
)
