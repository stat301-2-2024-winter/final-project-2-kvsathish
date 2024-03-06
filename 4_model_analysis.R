## Model Analysis

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
load("results/basic_rec.rda")

load("results/null_fit.rda")
load("results/logreg_fit.rda")
load("results/nb_fit.rda")
load("results/rf_fit.rda")

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)


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