plt_total_income <- function(benefits_table, unique_composition, unique_benefits) {

  # plot income plus benefits minus taxes by wage income and
  # income minus taxes by wage income
  # `benefits_table` is created with `create_benefits_table()`

  # don't need to check parameters because this is done in `total_take_home_income`

  income_plus_benefits <- benefits_table |>
    total_take_home_income(unique_composition, unique_benefits) |>
    dplyr::select(monthly_income, income_minus_taxes, take_home) |>
    tidyr::pivot_longer(cols = c('income_minus_taxes', 'take_home'), names_to = 'pay_type', values_to = 'income') |>
    dplyr::mutate(
      pay_type = dplyr::case_match(
        pay_type,
        'income_minus_taxes' ~ 'Income minus taxes',
        'take_home' ~ 'Income plus benefits, minus taxes'
      )
    )

  highcharter::hchart(income_plus_benefits, "line", highcharter::hcaes(x = monthly_income, y = income, group = pay_type)) |>
    # Add a title and axis titles
    highcharter::hc_title(text = "Total take home income by wage") |>
    highcharter::hc_subtitle(text = glue::glue("Family type: ")) |>
    highcharter::hc_xAxis(title = list(text = "Monthly wage income"),
             labels = list(format = "${value:,.0f}")) |>
    highcharter::hc_yAxis(title = list(text = "Total take home income"),
             labels = list(format = "${value:,.0f}")) |>
    # Customize the tooltip to show y-axis value at the top and format x values
    highcharter::hc_tooltip(
      shared = TRUE,
      headerFormat = '<span style="font-size: 10px">Monthly income: <b>${point.key:,.0f}</b></span><br/>',
      pointFormat = '<span style="color:{series.color}">\u25CF</span> {series.name}: <b>${point.y:,.0f}</b><br/>'
    )

}

plt_benefits_single_family <- function(benefits_table, family_composition) {

  # line chart of individual benefits income
  # `benefits_table` is created with `create_benefits_table()`

  check_parameters(family_composition, family_benefit_values('family'), 'family_composition')
  check_parameters(unique(benefits_table$composition), family_benefit_values('family'), 'composition column')
  check_parameters(unique(benefits_table$benefit), family_benefit_values('benefits'), 'benefits column')

  benefits_table |>
    dplyr::filter(composition == !!family_composition) |>
    highcharter::hchart("line", highcharter::hcaes(x = monthly_income, y = payment, group = benefit)) |>
      # Add a title and axis titles
      highcharter::hc_title(text = "Benefit levels by income") |>
      highcharter::hc_subtitle(text = glue::glue("Family type: {family_composition}")) |>
      highcharter::hc_xAxis(title = list(text = "Monthly Income"),
               labels = list(format = "${value:,.0f}")) |>
      highcharter::hc_yAxis(title = list(text = "Benefit Amount"),
               labels = list(format = "${value:,.0f}")) |>
      # Customize the tooltip to show y-axis value at the top and format x values
      highcharter::hc_tooltip(
        shared = TRUE,
        headerFormat = '<span style="font-size: 10px">Monthly income: <b>${point.key:,.0f}</b></span><br/>',
        pointFormat = '<span style="color:{series.color}">\u25CF</span> {series.name}: <b>${point.y:,.0f}</b><br/>'
      )

}
