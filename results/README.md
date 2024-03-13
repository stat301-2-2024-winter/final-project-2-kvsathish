## Overview

All the data splits/folds as well as all the fitted/tuned models are contained in this directory.

### Data

- `bball_folds.rda`: data folds
- `bball_split.rda`: data split
- `bball_test.rda`: testing data
- `bball_train.rda`: training data

### Fitted/Tuned Models

- `bt_tune_off.rda`: fitted/tuned boosted tree model with feature enginnering recipe
- `bt_tune.rda`: fitted/tuned boosted tree model with basic recipe
- `elastic_tune_off.rda`: fitted/tuned elastic net model with feature enginnering recipe
- `elastic_tune.rda`: fitted/tuned elastic net model with basic recipe
- `final_fit.rda`: final fitted/tuned elastic net model with basic recipe on the training data
- `knn_tune_off.rda`: fitted/tuned k-nearest neighbor model with feature enginnering recipe
- `knn_tune.rda`: fitted/tuned k-nearest neighbor model with basic recipe
- `logreg_fit_off.rda`: fitted logistic regression model with feature enginnering recipe
- `logreg_fit.rda`: fitted logistic regression model with basic recipe
- `nb_fit.rda`: fitted naive bayes model with basic recipe (baseline model)
- `null_fit.rda`: fitted null model with basic recipe (unused)
- `rf_fit.rda`: fitted random forest model with basic recipe (unused)
- `rf_tune_off.rda`: fitted/tuned random forest model with feature enginnering recipe
- `rf_tune.rda`: fitted/tuned random forest model with basic recipe
