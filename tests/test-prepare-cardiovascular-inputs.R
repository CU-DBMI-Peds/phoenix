library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-cardiovascular-inputs.R
#
# This script groups the preparation tests for cardiovascular Phoenix inputs.
# The family includes both:
#   - continuous/range-based values such as lactate and blood pressures
#   - discrete vasoactive medication indicators
#
# The purpose of the script is to show that each wrapper obeys the common
# preparation contract:
#   - check source-column type and allowed values
#   - reduce duplicate rows at one encounter clock
#   - return a standardized prepared object
#   - behave the same across supported input backends
################################################################################

# Build the three supported backends from one test fixture.
make_backends <- function(x) {
  list(
    DF = x,
    DT = as_data_table_if_available(x),
    TB = as_tibble_if_available(x)
  )
}

# Sort prepared output by encounter clock so that backend-specific row ordering
# does not create false failures in the value checks.
sort_prepared <- function(x) {
  x[order(x[["minutes_from_admission"]]), ]
}

# Generic test driver for continuous/range-based cardiovascular inputs.
#
# The synthetic data intentionally include one duplicated encounter time.  This
# lets the test exercise the default tie.breaker and a custom tie.breaker while
# keeping the example compact.
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

  test_bad_type_df <- df
  test_bad_type_df[[value.var]] <- as.character(test_bad_type_df[[value.var]])
  test_bad_type <- lapply(
    X = make_backends(test_bad_type_df),
    FUN = function(x) tryCatch(do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, verbose = FALSE)), error = function(e) e)
  )
  stopifnot(
    sapply(test_bad_type, inherits, "error"),
    sapply(sapply(test_bad_type, getElement, "message"), grepl, pattern = "numeric or integer")
  )
}

# Generic test driver for discrete cardiovascular indicators.
#
# These wrappers enforce a fixed allowable set internally, so the main questions
# are whether invalid indicator values are rejected and whether the prepared
# output is integer-valued after normalization.
run_indicator_case <- function(fun_name, variable_label, value.var) {
  id.vars <- c("hospital", "patient", "encounter")
  eclock <- "minutes_from_admission"
  FUN <- get(fun_name, mode = "function")

  df <- data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 0, 60, 120),
    value = c(0, 1, 0, 1),
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
    identical(prepared_default[["DF"]][["value"]], c(1L, 0L, 1L)),
    identical(prepared_default[["DT"]][["value"]], c(1L, 0L, 1L)),
    identical(prepared_default[["TB"]][["value"]], c(1L, 0L, 1L)),
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
    identical(prepared_custom[["DF"]][["value"]], c(0L, 0L, 1L)),
    identical(prepared_custom[["DT"]][["value"]], c(0L, 0L, 1L)),
    identical(prepared_custom[["TB"]][["value"]], c(0L, 0L, 1L))
  )

  test_invalid <- lapply(
    X = make_backends(phoenix:::phxdft_set(df, i = 1L, j = value.var, value = 2)),
    FUN = function(x) tryCatch(do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, verbose = FALSE)), error = function(e) e)
  )
  stopifnot(
    sapply(test_invalid, inherits, "error"),
    sapply(sapply(test_invalid, getElement, "message"), grepl, pattern = "not in `valid.values`")
  )
}

################################################################################
# Family-Wise Cardiovascular Coverage
#
# One explicit call per wrapper keeps the script easy to read for someone who
# knows the Phoenix inputs and wants to see how each one is being prepared.
################################################################################

run_range_case("prepare_lactate", "LACTATE", "lactate_value", c(5, 8, 6, 7), c(8, 6, 7), c(5, 6, 7), c(0, 20))
run_range_case("prepare_sbpc", "SBPC", "systolic_blood_pressure_cuff", c(80, 90, 100, 110), c(90, 100, 110), c(80, 100, 110), c(50, 150))
run_range_case("prepare_sbpa", "SBPA", "systolic_blood_pressure_arterial", c(85, 95, 105, 115), c(95, 105, 115), c(85, 105, 115), c(50, 150))
run_range_case("prepare_dbpc", "DBPC", "diastolic_blood_pressure_cuff", c(40, 50, 55, 60), c(50, 55, 60), c(40, 55, 60), c(20, 100))
run_range_case("prepare_dbpa", "DBPA", "diastolic_blood_pressure_arterial", c(45, 55, 60, 65), c(55, 60, 65), c(45, 60, 65), c(20, 100))
run_range_case("prepare_mapc", "MAPC", "mean_arterial_pressure_cuff", c(55, 65, 70, 75), c(65, 70, 75), c(55, 70, 75), c(20, 120))
run_range_case("prepare_mapa", "MAPA", "mean_arterial_pressure_arterial", c(60, 70, 75, 80), c(70, 75, 80), c(60, 75, 80), c(20, 120))

run_indicator_case("prepare_dobutamine", "DOBUTAMINE", "dobutamine_indicator")
run_indicator_case("prepare_dopamine", "DOPAMINE", "dopamine_indicator")
run_indicator_case("prepare_epinephrine", "EPINEPHRINE", "epinephrine_indicator")
run_indicator_case("prepare_milrinone", "MILRINONE", "milrinone_indicator")
run_indicator_case("prepare_norepinephrine", "NOREPINEPHRINE", "norepinephrine_indicator")
run_indicator_case("prepare_vasopressin", "VASOPRESSIN", "vasopressin_indicator")

################################################################################
#                                 End of File                                  #
################################################################################
