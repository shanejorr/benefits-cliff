family_benefit_values <- function(value_name) {

  value_name_params <- c('family', 'benefits')

  check_parameters(value_name, value_name_params)

  family_and_benefits <- list(
    family = c(
      "1 adult", "1 adult, 1 child", "1 adult, 2 children", "1 adult, 3 children",
      "2 adults", "2 adults, 1 child", "2 adults, 2 children", "2 adults, 3 children"
    ),
    benefits = c(
      "FNS (Food Stamps)", "Housing Choice Voucher", "NC Child Care Subsidy", "NC Medicaid / Health Choice", "Work First (TANF)"
    )
  )

  family_and_benefits[[value_name]]

}


check_parameters <- function(actual_data, test_data, test_name) {

  if (!all(actual_data %in% test_data)) {
    stop(
      glue::glue("Error: Some values in {test_name} are not valid. Valid values are:\n"),
      paste(sprintf("'%s'", test_data), collapse = ", "),
      call. = FALSE
    )
  }

}
