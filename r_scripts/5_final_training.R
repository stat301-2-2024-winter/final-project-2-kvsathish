## Train Final Model ----

## packages and datasets
library(tidyverse)
library(skimr)
library(here)
library(knitr)
library(rsample)
library(tidymodels)
library(doParallel)
set.seed(423)


load("results/bball_train.rda")
load("results/elastic_tune.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)

# finalize workflow
final_wflow <-
  elastic_tune |>
  extract_workflow() |>
  finalize_workflow(select_best(elastic_tune, metric = "accuracy"))


# final fit
final_fit <- fit(final_wflow, bball_train)


# save fit
save(final_fit, file = here("results/final_fit.rda"))