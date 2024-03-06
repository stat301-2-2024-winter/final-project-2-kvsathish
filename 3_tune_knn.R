## Fit for k-nearest neighbor model

## packages and datasets
library(tidyverse)
library(skimr)
library(here)
library(knitr)
library(rsample)
library(tidymodels)
library(doParallel)
set.seed(423)

load("data/bball_players.rda")

load("results/bball_split.rda")
load("results/bball_train.rda")
load("results/bball_test.rda")
load("results/bball_folds.rda")
load("results/trees_rec.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)

# specify model
rf_spec <- rand_forest() |> 
  set_engine("ranger") |> 
  set_mode("classification") 

# define workflow
rf_workflow <- workflow() |> 
  add_model(rf_spec) |>  
  add_recipe(trees_rec)

# fit model
rf_fit <- rf_workflow |> 
  fit_resamples(
    resamples = bball_folds, 
    control = control_resamples(save_workflow = TRUE)
  )

# save fit
save(rf_fit, file = here("results/rf_fit.rda"))