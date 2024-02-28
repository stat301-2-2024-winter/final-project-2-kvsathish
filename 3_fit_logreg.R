## Fit for logistic model

## packages and datasets
library(tidyverse)
library(skimr)
library(ggplot2)
library(here)
library(naniar)
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
logreg_spec <-
  logistic_reg() |> 
  set_engine("glm") |> 
  set_mode("classification")

# define workflow
logreg_wflow <- workflow() |> 
  add_model(logreg_spec) |> 
  add_recipe(basic_rec)

# fit model
logreg_fit <- logreg_wflow |> 
  fit_resamples(
    resamples = bball_folds,
    control = control_resamples(save_pred = TRUE, save_workflow = TRUE)
  )


# save fit
save(logreg_fit, file = here("results/logreg_fit.rda"))