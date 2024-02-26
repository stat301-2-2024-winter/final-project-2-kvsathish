## R script for progress memo 1

## packages and datasets
library(tidyverse)
library(skimr)
library(ggplot2)
library(here)
library(naniar)
library(knitr)
set.seed(423)

## OLD ----
## reading in data ----

# cbb_players <- read_csv("data/CollegeBasketballPlayers2009-2021.csv")

# View(cbb_players)

# summary statistics
# summary(cbb_players)

# check for missing values
# missing_values <- colSums(is.na(cbb_players))
# print(missing_values)

# count the number of categorical and numerical variables
#num_vars <- sapply(cbb_players, is.numeric)
#cat_vars <- sapply(cbb_players, is.factor)

# display the results
#cat("Number of variables:", ncol(cbb_players), "\n")
#cat("Number of observations:", nrow(cbb_players), "\n")
#cat("Number of numerical variables:", sum(num_vars), "\n")
#cat("Number of categorical variables:", sum(cat_vars), "\n")



# display missingness
#missing_summary <- cbb_players %>%
  #summarise_all(~mean(is.na(.)) * 100) %>%
  #gather(variable, missing_percentage) |> 
  #filter(missing_percentage > 0)

#kable(missing_summary, 
      #col.names = c("Variable", "Missing Percentage"),
      #caption = "Variables with Missing Values") 

# summary statistics
#summary(cbb_players$pick)

# summary with skimr
#skim(cbb_players$pick)

# histogram
#ggplot(cbb_players, aes(x = pick)) +
  #geom_density(fill = "skyblue", color = "black") +
  #labs(title = "Distribution of Pick Variable",
       #x = "Pick",
       #y = "Frequency") +
  #theme_minimal()

# missingness
#sum(is.na(cbb_players$pick))


## new read in of data ----

bball_players <- read_csv("data/CollegeBasketballPlayers2009-2021.csv") |> 
  janitor::clean_names() |> 
  mutate(pick = ifelse(!is.na(pick) & pick <= 60, "Yes", "No"))


View(bball_players)


# save data
save(bball_players, file = here("data/bball_players.rda"))


# visualize target variable pick
bball_players |> 
  ggplot(aes(x = pick)) +
  geom_bar() +
  labs(title = "Distribution of `pick`",
       y = NULL) +
  theme_minimal()

