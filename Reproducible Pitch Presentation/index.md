---
title       : Reproducible data pre-processing of Shiny app
subtitle    : Housing Affordability Data 
author      : Edem Dossou
job         : Aspiring Data Scientist
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---


## OVERVIEW

> 1. Importance of data pre-processing for predictive modeling
> 2. Housing Affordability Data
> 3. Data Pre-processing
> 4. Data Pre-processing
> 5. Shiny app

--- .class #id 

## Importance of data pre-processing for predictive modeling

> 1. Data pre-processing is critical for predictive modeling exercises. However,
> 2. It must be done taking into account the type of data being modeled
> 3. It involves dealing with missing values, data normalization - centering and scaling
> 4. Some of the techniques involve dealing with each predictor separately
> 5. Other techniques deal with predictors all at once

---
## Housing Affordability Data

> 1. The data used is from the U.S department of Housing and Urban Development website
> 2. It's the Housing Affordability data derived from the American Housing Survey
> 3. More info can be found here - https://www.huduser.gov/portal/datasets/hads/hads.html
> 4. The response is the yearly house cost
> 5. The predictors are age, income, number of bedrooms

---

## Data Pre-processing


```r
#load required libraries
pacman::p_load(dplyr,funModeling,caret,data.table,rpart,randomForest,rattle, 
               ggplot2, gridExtra,shiny,DT)

#import the data
download.file("https://www.huduser.gov/portal/datasets/hads/hads2013n_ASCII.zip",
              destfile = "housing_data.zip")
#unzip file
unzip("housing_data.zip")
#read the data
data <- read.table("thads2013n.txt", sep = ",", header = TRUE)
#rename variables to lower case
names(data) <- tolower(names(data))
#select variables of interest
data <- as.data.table(data) %>% select(costmed, totsal, bedrms, age1, built) 
#scaling the housing cost to yearly cost for comparison prupose to yearly income
data[, scale_cost := costmed * 12]
```

---

## Data Pre-processing


```r
#remove values that are less than or equal to zero
data <- data[(apply(data, 1, function(x) all(x > 0)))]

#subset to get houses built post 2009
dt <- data %>% filter(built >= 2010)

#get the overall status of the data. The status resulted in a missing values free 
#data. Also no zero values in the data
dt_status <- df_status(dt)
```

---

## Shiny app

> 1. Tool to visualize the end product of my analysis
> 2. Shows the train models summary -recursive partition regression trees, random forest, and the generalized boosted model algorithms 
> 3. Random Forest was the winning model
> 4. Test sets are included to test the final model
> 5. Shows scatterplot of observed vs predicted housing costs
