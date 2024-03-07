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