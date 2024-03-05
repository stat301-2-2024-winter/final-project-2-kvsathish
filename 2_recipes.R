## Recipes

## load packages and necessary data
library(tidyverse)
library(skimr)
library(here)
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

## Baseline + Logistic Regression Recipe ----

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

## Naive Bayes Recipe ----
nb_rec <- 
  recipe(pick ~ ., data = bball_train) |> 
  step_rm(player_name, ht, num, pfr, year, pid, type,
          rimmade, rimmade_rimmiss, midmade, midmade_midmiss,
          rimmade_rimmade_rimmiss, midmade_midmade_midmiss,
          dunksmiss_dunksmade, dunksmade_dunksmade_dunksmiss, x65) |> 
  step_zv(all_predictors()) |> 
  step_impute_mean(all_numeric_predictors()) 

# check recipe
nb_rec |> 
  prep() |> 
  bake(new_data = NULL) |> 
  glimpse()

# save recipe
save(nb_rec, file = here("results/nb_rec.rda"))

## Tree-Based Recipe ----


## Boosted Tree Recipe ----


## Extra notes for recipes ----

# In terms of recipes for the six models above, I plan to make about four recipes. 
# This is because I'm going to use a basic (kitchen-sink) recipe for the null and logistic models. 
# A separate trees-based recipe will be created for usage with the random forest and boosted trees model. 
# Also, I plan to make another recipe that corresponds well with the k-nearest neighbors model. 
# Finally, another recipe will be made to adjust for the naive bayes model because the 'step_dummy()' function won't be utilized with this model.

#distinct recipes for both model types
#- then variants of each
#- at least 4 recipes
#- 5th recipe for null/baseline

#tree-based recipes don't need factors turned into numbers

#knn - can do linear or tree-based (probably tree-based in literature)
#- could use both

#math formulation difference

#parametric vs not