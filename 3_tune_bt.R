## Tuned boosted trees model

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


## Tuned bt model ----

# specify model for tuning
bt_mod <- boost_tree(
  min_n = tune(),
  mtry = tune(),
  learn_rate = tune()
) |> 
  set_engine("xgboost") |> 
  set_mode("classification")

extract_parameter_set_dials(bt_mod)


# define workflow
bt_mod_wflow <- workflow() |> 
  add_model(bt_mod) |>  
  add_recipe(trees_rec)

# hyperparam values for tuning
bt_params <- extract_parameter_set_dials(bt_mod) |>
  update(mtry = mtry(range = c(1, 8))) |> 
  update(learn_rate = learn_rate(c(-5, -0.2)))

bt_grid <- grid_regular(bt_params, levels = 5)

bt_tune <- bt_mod_wflow |> 
  tune_grid(
    bball_folds, 
    grid = bt_grid,
    control = control_grid(save_workflow = TRUE)
  )

# save fit
save(bt_tune, file = here("results/bt_tune.rda"))

# find most accurate model
bt_best <- show_best(bt_tune, metric = "accuracy")
bt_best
