## Recipes

## load packages and necessary data
library(tidyverse)
library(skimr)
library(ggplot2)
library(here)
library(naniar)
library(knitr)
library(rsample)
library(tidymodels)
set.seed(423)

load("data/bball_players.rda")

load("results/bball_split.rda")
load("results/bball_train.rda")
load("results/bball_test.rda")
load("results/bball_folds.rda")

# handle common conflicts
tidymodels_prefer()

## Logistic Regression Recipe ----

# basic recipe
basic_rec <- 
  recipe(pick ~ ., data = bball_train) |> 
  step_rm(player_name, ht, num, pfr, year, pid, type,
          rimmade, rimmade_rimmiss, midmade, midmade_midmiss,
          rimmade_rimmade_rimmiss, midmade_midmade_midmiss,
          dunksmiss_dunksmade, dunksmade_dunksmade_dunksmiss, x65) |> 
  step_dummy(all_nominal_predictors()) |> 
  step_zv(all_predictors()) |> 
  step_impute_mean(all_numeric_predictors()) |> 
  step_normalize(all_predictors())

# check recipe
basic_rec |> 
  prep() |> 
  bake(new_data = NULL) |> 
  glimpse()

# save recipe
save(basic_rec, file = here("results/basic_rec.rda"))

## Tree-Based Recipe ----


## Boosted Tree Recipe ----