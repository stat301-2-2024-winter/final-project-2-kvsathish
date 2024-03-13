## Tuned elastic net models

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
load("results/basic_rec.rda")
load("results/off_rec.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)

## Tuned model with basic recipe ----

# specify model
elastic_spec <-
  logistic_reg(
    penalty = tune(),
    mixture = tune()
  ) |> 
  set_engine("glmnet") |> 
  set_mode("classification")

elastic_params <- 
  extract_parameter_set_dials(elastic_spec) |> 
  update(penalty = penalty(range = c(-4, 0))) |>
  update(mixture = mixture(range = c(0, 1)))

# define workflow
elastic_wflow <- workflow() |> 
  add_model(elastic_spec) |>  
  add_recipe(basic_rec)

# hyperparam values for tuning

elastic_grid <- grid_regular(elastic_params, levels = 5)

elastic_tune <- elastic_wflow |> 
  tune_grid(
    bball_folds, 
    grid = elastic_grid,
    control = control_grid(save_workflow = TRUE)
  )

# save fit
save(elastic_tune, file = here("results/elastic_tune.rda"))

# find most accurate model
elastic_best <- show_best(elastic_tune, metric = "accuracy")
elastic_best


## Tuned model with offensive variant recipe ----

# specify model
elastic_spec <-
  logistic_reg(
    penalty = tune(),
    mixture = tune()
  ) |> 
  set_engine("glmnet") |> 
  set_mode("classification")

elastic_params <- 
  extract_parameter_set_dials(elastic_spec) |> 
  update(penalty = penalty(range = c(-4, 0))) |>
  update(mixture = mixture(range = c(0, 1)))

# define workflow
elastic_wflow_2 <- workflow() |> 
  add_model(elastic_spec) |>  
  add_recipe(off_rec)

# hyperparam values for tuning

elastic_grid_2 <- grid_regular(elastic_params, levels = 5)

elastic_tune_off <- elastic_wflow_2 |> 
  tune_grid(
    bball_folds, 
    grid = elastic_grid_2,
    control = control_grid(save_workflow = TRUE)
  )

# save fit
save(elastic_tune_off, file = here("results/elastic_tune_off.rda"))

# find most accurate model
elastic_best <- show_best(elastic_tune, metric = "accuracy")
