## Tuned k-nearest neighbor models

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
load("results/off_trees.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)


## Tuned model with basic trees recipe ----

# specify model for tuning
knn_mod <- nearest_neighbor(
  neighbors = tune()
) |> 
  set_engine("kknn") |> 
  set_mode("classification")

extract_parameter_set_dials(knn_mod)


# define workflow
knn_mod_wflow <- workflow() |> 
  add_model(knn_mod) |>  
  add_recipe(trees_rec)

# hyperparam values for tuning
knn_params <- extract_parameter_set_dials(knn_mod)

knn_grid <- grid_regular(knn_params, levels = 5)

knn_tune <- knn_mod_wflow |> 
  tune_grid(
    bball_folds, 
    grid = knn_grid,
    control = control_grid(save_workflow = TRUE)
  )

# save fit
save(knn_tune, file = here("results/knn_tune.rda"))

# find most accurate model
knn_best <- show_best(knn_tune, metric = "accuracy")
knn_best


## Tuned model with offensive variant trees recipe ----

# specify model for tuning
knn_mod_off <- nearest_neighbor(
  neighbors = tune()
) |> 
  set_engine("kknn") |> 
  set_mode("classification")

extract_parameter_set_dials(knn_mod_off)


# define workflow
knn_mod_wflow_off <- workflow() |> 
  add_model(knn_mod_off) |>  
  add_recipe(off_trees)

# hyperparam values for tuning
knn_params_off <- extract_parameter_set_dials(knn_mod_off)

knn_grid_off <- grid_regular(knn_params_off, levels = 5)

knn_tune_off <- knn_mod_wflow_off |> 
  tune_grid(
    bball_folds, 
    grid = knn_grid_off,
    control = control_grid(save_workflow = TRUE)
  )

# save fit
save(knn_tune_off, file = here("results/knn_tune_off.rda"))

# find most accurate model
knn_best_off <- show_best(knn_tune_off, metric = "accuracy")
knn_best_off