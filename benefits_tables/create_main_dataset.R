############################################################################
#
# This script combines the individual benefit datasets to create a master dataset
#
##############################################################################

calculate_taxes <- function(family_types) {

  # calculate taxes for each family type
  # use `create_benefits_table()` to calculate family types
  # the output from `create_benefits_table()` is used as input (`family_type`) for this function

  distinct_families <- family_types |>
    dplyr::distinct(monthly_income, adults, children) |>
    dplyr::mutate(taxsimid = dplyr::row_number())

  tax_data <- distinct_families |>
    dplyr::mutate(yearly_income = monthly_income * 12) |>
    dplyr::distinct(yearly_income, adults, children) |>
    dplyr::rename(depx = children) |>
    dplyr::mutate(
      taxsimid = dplyr::row_number(),
      year = 2019,
      mstat = dplyr::if_else(adults == 1, 1, 2),
      state = "NC",
      page = 30,
      sage = dplyr::if_else(adults == 1, 0, 30),
      age1 = dplyr::if_else(depx >= 1, 5, 0),
      age2 = dplyr::if_else(depx >= 2, 10, 0),
      age3 = dplyr::if_else(depx >= 3, 15, 0),
      pwages = dplyr::if_else(adults == 1, yearly_income, yearly_income / 2),
      swages = dplyr::if_else(adults == 1, 0, yearly_income / 2)
    ) |>
    dplyr::select(taxsimid, depx, year:swages)

  tax_amounts <- usincometaxes::taxsim_calculate_taxes(
    .data = tax_data,
    marginal_tax_rates = 'Wages',
    return_all_information = FALSE
  ) |>
    dplyr::mutate(total_taxes = (fiitax + siitax + (tfica / 2)) / 2) |>
    dplyr::select(taxsimid, total_taxes)

  if (nrow(tax_amounts) != nrow(distinct_families)) stop("Problems calculating taxes", call. = FALSE)
  if (!all(tax_amounts$taxsimid == distinct_families$taxsimid)) stop("Problems calculating taxes", call. = FALSE)

  distinct_families |>
    dplyr::left_join(tax_amounts, by = "taxsimid", relationship = "one-to-one")

}

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

  message("Creating base table")

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
