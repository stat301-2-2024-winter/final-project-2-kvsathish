## Model Analysis

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

load("results/null_fit.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)


# log regression 
logreg_pred <- bball_test |> 
  bind_cols(predict(logreg_fit, bball_test)) |> 
  select(pick, .pred_class)

# null model
null_pred <- bball_test |> 
  bind_cols(predict(null_fit, bball_test)) |> 
  select(pick, .pred_class)


# table of necessary accuracy metrics
accuracy_table <- tibble(
  model = c("logistic regression", "null model"),
  accuracy = c(
    (accuracy(logreg_pred, truth = pick, estimate = .pred_class) |> pull(.estimate)),
    (accuracy(null_pred, truth = pick, estimate = .pred_class) |> pull(.estimate))
  )
)

accuracy_table |> 
  kable(align = "c", caption = "Accuracy metric for models predicting `pick`")

# make confusion matrix
log_conf_matrix <- logreg_pred |> 
  conf_mat(truth = pick, estimate = .pred_class)

log_conf_matrix