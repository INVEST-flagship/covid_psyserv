source("code//00_pkgs_utils.R")

# Functions for prediction w/ neg bin distribution ------------------------

# Negative binomial distribution

# Monthly data
ts_pred_month <- 
  function(df = df) {
    
    train <- 
      df %>% 
      filter(yearmonday < "2020-03-01")
    
    test <- 
      df %>% 
      filter(yearmonday >= "2020-03-01") 
    
    # Train negative binomial model
    
    model_negbin <-
      glm.nb(
        n ~ MONTH %>% as.character() + YEAR + offset(ln_risk),
        data = train
      )
    
    # Predict on data data after cutoff
    
    model_negbin_pred <-
      predict(
        model_negbin,
        newdata = test %>% select(MONTH, YEAR, ln_risk),
        se.fit = T, 
        type = "response" # needed to display counts
      )
    
    model_negbin_pred_fit <-
      tibble(
        negbin_pred = model_negbin_pred$fit,
        negbin_pred_se = model_negbin_pred$se.fit
      )
    
    test <-
      test %>%
      bind_cols(
        model_negbin_pred_fit
      ) %>% 
      mutate(
        negbin_pred_lo = negbin_pred - 1.96*negbin_pred_se, #95% prediction interval
        negbin_pred_hi = negbin_pred + 1.96*negbin_pred_se,
        
        n_pred = negbin_pred %>% as.integer(), # predictions as counts
        n_pred_lo = negbin_pred_lo %>% as.integer(),
        n_pred_hi = negbin_pred_hi %>% as.integer(),
        
        negbin_pred_rate = negbin_pred / nrisk * 1000, # predictionas rates
        negbin_pred_rate_lo = negbin_pred_lo / nrisk * 1000, 
        negbin_pred_rate_hi = negbin_pred_hi / nrisk * 1000
      )
    
    # Combine train and test datasets
    
    train_test <- 
      bind_rows(
        train, test
      )
    
    # Add differences (absolute and relative)
    
    train_test <- 
      train_test %>% 
      mutate(
        
        # Rates
        
        diff_rate_abs = rate1000 - negbin_pred_rate, 
        diff_rate_rel_perc = (1 - (negbin_pred_rate / rate1000)) * 100, 
        diff_rate_sign = case_when(
          rate1000 >= negbin_pred_rate_lo & rate1000 <= negbin_pred_rate_hi ~ 0, 
          is.na(negbin_pred_rate) ~ NA_real_, 
          TRUE ~ 1
        ), 
        
        # Counts (non-integer)
        
        diff_n_abs = n - negbin_pred, 
        diff_n_rel_perc = (1 - (negbin_pred / n)) * 100, 
        diff_n_sign = case_when(
          n >= negbin_pred_lo & n <= negbin_pred_hi ~ 0, 
          is.na(negbin_pred) ~ NA_real_, 
          TRUE ~ 1
        ), 
        
        # Counts (integer)
        
        diff_n_abs_int = n - n_pred, 
        diff_n_abs_int_lo = n - n_pred_hi,
        diff_n_abs_int_hi = n - n_pred_lo
        
      ) 
    
    return(train_test)
    
  }


# Function for poisson prediction -----------------------------------------

ts_pred_month_poi <- 
  function(df = df) {
    
    train <- 
      df %>% 
      filter(yearmonday < "2020-03-01")
    
    test <- 
      df %>% 
      filter(yearmonday >= "2020-03-01") 
    
    # Train model
    
    model_poi <-
      glm(
        n ~ MONTH %>% as.character() + YEAR + offset(ln_risk),
        data = train, 
        family = poisson(link = "log") 
      )
    
    # Predict on data data after cutoff
    
    model_poi_pred <-
      predict(
        model_poi,
        newdata = test %>% select(MONTH, YEAR, ln_risk),
        se.fit = T, 
        type = "response" # needed to display counts
      )
    
    model_poi_pred_fit <-
      tibble(
        poi_pred = model_poi_pred$fit,
        poi_pred_se = model_poi_pred$se.fit
      )
    
    test <-
      test %>%
      bind_cols(
        model_poi_pred_fit
      ) %>% 
      mutate(
        poi_pred_lo = poi_pred - 1.96*poi_pred_se, #95% prediction interval
        poi_pred_hi = poi_pred + 1.96*poi_pred_se,
        
        n_pred = poi_pred %>% as.integer(), # predictions as counts
        n_pred_lo = poi_pred_lo %>% as.integer(),
        n_pred_hi = poi_pred_hi %>% as.integer(),
        
        poi_pred_rate = poi_pred / nrisk * 1000, # predictionas rates
        poi_pred_rate_lo = poi_pred_lo / nrisk * 1000, 
        poi_pred_rate_hi = poi_pred_hi / nrisk * 1000
      )
    
    # Combine train and test datasets
    
    train_test <- 
      bind_rows(
        train, test
      )
    
    # Add differences (absolute and relative)
    
    train_test <- 
      train_test %>% 
      mutate(
        
        # Rates
        
        diff_rate_abs = rate1000 - poi_pred_rate, 
        diff_rate_rel_perc = (1 - (poi_pred_rate / rate1000)) * 100, 
        diff_rate_sign = case_when(
          rate1000 >= poi_pred_rate_lo & rate1000 <= poi_pred_rate_hi ~ 0, 
          is.na(poi_pred_rate) ~ NA_real_, 
          TRUE ~ 1
        ), 
        
        # Counts (non-integer)
        
        diff_n_abs = n - poi_pred, 
        diff_n_rel_perc = (1 - (poi_pred / n)) * 100, 
        diff_n_sign = case_when(
          n >= poi_pred_lo & n <= poi_pred_hi ~ 0, 
          is.na(poi_pred) ~ NA_real_, 
          TRUE ~ 1
        ), 
        
        # Counts (integer)
        
        diff_n_abs_int = n - n_pred, 
        diff_n_abs_int_lo = n - n_pred_hi,
        diff_n_abs_int_hi = n - n_pred_lo
        
      ) 
    
    return(train_test)
    
  }
