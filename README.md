Comparison of new psychiatric diagnoses among children and adolescents
before and during the COVID-19 pandemic: A nationwide register-based
study
================

[![DOI](https://zenodo.org/badge/511254713.svg)](https://zenodo.org/badge/latestdoi/511254713)

## Introduction

This document shows how to perform the analyses and vizualize the
results as described in the manuscript ‘Comparison of new psychiatric
diagnoses among children and adolescents before and during the COVID-19
pandemic: A nationwide register-based study’.

## Reproducing analyses

Clone the repository from <https://github.com/davgyl/covid_psyserv.git>.

## Prepare the denominator

The program to edit the data containing the number at risk is found in
`code/01_prep_denominator.R`.

## Time series data

The time series data used for running the analyses is found in
`data/ts_aggregated.rds` and it has the following structure.

``` r
source("code//00_pkgs_utils.R")

ts_m <- read_rds("data/ts_aggregated.rds")
ts_m %>% glimpse()
```

    ## Rows: 798
    ## Columns: 14
    ## $ ts            <chr> "01_any", "01_any", "01_any", "01_any", "01_any", "01_an…
    ## $ lab_ts        <chr> "Any diagnosis", "Any diagnosis", "Any diagnosis", "Any …
    ## $ order_outcome <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
    ## $ lab_sex       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ lab_age       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ lab_area      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ lab_outcome   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ yearmonday    <date> 2017-01-15, 2017-02-15, 2017-03-15, 2017-04-15, 2017-05…
    ## $ YEAR          <dbl> 2017, 2017, 2017, 2017, 2017, 2017, 2017, 2017, 2017, 20…
    ## $ MONTH         <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6,…
    ## $ n             <dbl> 1505, 1400, 1564, 1349, 1624, 1522, 605, 1343, 1477, 149…
    ## $ nrisk         <dbl> 1066261, 1066261, 1066261, 1066261, 1066261, 1066261, 10…
    ## $ rate1000      <dbl> 1.4114743, 1.3129994, 1.4668078, 1.2651687, 1.5230792, 1…
    ## $ ln_risk       <dbl> 13.87967, 13.87967, 13.87967, 13.87967, 13.87967, 13.879…

The variables `ts` and `lab_ts` clusters the time series to  
\- One time serie of any diagnosis without stratification (`01_any`)  
\- Two time series of any diagnosis stratified by sex (`02_sex`)  
\- Two time series of any diagnosis stratified by age group (`03_age`)  
\- Two time series of any diagnosis stratified by geomgraphic area
(`04_area`)  
\- Seven time series of diagnostic groups as outcomes (`04_area`)

| ts       | lab\_ts                    |
| :------- | :------------------------- |
| 01\_any  | Any diagnosis              |
| 02\_sex  | Any diagnosis by sex       |
| 03\_age  | Any diagnosis by age group |
| 04\_area | Any diagnosis by area      |
| 05\_out  | Diagnostic groups          |

## Modelling and visualization

  - The program for modelling data is found in
    `code/02_model_functions.R`.  
  - To model the associations, run `code/03_model_all_ts.R`.  
  - To edit tables, run `code/04_viz_table1_descr.R` and
    `code/05_viz_table2.R`.  
  - To visualize the associations as figures, run
    `code/06_viz_fig_aim1.R` for Figure 1 and `code/07_viz_fig_aim2.R`
    for Figure 2.  
  - To plot supplemental figures, run
    `code/08_covid_patients_hospital.R` and
    `code/10_stratification.R`.  
  - To examine immigration and emigration, run
    `code/09_emigration_immigration.R`

## Immigration and emigration

The number and percentage of youth immigrating and emigrating per year
is shown in the table below as described in detail in
`code/09_emigration_immigration.R`.

| Year | Total\_immigration | Total\_emigration | Total\_population | Percent\_immigration | Percent\_emigration |
| ---: | -----------------: | ----------------: | ----------------: | -------------------: | ------------------: |
| 2017 |               8287 |              2886 |           1186479 |            0.6984532 |           0.2432407 |
| 2018 |               7361 |              3219 |           1178401 |            0.6246600 |           0.2731668 |
| 2019 |               7710 |              3173 |           1167707 |            0.6602684 |           0.2717291 |
| 2020 |               7570 |              2432 |           1159093 |            0.6530969 |           0.2098192 |

## Versions

R version: 3.6.3. Version of packages are shown in the table below.

| Package   | Version  |
| :-------- | :------- |
| MASS      | 7.3.51.5 |
| tidyverse | 1.3.0    |
| stringr   | 1.4.0    |
| openxlsx  | 4.1.4    |
| knitr     | 1.28     |
| lubridate | 1.7.4    |
| codebook  | 0.9.2    |
| haven     | 2.4.3    |
| broom     | 0.5.5    |
