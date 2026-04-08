library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-neurologic-inputs.R
#
# This script groups the neurologic preparation tests for Phoenix:
#   - GCS eye, motor, verbal, and total
#   - pupil status variables
#
# These are all discrete inputs with fixed allowable values.  End users are not
# expected to change those allowable values, so the main checks here are:
#   - invalid values are rejected
#   - duplicate rows reduce via tie.breaker
#   - prepared outputs are integer-valued
#   - factor input is rejected
#   - zero-row inputs still return a valid prepared object
################################################################################

# Generic test driver for discrete neurologic wrappers.
#
# The data set is intentionally small but includes one duplicated encounter time
# so the effect of tie.breaker is visible.
run_discrete_case <- function(fun_name,
                              variable_label,
                              value.var,
                              valid_values,
                              expected_default,
                              expected_custom) {
  id.vars <- c("hospital", "patient", "encounter")
  eclock <- "minutes_from_admission"
  FUN <- get(fun_name, mode = "function")

  df <- data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 0, 60, 120),
    value = as.numeric(c(valid_values[1], valid_values[2], valid_values[length(valid_values) - 1], valid_values[length(valid_values)])),
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
    is.integer(prepared_default[["DF"]][["value"]]),
    is.integer(prepared_default[["DT"]][["value"]]),
    is.integer(prepared_default[["TB"]][["value"]]),
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

  test_invalid <- lapply(
    X = make_backends(phoenix:::phxdft_set(df, i = 1L, j = value.var, value = max(valid_values) + 1)),
    FUN = function(x) tryCatch(do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, verbose = FALSE)), error = function(e) e)
  )
  stopifnot(
    sapply(test_invalid, inherits, "error"),
    sapply(sapply(test_invalid, getElement, "message"), grepl, pattern = "not in `valid.values`")
  )

  test_bad_type_df <- df
  test_bad_type_df[[value.var]] <- factor(test_bad_type_df[[value.var]])
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

################################################################################
# Family-Wise Neurologic Coverage
################################################################################

run_discrete_case("prepare_gcseye", "GCSEYE", "gcs_eye_score", c(1, 2, 3, 4), c(2L, 3L, 4L), c(1L, 3L, 4L))
run_discrete_case("prepare_gcsmotor", "GCSMOTOR", "gcs_motor_score", c(1, 2, 3, 4, 5, 6), c(2L, 5L, 6L), c(1L, 5L, 6L))
run_discrete_case("prepare_gcsverbal", "GCSVERBAL", "gcs_verbal_score", c(1, 2, 3, 4, 5), c(2L, 4L, 5L), c(1L, 4L, 5L))
run_discrete_case("prepare_gcstotal", "GCSTOTAL", "gcs_total_score", c(3:15), c(4L, 14L, 15L), c(3L, 14L, 15L))
run_discrete_case("prepare_pupilleft", "PUPILLEFT", "left_pupil_fixed", c(0, 1), c(1L, 0L, 1L), c(0L, 0L, 1L))
run_discrete_case("prepare_pupilright", "PUPILRIGHT", "right_pupil_fixed", c(0, 1), c(1L, 0L, 1L), c(0L, 0L, 1L))
run_discrete_case("prepare_pupils", "PUPILS", "any_pupil_fixed", c(0, 1), c(1L, 0L, 1L), c(0L, 0L, 1L))

################################################################################
#                                 End of File                                  #
################################################################################
