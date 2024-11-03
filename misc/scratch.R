# source data -----------------------

fuction_files <- list.files('functions', recursive = TRUE, full.names = TRUE, pattern = "\\.R$")

purrr::walk(fuction_files, source)

# create data --------------------

family_composition <- family_benefit_values('family')[3]
unique_benefits <- family_benefit_values('benefits')[1:3]

# this will be saved out as an rds file
benefits_table <- create_benefits_table(income_increment = 10)

# create viz -------------------------

plt_total_income(benefits_table, family_composition, unique_benefits)

plt_benefits_single_family(benefits_table, family_composition)

