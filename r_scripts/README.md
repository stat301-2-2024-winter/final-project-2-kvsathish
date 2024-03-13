## R Scripts 

- `1_initial_setup.R`: initial data split & forming of resamples
- `2_recipes.R`: data preprocessing/feature engineering for various models
- `3_fit_baseline.R`: fitting of baseline to resamples (Not applicable to project)
- `3_fit_logreg.R`: fitting of logistic regression models to resamples
- `3_fit_naive_bayes.R`: fitting of naive bayes model to resamples 
- `3_tune_bt.R`: fitting/tuning of boosted tree models to resamples 
- `3_tune_elastic_net.R`: fitting/tuning of elastic net models to resamples 
- `3_tune_knn.R`: fitting/tuning of k-nearest neighbor models to resamples 
- `3_tune_rf.R`: fitting/tuning of random forest models to resamples 
- `4_model_analysis.R`: analysis/comparison of models fit to resamples, final model selection by accuracy metric
- `5_final_training.R`: training/fitting of final model
- `6_final_assessment.R`: assessment of final model with testing data