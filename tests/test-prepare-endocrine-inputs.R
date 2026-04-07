library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-endocrine-inputs.R
#
# Phoenix-8 endocrine preparation currently consists of glucose.  This wrapper
# is range-based, so the main questions are:
#   - are values validated against valid.range?
#   - are duplicate rows reduced via tie.breaker?
#   - is the prepared output standardized across data.frame, data.table, and
#     tibble?
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
    identical(prepared_default[["TB"]][["variable"]], rep(variable_label, 3)),
    identical(attr(prepared_default[["DF"]], "id.vars"), id.vars),
    identical(attr(prepared_default[["DT"]], "id.vars"), id.vars),
    identical(attr(prepared_default[["TB"]], "id.vars"), id.vars),
    identical(attr(prepared_default[["DF"]], "eclock"), eclock),
    identical(attr(prepared_default[["DT"]], "eclock"), eclock),
    identical(attr(prepared_default[["TB"]], "eclock"), eclock)
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

  test_missing <- lapply(
    X = make_backends(phoenix:::phxdft_set(df, i = 1L, j = value.var, value = NA_real_)),
    FUN = function(x) tryCatch(do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, verbose = FALSE)), error = function(e) e)
  )
  stopifnot(
    sapply(test_missing, inherits, "error"),
    sapply(sapply(test_missing, getElement, "message"), grepl, pattern = "non-missing")
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

  test_zero_row <- lapply(
    X = make_backends(df[0, ]),
    FUN = function(x) do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, verbose = FALSE))
  )
  stopifnot(
    identical(nrow(test_zero_row[["DF"]]), 0L),
    identical(nrow(test_zero_row[["DT"]]), 0L),
    identical(nrow(test_zero_row[["TB"]]), 0L),
    identical(test_zero_row[["DF"]][["variable"]], character(0)),
    identical(test_zero_row[["DT"]][["variable"]], character(0)),
    identical(test_zero_row[["TB"]][["variable"]], character(0))
  )
}

run_range_case("prepare_glucose", "GLUCOSE", "glucose_value", c(80, 110, 95, 120), c(110, 95, 120), c(80, 95, 120), c(0, 300))

################################################################################
#                                 End of File                                  #
################################################################################
