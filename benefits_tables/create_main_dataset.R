############################################################################
#
# This script combines the individual benefit datasets to create a master dataset
#
##############################################################################

create_benefits_table <- function() {

  tables_folder <- "benefits_tables"

  # source all function files ----------------------
  # files are split between general functions in the 'functions' folder
  # and functions that calculate benefits in the 'benefits' folder

  # create single vector with all the file names containing functions
  function_files <- list.files(path = paste0(tables_folder, "/functions"), pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
  benefit_files <- list.files(path = paste0(tables_folder, "/benefits"), pattern = "\\.R$", recursive = TRUE, full.names = TRUE)

  all_function_files <- c(function_files, benefit_files)

  # source all functions
  purrr::walk(all_function_files, source)

  # create benefits table -------------------------

  base_table <- base_composition()

  .data <- dplyr::bind_rows(
    list(
      child_care(base_table),
      fns_snap(base_table),
      housing_voucher(base_table),
      medicaid(base_table),
      tanf(base_table)
    )) |>
    dplyr::arrange(benefit, monthly_income, adults, children)

  return(.data)

}
