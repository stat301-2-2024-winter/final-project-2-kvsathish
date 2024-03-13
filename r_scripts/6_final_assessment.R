## Final assessment of best model with testing data

## packages and datasets
library(tidyverse)
library(skimr)
library(here)
library(knitr)
library(rsample)
library(tidymodels)
library(doParallel)
set.seed(423)


load("results/bball_test.rda")
load("results/final_fit.rda")

bball_test <- bball_test |> 
  mutate(pick = factor(pick))

# handle common conflicts
tidymodels_prefer()

# work in parallel
num_cores <- parallel::detectCores(logical=TRUE)
registerDoParallel(cores=num_cores)

# make metric set
bball_metric <- metric_set(accuracy)

# tibble of predicted values
en_predict <- bball_test |> 
  bind_cols(predict(final_fit, bball_test)) |> 
  select(pick, .pred_class)

# apply metrics to predictions
bball_metric(en_predict, truth = pick, estimate = .pred_class) |> 
  select(.metric, .estimate) |> 
  kable(align = "c", col.names = c("Metric", "Estimate"), 
        caption = "Evaluation of Predictions by Elastic Net using Accuracy")

# confusion matrix
en_conf <- en_predict |> 
  conf_mat(truth = pick, estimate = .pred_class)

# plot confusion matrix as heatmap
conf_mat_heatmap <- 
  en_conf |> 
  autoplot(type = "heatmap")

# save plot
ggsave(
  filename = "images/conf_mat_heatmap.png",
  plot = conf_mat_heatmap,
  units = "in",
  width = 6,
  height = 4
)
