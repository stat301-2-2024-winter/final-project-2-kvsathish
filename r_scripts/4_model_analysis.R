## Analyzing the accuracy metric for the models

## packages and datasets
library(tidyverse)
library(skimr)
library(here)
library(knitr)
library(rsample)
library(tidymodels)
library(doParallel)
set.seed(4231)

load("data/bball_players.rda")

load("results/bball_split.rda")
load("results/bball_train.rda")
load("results/bball_test.rda")
load("results/bball_folds.rda")


load("results/logreg_fit.rda")
load("results/nb_fit.rda")
load("results/rf_tune.rda")
load("results/bt_tune.rda")
load("results/knn_tune.rda")
load("results/elastic_tune.rda")

load("results/logreg_fit_off.rda")
load("results/rf_tune_off.rda")
load("results/bt_tune_off.rda")
load("results/knn_tune_off.rda")
load("results/elastic_tune_off.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)


## Current ----

## Best models ----

# make workflow set
model_results <- as_workflow_set(
  nbayes = nb_fit,
  logreg = logreg_fit,
  elastic = elastic_tune,
  rf = rf_tune,
  knn = knn_tune, 
  bt = bt_tune,
  logreg_off = logreg_fit_off,
  elastic_off = elastic_tune_off,
  rf_off = rf_tune_off,
  knn_off = knn_tune_off, 
  bt_off = bt_tune_off
)

# get highest accuracy for each model type
model_results |> 
  collect_metrics() |> 
  filter(.metric == "accuracy") |> 
  slice_max(mean, by = wflow_id) |> 
  distinct(wflow_id, .keep_all = TRUE) |>
  select(`Model Type` = wflow_id,
         `Accuracy` = mean,
         `Std Error` = std_err,
         `Num_Computations` = n) |>
  kable(digits = c(NA, 3, 4, 0))


## Best hyperparams

elastic_best <- elastic_tune |> 
  select_best(metric = "accuracy")

rf_best <- rf_tune |>
  select_best(metric = "accuracy")

knn_best <- knn_tune |>
  select_best(metric = "accuracy")

bt_best <- bt_tune |>
  select_best(metric = "accuracy")

elastic_off_best <- elastic_tune_off |> 
  select_best(metric = "accuracy")

rf_off_best <- rf_tune_off |>
  select_best(metric = "accuracy")

knn_off_best <- knn_tune_off |>
  select_best(metric = "accuracy")

bt_off_best <- bt_tune_off |>
  select_best(metric = "accuracy")


best_parameters <-
  bind_rows(
    bt_best |>  mutate (model = "Boosted Tree"),
    knn_best |>  mutate (model = "K-nearest Neighbor"),
    rf_best |>  mutate (model = "Random Forest"),
    elastic_best |>  mutate(model = "Elastic Net"),
    bt_off_best |>  mutate (model = "Boosted Tree (Off)"),
    knn_off_best |>  mutate (model = "K-nearest Neighbor(Off)"),
    rf_off_best |>  mutate (model = "Random Forest (Off)"),
    elastic_off_best |>  mutate(model = "Elastic Net (Off)"),
  ) |>
  select(model,
         mtry,
         min_n,
         learn_rate,
         neighbors,
         penalty,
         mixture) |> 
  kable(digits = c(NA, 2, 2, 3, 2, 3, 2))

## OLD ----

# bt 
select_best(rf_tune, metric = "accuracy") |> 
  kable(align = "l", caption = "Best Model for Boosted Tree")

# collect accuracy metric
null_accuracy <- null_fit |> 
  collect_metrics() |> 
  filter(.metric == "accuracy")

logreg_accuracy <- logreg_fit |> 
  collect_metrics() |> 
  filter(.metric == "accuracy")

nb_accuracy <- nb_fit |> 
  collect_metrics() |> 
  filter(.metric == "accuracy")

rf_accuracy <- rf_fit |> 
  collect_metrics() |> 
  filter(.metric == "accuracy")

rft_accuracy <- rf_tune |> 
  collect_metrics() |> 
  filter(.metric == "accuracy")

# format into a table
accuracy_table <- bind_rows(
  mutate(null_accuracy, model = "Null Model"),
  mutate(logreg_accuracy, model = "Logistic Regression"),
  mutate(nb_accuracy, model = "Naive Bayes Model"),
  mutate(rf_accuracy, model = "Random Forest Model")
) |> 
  select(model, everything())

kable(accuracy_table, caption = "Accuracy Metrics")


## OLD ----

# Calculate assessment metric for baseline model
baseline_results <- summary(null_fit)[[accuracy()]]

# Calculate assessment metric for logistic model
logistic_results <- summary(logreg_fit)[[accuracy()]]

# Display assessment results table
assessment_table <- data.frame(
  Model = c("Baseline", "Logistic"),
  Assessment_Metric = c(baseline_results, logistic_results)
)
kable(assessment_table)

# predict class probabilities
logreg_probs <- bball_test |> 
  bind_cols(predict(logreg_fit, bball_test, type = "prob")) |> 
  select(pick, .pred_Yes, .pred_No)

logreg_probs |> 
  head(5) |> 
  kable(align = "c", caption = "Sample of five observations in Basketball data with 
        class probabilities for `pick` from logreg model")

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