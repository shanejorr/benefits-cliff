library(tidyverse)

source('benefits_tables/create_main_dataset.R')

benefits_table <- create_benefits_table()

ggplot(benefits_table, aes(x = year, y = value, fill = variable))
