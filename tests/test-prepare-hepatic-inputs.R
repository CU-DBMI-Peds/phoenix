library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-hepatic-inputs.R
#
# Phoenix-8 hepatic preparation consists of bilirubin and ALT.  Both are
# continuous/range-based values and use the usual Phoenix preparation contract
# for duplicate reduction and valid.range validation.
################################################################################

make_backends <- function(x) {
  list(
    DF = x,
    DT = as_data_table_if_available(x),
    TB = as_tibble_if_available(x)
  )
}

sort_prepared <- function(x) {
  x[order(x[["minutes_from_admission"]]), ]
}

run_range_case <- function(fun_name,
                           variable_label,
                           value.var,
                           values,
                           expected_default,
                           expected_custom,
                           custom_valid_range) {
  id.vars <- c("hospital", "patient", "encounter")
  eclock <- "minutes_from_admission"
  FUN <- get(fun_name, mode = "function")

  df <- data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 0, 60, 120),
    value = values,
    stringsAsFactors = FALSE
  )
  names(df)[names(df) == "value"] <- value.var
  testdata <- make_backends(df)

  prepared_default <- lapply(
    X = testdata,
    FUN = function(x) do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, verbose = FALSE))
  )
  prepared_default <- lapply(prepared_default, sort_prepared)

  stopifnot(
    identical(prepared_default[["DF"]][["value"]], expected_default),
    identical(prepared_default[["DT"]][["value"]], expected_default),
    identical(prepared_default[["TB"]][["value"]], expected_default),
    identical(prepared_default[["DF"]][["variable"]], rep(variable_label, 3)),
    identical(prepared_default[["DT"]][["variable"]], rep(variable_label, 3)),
    identical(prepared_default[["TB"]][["variable"]], rep(variable_label, 3))
  )

  prepared_custom <- lapply(
    X = testdata,
    FUN = function(x) do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, tie.breaker = min, verbose = FALSE))
  )
  prepared_custom <- lapply(prepared_custom, sort_prepared)

  stopifnot(
    identical(prepared_custom[["DF"]][["value"]], expected_custom),
    identical(prepared_custom[["DT"]][["value"]], expected_custom),
    identical(prepared_custom[["TB"]][["value"]], expected_custom)
  )

  prepared_custom_range <- lapply(
    X = testdata,
    FUN = function(x) do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, valid.range = custom_valid_range, verbose = FALSE))
  )
  prepared_custom_range <- lapply(prepared_custom_range, sort_prepared)

  stopifnot(
    identical(prepared_custom_range[["DF"]][["value"]], expected_default),
    identical(prepared_custom_range[["DT"]][["value"]], expected_default),
    identical(prepared_custom_range[["TB"]][["value"]], expected_default)
  )
}

run_range_case("prepare_bilirubin", "BILIRUBIN", "bilirubin_value", c(3.2, 4.0, 4.3, 3.5), c(4.0, 4.3, 3.5), c(3.2, 4.3, 3.5), c(0, 20))
run_range_case("prepare_alt", "ALT", "alt_value", c(99, 102, 106, 110), c(102, 106, 110), c(99, 106, 110), c(0, 1000))

################################################################################
#                                 End of File                                  #
################################################################################
