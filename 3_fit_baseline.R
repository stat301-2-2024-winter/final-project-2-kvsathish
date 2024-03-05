## Fit for baseline model

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

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)

# specify model
null_spec <- null_model() |> 
  set_engine("parsnip") |> 
  set_mode("classification") 

# define workflow
null_workflow <- workflow() |> 
  add_model(null_spec) |>  
  add_recipe(basic_rec)

# fit model
null_fit <- null_workflow |> 
  fit_resamples(
    resamples = bball_folds, 
    control = control_resamples(save_workflow = TRUE)
  )

# save fit
save(null_fit, file = here("results/null_fit.rda"))