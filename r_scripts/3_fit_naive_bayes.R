## Fit for naive bayes model

## packages and datasets
library(tidyverse)
library(skimr)
library(here)
library(knitr)
library(rsample)
library(tidymodels)
library(doParallel)
library(discrim)
set.seed(423)

load("data/bball_players.rda")

load("results/bball_split.rda")
load("results/bball_train.rda")
load("results/bball_test.rda")
load("results/bball_folds.rda")
load("results/nb_rec.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)

# specify model
nb_spec <- naive_Bayes() |> 
  set_mode("classification") |> 
  set_engine("klaR")

# define workflow
nb_workflow <- workflow() |> 
  add_model(nb_spec) |>  
  add_recipe(nb_rec)

# fit model
nb_fit <- nb_workflow |> 
  fit_resamples(
    resamples = bball_folds, 
    control = control_resamples(save_workflow = TRUE)
  )

# save fit
save(nb_fit, file = here("results/nb_fit.rda"))