library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-respiratory-inputs.R
#
# This script groups the preparation tests for respiratory Phoenix inputs.
# Respiratory preparation is a good example of the two main patterns used in
# R/operationalize.R:
#   - continuous/range-based inputs such as FIO2, SPO2, PAO2, PEEP, and
#     ventilator-related values
#   - discrete indicator inputs such as IMV and O2 support
#
# The first part of this file uses compact helper functions to test the common
# contract across the respiratory prepare_* wrappers.  The later, more verbose
# FIO2/SPO2/IMV sections are retained because those three inputs are especially
# central to Phoenix respiratory scoring and benefit from deeper edge-case
# regression coverage.
################################################################################

# Generic driver for range-based respiratory wrappers.
#
# The synthetic data include one duplicated encounter time and two unique later
# times.  That is enough to test:
#   - default duplicate reduction
#   - a custom tie.breaker
#   - a custom valid.range
#   - missing-value rejection
#   - bad-type rejection
#   - zero-row handling
run_range_case <- function(fun_name,
                           variable_label,
                           value.var,
                           values,
                           expected_default,
                           expected_custom,
                           custom_valid_range,
                           default_tie.breaker,
                           custom_tie.breaker) {
  id.vars <- c("hospital", "patient", "encounter")
  eclock <- "minutes_from_admission"
  FUN <- get(fun_name, mode = "function")

  df <-
    data.frame(
      hospital = c("H1", "H1", "H1", "H1"),
      patient = c("P1", "P1", "P1", "P1"),
      encounter = c("E1", "E1", "E1", "E1"),
      minutes_from_admission = c(0, 0, 60, 120),
      value = values,
      stringsAsFactors = FALSE
    )
  names(df)[names(df) == "value"] <- value.var
  testdata <- make_backends(df)

  prepared_default <-
    lapply(
      X = testdata,
      FUN = function(x) {
        do.call(
          FUN,
          list(
            x = x,
            id.vars = id.vars,
            eclock = eclock,
            value.var = value.var,
            verbose = FALSE
          )
        )
      }
    )

  stopifnot(
    identical(sapply(prepared_default, inherits, "data.frame"), c(DF = TRUE, DT = TRUE, TB = TRUE)),
    identical(sapply(prepared_default, inherits, paste0("phoenix_prepared_", sub("^prepare_", "", fun_name))), c(DF = TRUE, DT = TRUE, TB = TRUE))
  )

  prepared_default <- lapply(prepared_default, sort_prepared)
  stopifnot(
    identical(prepared_default[["DF"]][["minutes_from_admission"]], c(0, 60, 120)),
    identical(prepared_default[["DT"]][["minutes_from_admission"]], c(0, 60, 120)),
    identical(prepared_default[["TB"]][["minutes_from_admission"]], c(0, 60, 120)),
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

  prepared_custom <-
    lapply(
      X = testdata,
      FUN = function(x) {
        do.call(
          FUN,
          list(
            x = x,
            id.vars = id.vars,
            eclock = eclock,
            value.var = value.var,
            tie.breaker = custom_tie.breaker,
            verbose = FALSE
          )
        )
      }
    )

  prepared_custom <- lapply(prepared_custom, sort_prepared)
  stopifnot(
    identical(prepared_custom[["DF"]][["value"]], expected_custom),
    identical(prepared_custom[["DT"]][["value"]], expected_custom),
    identical(prepared_custom[["TB"]][["value"]], expected_custom)
  )

  prepared_custom_range <-
    lapply(
      X = testdata,
      FUN = function(x) {
        do.call(
          FUN,
          list(
            x = x,
            id.vars = id.vars,
            eclock = eclock,
            value.var = value.var,
            valid.range = custom_valid_range,
            verbose = FALSE
          )
        )
      }
    )

  prepared_custom_range <- lapply(prepared_custom_range, sort_prepared)
  stopifnot(
    identical(prepared_custom_range[["DF"]][["value"]], expected_default),
    identical(prepared_custom_range[["DT"]][["value"]], expected_default),
    identical(prepared_custom_range[["TB"]][["value"]], expected_default)
  )

  test_missing <-
    lapply(
      X = make_backends(phoenix:::phxdft_set(df, i = 1L, j = value.var, value = NA_real_)),
      FUN = function(x) {
        tryCatch(
          do.call(
            FUN,
            list(
              x = x,
              id.vars = id.vars,
              eclock = eclock,
              value.var = value.var,
              verbose = FALSE
            )
          ),
          error = function(e) e
        )
      }
    )
  stopifnot(
    sapply(test_missing, inherits, "error"),
    sapply(sapply(test_missing, getElement, "message"), grepl, pattern = "non-missing")
  )

  test_bad_type_df <- df
  test_bad_type_df[[value.var]] <- as.character(test_bad_type_df[[value.var]])
  test_bad_type <-
    lapply(
      X = make_backends(test_bad_type_df),
      FUN = function(x) {
        tryCatch(
          do.call(
            FUN,
            list(
              x = x,
              id.vars = id.vars,
              eclock = eclock,
              value.var = value.var,
              verbose = FALSE
            )
          ),
          error = function(e) e
        )
      }
    )
  stopifnot(
    sapply(test_bad_type, inherits, "error"),
    sapply(sapply(test_bad_type, getElement, "message"), grepl, pattern = "numeric or integer")
  )

  test_zero_row_df <- df[0, ]
  test_zero_row <-
    lapply(
      X = make_backends(test_zero_row_df),
      FUN = function(x) {
        do.call(
          FUN,
          list(
            x = x,
            id.vars = id.vars,
            eclock = eclock,
            value.var = value.var,
            verbose = FALSE
          )
        )
      }
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

# Generic driver for discrete respiratory wrappers.
#
# These wrappers do not expose valid.values to the caller.  Instead, the wrapper
# itself defines the allowed values and the prepared output is expected to be
# integer-valued.
run_discrete_case <- function(fun_name,
                              variable_label,
                              value.var,
                              valid_values,
                              default_tie.breaker,
                              custom_tie.breaker,
                              expected_default,
                              expected_custom) {
  id.vars <- c("hospital", "patient", "encounter")
  eclock <- "minutes_from_admission"
  FUN <- get(fun_name, mode = "function")

  df <-
    data.frame(
      hospital = c("H1", "H1", "H1", "H1"),
      patient = c("P1", "P1", "P1", "P1"),
      encounter = c("E1", "E1", "E1", "E1"),
      minutes_from_admission = c(0, 0, 60, 120),
      value = as.numeric(c(valid_values[1], valid_values[2], valid_values[1], valid_values[2])),
      stringsAsFactors = FALSE
    )
  names(df)[names(df) == "value"] <- value.var
  testdata <- make_backends(df)

  prepared_default <-
    lapply(
      X = testdata,
      FUN = function(x) {
        do.call(
          FUN,
          list(
            x = x,
            id.vars = id.vars,
            eclock = eclock,
            value.var = value.var,
            verbose = FALSE
          )
        )
      }
    )

  prepared_default <- lapply(prepared_default, sort_prepared)
  stopifnot(
    identical(prepared_default[["DF"]][["value"]], expected_default),
    identical(prepared_default[["DT"]][["value"]], expected_default),
    identical(prepared_default[["TB"]][["value"]], expected_default),
    identical(prepared_default[["DF"]][["variable"]], rep(variable_label, 3)),
    identical(prepared_default[["DT"]][["variable"]], rep(variable_label, 3)),
    identical(prepared_default[["TB"]][["variable"]], rep(variable_label, 3)),
    is.integer(prepared_default[["DF"]][["value"]]),
    is.integer(prepared_default[["DT"]][["value"]]),
    is.integer(prepared_default[["TB"]][["value"]])
  )

  prepared_custom <-
    lapply(
      X = testdata,
      FUN = function(x) {
        do.call(
          FUN,
          list(
            x = x,
            id.vars = id.vars,
            eclock = eclock,
            value.var = value.var,
            tie.breaker = custom_tie.breaker,
            verbose = FALSE
          )
        )
      }
    )
  prepared_custom <- lapply(prepared_custom, sort_prepared)
  stopifnot(
    identical(prepared_custom[["DF"]][["value"]], expected_custom),
    identical(prepared_custom[["DT"]][["value"]], expected_custom),
    identical(prepared_custom[["TB"]][["value"]], expected_custom)
  )

  invalid_value <- max(valid_values) + 1
  test_invalid <- lapply(
    X = make_backends(phoenix:::phxdft_set(df, i = 1L, j = value.var, value = invalid_value)),
    FUN = function(x) {
      tryCatch(
        do.call(
          FUN,
          list(
            x = x,
            id.vars = id.vars,
            eclock = eclock,
            value.var = value.var,
            verbose = FALSE
          )
        ),
        error = function(e) e
      )
    }
  )
  stopifnot(
    sapply(test_invalid, inherits, "error"),
    sapply(sapply(test_invalid, getElement, "message"), grepl, pattern = "not in `valid.values`")
  )

  test_factor_df <- df
  test_factor_df[[value.var]] <- factor(test_factor_df[[value.var]])
  test_factor <-
    lapply(
      X = make_backends(test_factor_df),
      FUN = function(x) {
        tryCatch(
          do.call(
            FUN,
            list(
              x = x,
              id.vars = id.vars,
              eclock = eclock,
              value.var = value.var,
              verbose = FALSE
            )
          ),
          error = function(e) e
        )
      }
    )
  stopifnot(
    sapply(test_factor, inherits, "error"),
    sapply(sapply(test_factor, getElement, "message"), grepl, pattern = "numeric or integer")
  )
}

################################################################################
# Family-Wise Respiratory Coverage
#
# Each call below corresponds to one respiratory prepare_* wrapper.  The
# expected reduced values are written explicitly so someone familiar with the
# Phoenix inputs can see how duplicate rows are intended to collapse.
################################################################################

run_range_case(
  fun_name = "prepare_fio2",
  variable_label = "FIO2",
  value.var = "fraction_inspired_oxygen",
  values = c(0.21, 0.40, 0.30, 0.50),
  expected_default = c(0.40, 0.30, 0.50),
  expected_custom = c(0.21, 0.30, 0.50),
  custom_valid_range = c(0.20, 0.60),
  default_tie.breaker = max,
  custom_tie.breaker = min
)

run_range_case(
  fun_name = "prepare_spo2",
  variable_label = "SPO2",
  value.var = "oxygen_saturation",
  values = c(97, 92, 95, 90),
  expected_default = c(92, 95, 90),
  expected_custom = c(97, 95, 90),
  custom_valid_range = c(85, 100),
  default_tie.breaker = min,
  custom_tie.breaker = max
)

run_discrete_case(
  fun_name = "prepare_imv",
  variable_label = "IMV",
  value.var = "invasive_mechanical_ventilation",
  valid_values = c(0, 1),
  default_tie.breaker = max,
  custom_tie.breaker = min,
  expected_default = c(1L, 0L, 1L),
  expected_custom = c(0L, 0L, 1L)
)

run_range_case(
  fun_name = "prepare_pao2",
  variable_label = "PAO2",
  value.var = "partial_pressure_arterial_oxygen",
  values = c(80, 70, 65, 60),
  expected_default = c(70, 65, 60),
  expected_custom = c(80, 65, 60),
  custom_valid_range = c(50, 120),
  default_tie.breaker = min,
  custom_tie.breaker = max
)

run_range_case(
  fun_name = "prepare_vent",
  variable_label = "VENT",
  value.var = "ventilator_setting",
  values = c(5, 10, 8, 7),
  expected_default = c(10, 8, 7),
  expected_custom = c(5, 8, 7),
  custom_valid_range = c(0, 20),
  default_tie.breaker = max,
  custom_tie.breaker = min
)

run_range_case(
  fun_name = "prepare_hfov",
  variable_label = "HFOV",
  value.var = "high_frequency_oscillation",
  values = c(0, 1, 0, 1),
  expected_default = c(1, 0, 1),
  expected_custom = c(0, 0, 1),
  custom_valid_range = c(0, 2),
  default_tie.breaker = max,
  custom_tie.breaker = min
)

run_range_case(
  fun_name = "prepare_peep",
  variable_label = "PEEP",
  value.var = "positive_end_expiratory_pressure",
  values = c(5, 8, 6, 10),
  expected_default = c(8, 6, 10),
  expected_custom = c(5, 6, 10),
  custom_valid_range = c(0, 20),
  default_tie.breaker = max,
  custom_tie.breaker = min
)

run_discrete_case(
  fun_name = "prepare_o2support",
  variable_label = "O2SUPPORT",
  value.var = "other_respiratory_support",
  valid_values = c(0, 1),
  default_tie.breaker = max,
  custom_tie.breaker = min,
  expected_default = c(1L, 0L, 1L),
  expected_custom = c(0L, 0L, 1L)
)

################################################################################
# Detailed Respiratory Regression Sections
#
# The earlier, more explicit FIO2, SPO2, and IMV test bodies are retained below.
# They overlap with the compact family-wise coverage above, but they also serve
# as detailed documentation of the expected preparation behavior for the most
# central respiratory inputs.
################################################################################

# Default valid range checks 0.21 to 1.00
testdata <- list()
testdata[["DF"]] <-
  data.frame(
    hospital = c("H1"),
    patient = c("P1"),
    encounter = c(rep("E1", 4), rep("E2", 2)),
    minutes_from_admission = c(1:3, 3, -1, 200),
    percent_inspired_oxygen = c(NA, -0.3, 21, 0.21, 0.3, 0.4),
    stringsAsFactors = FALSE
  )
testdata[["DT"]] <- as_data_table_if_available(testdata[["DF"]])
testdata[["TB"]] <- as_tibble_if_available(testdata[["DF"]])

# Error due to the presence of a missing value
test_missing_value <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "percent_inspired_oxygen"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_missing_value, inherits, "error"),
  sapply(sapply(test_missing_value, getElement, "message"), grepl, pattern = "non-missing")
)

# now update the missing value to a valid value
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = 1L,
    j = "percent_inspired_oxygen",
    value = 0.21
  )

# Error due to the presence of a values outside the valid range - there are
# values too large and too small
test_values_outside_value_range <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "percent_inspired_oxygen"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_values_outside_value_range, inherits, "error"),
  sapply(sapply(test_values_outside_value_range, getElement, "message"), grepl, pattern = " < 0\\.21.*1\\.0")
)

# now update the low value to a valid one and test for the upper issue only
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(2L),
    j = "percent_inspired_oxygen",
    value = c(0.31)
  )

test_values_above_value_range <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "percent_inspired_oxygen"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(sapply(test_values_above_value_range, inherits, "error"))
msgs <- sapply(test_values_above_value_range, getElement, "message")
stopifnot(
  sapply(msgs, grepl, pattern = "> 1\\.0", perl = TRUE),
  !sapply(msgs, grepl, pattern = "< 0.21", perl = TRUE)
)

# now update the high value to a low value so now we can test just the below
# range value
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(3L),
    j = "percent_inspired_oxygen",
    value = c(0.20)
  )

test_values_below_value_range <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "percent_inspired_oxygen"
        ),
        error = function(e) e
      )
    }
  )

msgs <- sapply(test_values_below_value_range, getElement, "message")
stopifnot(
  !sapply(msgs, grepl, pattern = "> 1\\.0", perl = TRUE),
  sapply(msgs, grepl, pattern = "< 0.21", perl = TRUE)
)

# now update the low value to a valid value for testing output from "valid"
# data.
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(3L),
    j = "percent_inspired_oxygen",
    value = c(0.42)
  )

# because data.table can be used, we want to make sure we don't mutate the
# user's input.  Get the sha265 for the input data and verify that it has not
# changed after applying prepare_fio2
testdata_sha <- digest::digest(testdata, algo = "sha256")

# and test for expected outputs
test_prepared_data <-
  lapply(
    X = testdata,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "percent_inspired_oxygen"
      )
    }
  )

stopifnot(testdata_sha == digest::digest(testdata, algo = "sha256"))

stopifnot(
  identical(
    sapply(test_prepared_data, inherits, "data.frame"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "data.table"),
    c("DF" = FALSE, "DT" = inherits(testdata[["DT"]], "data.table"), "TB" = FALSE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "tbl_df"),
    c("DF" = FALSE, "DT" = FALSE, "TB" = inherits(testdata[["TB"]], "tbl_df"))
  ),
  identical(names(test_prepared_data[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_data[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_data[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(test_prepared_data[["DF"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["DT"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["TB"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["DF"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["DT"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["TB"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["DF"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["DT"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["TB"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["DF"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["DT"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["TB"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["DF"]][["value"]], c(0.21, 0.31, 0.3, 0.4, 0.42)),
  identical(test_prepared_data[["DT"]][["value"]], c(0.21, 0.31, 0.3, 0.4, 0.42)),
  identical(test_prepared_data[["TB"]][["value"]], c(0.21, 0.31, 0.3, 0.4, 0.42)),
  identical(test_prepared_data[["DF"]][["variable"]], rep("FIO2", 5)),
  identical(test_prepared_data[["DT"]][["variable"]], rep("FIO2", 5)),
  identical(test_prepared_data[["TB"]][["variable"]], rep("FIO2", 5))
)

# the output from test_prepared_data could be "prepared" again, with no
# difference save the class attribute being longer in the reprocessed data.
# NOTE: the `value.var` arguement does need to be updated for the call.
test_prepared_data2 <-
  lapply(
    X = test_prepared_data,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "value"
      )
    }
  )
stopifnot(
  all.equal(test_prepared_data, test_prepared_data2, check.attributes = FALSE)
)

################################################################################
# Explicit class and attribute checks for prepared outputs
stopifnot(
  identical(
    sapply(test_prepared_data, inherits, "phoenix_prepared"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "phoenix_prepared_fio2"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(attr(test_prepared_data[["DF"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["DT"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["TB"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["DF"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_data[["DT"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_data[["TB"]], "eclock"), "minutes_from_admission")
)

################################################################################
# No duplicates path
testdata_no_dups <- list()
testdata_no_dups[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    percent_inspired_oxygen = c(0.21, 0.30, 0.40),
    stringsAsFactors = FALSE
  )
testdata_no_dups[["DT"]] <- as_data_table_if_available(testdata_no_dups[["DF"]])
testdata_no_dups[["TB"]] <- as_tibble_if_available(testdata_no_dups[["DF"]])

test_prepared_no_dups <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "percent_inspired_oxygen",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_prepared_no_dups[["DF"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["DT"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["TB"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["DF"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_prepared_no_dups[["DT"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_prepared_no_dups[["TB"]][["value"]], c(0.21, 0.30, 0.40))
)

################################################################################
# All duplicates path and custom tie.breaker across all backends
testdata_all_dups <- list()
testdata_all_dups[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 0, 60, 60),
    percent_inspired_oxygen = c(0.21, 0.40, 0.30, 0.50),
    stringsAsFactors = FALSE
  )
testdata_all_dups[["DT"]] <- as_data_table_if_available(testdata_all_dups[["DF"]])
testdata_all_dups[["TB"]] <- as_tibble_if_available(testdata_all_dups[["DF"]])

test_prepared_all_dups_max <-
  lapply(
    X = testdata_all_dups,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "percent_inspired_oxygen",
        tie.breaker = max,
        verbose = FALSE
      )
    }
  )

test_prepared_all_dups_min <-
  lapply(
    X = testdata_all_dups,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "percent_inspired_oxygen",
        tie.breaker = min,
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_prepared_all_dups_max[["DF"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["DT"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["TB"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["DF"]][["value"]], c(0.40, 0.50)),
  identical(test_prepared_all_dups_max[["DT"]][["value"]], c(0.40, 0.50)),
  identical(test_prepared_all_dups_max[["TB"]][["value"]], c(0.40, 0.50)),
  identical(test_prepared_all_dups_min[["DF"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["DT"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["TB"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["DF"]][["value"]], c(0.21, 0.30)),
  identical(test_prepared_all_dups_min[["DT"]][["value"]], c(0.21, 0.30)),
  identical(test_prepared_all_dups_min[["TB"]][["value"]], c(0.21, 0.30))
)

################################################################################
# custom valid.range support
test_custom_valid_range <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "percent_inspired_oxygen",
        valid.range = c(0.20, 0.50),
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_custom_valid_range[["DF"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_custom_valid_range[["DT"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_custom_valid_range[["TB"]][["value"]], c(0.21, 0.30, 0.40))
)

################################################################################
# id.vars validation
test_bad_id_vars <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "missing_id"),
          eclock = "minutes_from_admission",
          value.var = "percent_inspired_oxygen",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_id_vars, inherits, "error"),
  sapply(sapply(test_bad_id_vars, getElement, "message"), grepl, pattern = "missing_id")
)

################################################################################
# eclock validation: missing column and non-numeric column
test_bad_eclock_missing <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "missing_eclock",
          value.var = "percent_inspired_oxygen",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_eclock_missing, inherits, "error"),
  sapply(sapply(test_bad_eclock_missing, getElement, "message"), grepl, pattern = "missing_eclock")
)

testdata_bad_eclock <- list()
testdata_bad_eclock[["DF"]] <- testdata_no_dups[["DF"]]
testdata_bad_eclock[["DT"]] <- testdata_no_dups[["DT"]]
testdata_bad_eclock[["TB"]] <- testdata_no_dups[["TB"]]

testdata_bad_eclock <-
  lapply(
    X = testdata_bad_eclock,
    FUN = phoenix:::phxdft_set,
    j = "minutes_from_admission",
    value = c("0", "60", "10")
  )

test_bad_eclock_type <-
  lapply(
    X = testdata_bad_eclock,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "percent_inspired_oxygen",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_eclock_type, inherits, "error"),
  sapply(sapply(test_bad_eclock_type, getElement, "message"), grepl, pattern = "numeric vector")
)

################################################################################
# value.var validation: missing column and already named value
test_bad_value_var <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "missing_value_var",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_value_var, inherits, "error")
)

testdata_value_var <- list()
testdata_value_var[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    value = c(0.21, 0.30, 0.40),
    stringsAsFactors = FALSE
  )
testdata_value_var[["DT"]] <- testdata_value_var[["DF"]]
testdata_value_var[["TB"]] <- testdata_value_var[["DF"]]

if (requireNamespace("data.table", quietly = TRUE)) {
  testdata_value_var[["DT"]] <- getExportedValue(ns = "data.table", name = "as.data.table")(testdata_value_var[["DT"]])
}

if (requireNamespace("dplyr", quietly = TRUE)) {
  testdata_value_var[["TB"]] <- getExportedValue(ns = "dplyr", name = "as_tibble")(testdata_value_var[["TB"]])
}

test_prepared_value_var <-
  lapply(
    X = testdata_value_var,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "value",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(names(test_prepared_value_var[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_value_var[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_value_var[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(test_prepared_value_var[["DF"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_prepared_value_var[["DT"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_prepared_value_var[["TB"]][["value"]], c(0.21, 0.30, 0.40))
)

################################################################################
# Zero-row input
testdata_zero_row <- list()
testdata_zero_row[["DF"]] <-
  data.frame(
    hospital = character(0),
    patient = character(0),
    encounter = character(0),
    minutes_from_admission = numeric(0),
    percent_inspired_oxygen = numeric(0),
    stringsAsFactors = FALSE
  )
testdata_zero_row[["DT"]] <- as_data_table_if_available(testdata_zero_row[["DF"]])
testdata_zero_row[["TB"]] <- as_tibble_if_available(testdata_zero_row[["DF"]])

test_prepared_zero_row <-
  lapply(
    X = testdata_zero_row,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "percent_inspired_oxygen",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(nrow(test_prepared_zero_row[["DF"]]), 0L),
  identical(nrow(test_prepared_zero_row[["DT"]]), 0L),
  identical(nrow(test_prepared_zero_row[["TB"]]), 0L),
  identical(names(test_prepared_zero_row[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_zero_row[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_zero_row[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(attr(test_prepared_zero_row[["DF"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["DT"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["TB"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["DF"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_zero_row[["DT"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_zero_row[["TB"]], "eclock"), "minutes_from_admission"),
  identical(test_prepared_zero_row[["DF"]][["variable"]], character(0)),
  identical(test_prepared_zero_row[["DT"]][["variable"]], character(0)),
  identical(test_prepared_zero_row[["TB"]][["variable"]], character(0))
)

################################################################################
#                                 End of File                                  #
################################################################################



################################################################################
# Defaut valid range checks 0 to 100
testdata <- list()
testdata[["DF"]] <-
  data.frame(
    hospital = c("H1"),
    patient = c("P1"),
    encounter = c(rep("E1", 4), rep("E2", 2)),
    minutes_from_admission = c(1:3, 3, -1, 200),
    oxygen_saturation = c(NA, -3, 101, 98, 95, 90),
    stringsAsFactors = FALSE
  )
testdata[["DT"]] <- as_data_table_if_available(testdata[["DF"]])
testdata[["TB"]] <- as_tibble_if_available(testdata[["DF"]])

# Error due to the presence of a missing value
test_missing_value <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "oxygen_saturation"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_missing_value, inherits, "error"),
  sapply(sapply(test_missing_value, getElement, "message"), grepl, pattern = "non-missing")
)

# now update the missing value to a valid value
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = 1L,
    j = "oxygen_saturation",
    value = 97
  )

# Error due to the presence of values outside the valid range - there are
# values too large and too small
test_values_outside_value_range <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "oxygen_saturation"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_values_outside_value_range, inherits, "error"),
  sapply(sapply(test_values_outside_value_range, getElement, "message"), grepl, pattern = " < 0\\.0+.*100\\.0+")
)

# now update the low value to a valid one and test for the upper issue only
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(2L),
    j = "oxygen_saturation",
    value = c(93)
  )

test_values_above_value_range <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "oxygen_saturation"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(sapply(test_values_above_value_range, inherits, "error"))
msgs <- sapply(test_values_above_value_range, getElement, "message")
stopifnot(
  sapply(msgs, grepl, pattern = "> 100\\.0", perl = TRUE),
  !sapply(msgs, grepl, pattern = "< 0\\.0", perl = TRUE)
)

# now update the high value to a low value so now we can test just the below
# range value
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(3L),
    j = "oxygen_saturation",
    value = c(-1)
  )

test_values_below_value_range <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "oxygen_saturation"
        ),
        error = function(e) e
      )
    }
  )

msgs <- sapply(test_values_below_value_range, getElement, "message")
stopifnot(
  !sapply(msgs, grepl, pattern = "> 100\\.0", perl = TRUE),
  sapply(msgs, grepl, pattern = "< 0\\.0", perl = TRUE)
)

# now update the low value to a valid value for testing output from "valid"
# data.
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(3L),
    j = "oxygen_saturation",
    value = c(96)
  )

# because data.table can be used, we want to make sure we don't mutate the
# user's input.  Get the sha265 for the input data and verify that it has not
# changed after applying prepare_spo2
testdata_sha <- digest::digest(testdata, algo = "sha256")

# and test for expected outputs
test_prepared_data <-
  lapply(
    X = testdata,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "oxygen_saturation"
      )
    }
  )

stopifnot(testdata_sha == digest::digest(testdata, algo = "sha256"))

stopifnot(
  identical(
    sapply(test_prepared_data, inherits, "data.frame"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "data.table"),
    c("DF" = FALSE, "DT" = inherits(testdata[["DT"]], "data.table"), "TB" = FALSE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "tbl_df"),
    c("DF" = FALSE, "DT" = FALSE, "TB" = inherits(testdata[["TB"]], "tbl_df"))
  ),
  identical(names(test_prepared_data[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_data[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_data[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(test_prepared_data[["DF"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["DT"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["TB"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["DF"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["DT"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["TB"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["DF"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["DT"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["TB"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["DF"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["DT"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["TB"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["DF"]][["value"]], c(97, 93, 95, 90, 96)),
  identical(test_prepared_data[["DT"]][["value"]], c(97, 93, 95, 90, 96)),
  identical(test_prepared_data[["TB"]][["value"]], c(97, 93, 95, 90, 96)),
  identical(test_prepared_data[["DF"]][["variable"]], rep("SPO2", 5)),
  identical(test_prepared_data[["DT"]][["variable"]], rep("SPO2", 5)),
  identical(test_prepared_data[["TB"]][["variable"]], rep("SPO2", 5))
)

# the output from test_prepared_data could be "prepared" again, with no
# difference save the class attribute being longer in the reprocessed data.
# NOTE: the `value.var` arguement does need to be updated for the call.
test_prepared_data2 <-
  lapply(
    X = test_prepared_data,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "value"
      )
    }
  )
stopifnot(
  all.equal(test_prepared_data, test_prepared_data2, check.attributes = FALSE)
)

################################################################################
# Explicit class and attribute checks for prepared outputs
stopifnot(
  identical(
    sapply(test_prepared_data, inherits, "phoenix_prepared"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "phoenix_prepared_spo2"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(attr(test_prepared_data[["DF"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["DT"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["TB"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["DF"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_data[["DT"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_data[["TB"]], "eclock"), "minutes_from_admission")
)

################################################################################
# No duplicates path
testdata_no_dups <- list()
testdata_no_dups[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    oxygen_saturation = c(97, 93, 90),
    stringsAsFactors = FALSE
  )
testdata_no_dups[["DT"]] <- as_data_table_if_available(testdata_no_dups[["DF"]])
testdata_no_dups[["TB"]] <- as_tibble_if_available(testdata_no_dups[["DF"]])

test_prepared_no_dups <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "oxygen_saturation",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_prepared_no_dups[["DF"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["DT"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["TB"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["DF"]][["value"]], c(97, 93, 90)),
  identical(test_prepared_no_dups[["DT"]][["value"]], c(97, 93, 90)),
  identical(test_prepared_no_dups[["TB"]][["value"]], c(97, 93, 90))
)

################################################################################
# All duplicates path and custom tie.breaker across all backends
testdata_all_dups <- list()
testdata_all_dups[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 0, 60, 60),
    oxygen_saturation = c(97, 92, 90, 88),
    stringsAsFactors = FALSE
  )
testdata_all_dups[["DT"]] <- as_data_table_if_available(testdata_all_dups[["DF"]])
testdata_all_dups[["TB"]] <- as_tibble_if_available(testdata_all_dups[["DF"]])

test_prepared_all_dups_min <-
  lapply(
    X = testdata_all_dups,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "oxygen_saturation",
        tie.breaker = min,
        verbose = FALSE
      )
    }
  )

test_prepared_all_dups_max <-
  lapply(
    X = testdata_all_dups,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "oxygen_saturation",
        tie.breaker = max,
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_prepared_all_dups_min[["DF"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["DT"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["TB"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["DF"]][["value"]], c(92, 88)),
  identical(test_prepared_all_dups_min[["DT"]][["value"]], c(92, 88)),
  identical(test_prepared_all_dups_min[["TB"]][["value"]], c(92, 88)),
  identical(test_prepared_all_dups_max[["DF"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["DT"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["TB"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["DF"]][["value"]], c(97, 90)),
  identical(test_prepared_all_dups_max[["DT"]][["value"]], c(97, 90)),
  identical(test_prepared_all_dups_max[["TB"]][["value"]], c(97, 90))
)

################################################################################
# custom valid.range support
test_custom_valid_range <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "oxygen_saturation",
        valid.range = c(85, 100),
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_custom_valid_range[["DF"]][["value"]], c(97, 93, 90)),
  identical(test_custom_valid_range[["DT"]][["value"]], c(97, 93, 90)),
  identical(test_custom_valid_range[["TB"]][["value"]], c(97, 93, 90))
)

################################################################################
# id.vars validation
test_bad_id_vars <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "missing_id"),
          eclock = "minutes_from_admission",
          value.var = "oxygen_saturation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_id_vars, inherits, "error"),
  sapply(sapply(test_bad_id_vars, getElement, "message"), grepl, pattern = "missing_id")
)

################################################################################
# eclock validation: missing column and non-numeric column
test_bad_eclock_missing <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "missing_eclock",
          value.var = "oxygen_saturation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_eclock_missing, inherits, "error"),
  sapply(sapply(test_bad_eclock_missing, getElement, "message"), grepl, pattern = "missing_eclock")
)

testdata_bad_eclock <- list()
testdata_bad_eclock[["DF"]] <- testdata_no_dups[["DF"]]
testdata_bad_eclock[["DT"]] <- testdata_no_dups[["DT"]]
testdata_bad_eclock[["TB"]] <- testdata_no_dups[["TB"]]

testdata_bad_eclock <-
  lapply(
    X = testdata_bad_eclock,
    FUN = phoenix:::phxdft_set,
    j = "minutes_from_admission",
    value = c("0", "60", "10")
  )

test_bad_eclock_type <-
  lapply(
    X = testdata_bad_eclock,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "oxygen_saturation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_eclock_type, inherits, "error"),
  sapply(sapply(test_bad_eclock_type, getElement, "message"), grepl, pattern = "numeric vector")
)

################################################################################
# value.var validation: missing column and already named value
test_bad_value_var <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_spo2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "missing_value_var",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_value_var, inherits, "error")
)

testdata_value_var <- list()
testdata_value_var[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    value = c(97, 93, 90),
    stringsAsFactors = FALSE
  )
testdata_value_var[["DT"]] <- testdata_value_var[["DF"]]
testdata_value_var[["TB"]] <- testdata_value_var[["DF"]]

if (requireNamespace("data.table", quietly = TRUE)) {
  testdata_value_var[["DT"]] <- getExportedValue(ns = "data.table", name = "as.data.table")(testdata_value_var[["DT"]])
}

if (requireNamespace("dplyr", quietly = TRUE)) {
  testdata_value_var[["TB"]] <- getExportedValue(ns = "dplyr", name = "as_tibble")(testdata_value_var[["TB"]])
}

test_prepared_value_var <-
  lapply(
    X = testdata_value_var,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "value",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(names(test_prepared_value_var[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_value_var[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_value_var[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(test_prepared_value_var[["DF"]][["value"]], c(97, 93, 90)),
  identical(test_prepared_value_var[["DT"]][["value"]], c(97, 93, 90)),
  identical(test_prepared_value_var[["TB"]][["value"]], c(97, 93, 90))
)

################################################################################
# Zero-row input
testdata_zero_row <- list()
testdata_zero_row[["DF"]] <-
  data.frame(
    hospital = character(0),
    patient = character(0),
    encounter = character(0),
    minutes_from_admission = numeric(0),
    oxygen_saturation = numeric(0),
    stringsAsFactors = FALSE
  )
testdata_zero_row[["DT"]] <- as_data_table_if_available(testdata_zero_row[["DF"]])
testdata_zero_row[["TB"]] <- as_tibble_if_available(testdata_zero_row[["DF"]])

test_prepared_zero_row <-
  lapply(
    X = testdata_zero_row,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "oxygen_saturation",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(nrow(test_prepared_zero_row[["DF"]]), 0L),
  identical(nrow(test_prepared_zero_row[["DT"]]), 0L),
  identical(nrow(test_prepared_zero_row[["TB"]]), 0L),
  identical(names(test_prepared_zero_row[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_zero_row[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_zero_row[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(attr(test_prepared_zero_row[["DF"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["DT"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["TB"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["DF"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_zero_row[["DT"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_zero_row[["TB"]], "eclock"), "minutes_from_admission"),
  identical(test_prepared_zero_row[["DF"]][["variable"]], character(0)),
  identical(test_prepared_zero_row[["DT"]][["variable"]], character(0)),
  identical(test_prepared_zero_row[["TB"]][["variable"]], character(0))
)

################################################################################
#                                 End of File                                  #
################################################################################



################################################################################
# Default valid values checks 0 and 1
testdata <- list()
testdata[["DF"]] <-
  data.frame(
    hospital = c("H1"),
    patient = c("P1"),
    encounter = c(rep("E1", 4), rep("E2", 2)),
    minutes_from_admission = c(1:3, 3, -1, 200),
    invasive_mechanical_ventilation = c(NA, -1, 2, 0, 1, 0),
    stringsAsFactors = FALSE
  )
testdata[["DT"]] <- as_data_table_if_available(testdata[["DF"]])
testdata[["TB"]] <- as_tibble_if_available(testdata[["DF"]])

# Error due to the presence of a missing value
test_missing_value <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "invasive_mechanical_ventilation"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_missing_value, inherits, "error"),
  sapply(sapply(test_missing_value, getElement, "message"), grepl, pattern = "non-missing")
)

# now update the missing value to a valid value
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = 1L,
    j = "invasive_mechanical_ventilation",
    value = 1L
  )

# Error due to the presence of values outside the valid values
test_values_outside_valid_values <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "invasive_mechanical_ventilation"
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_values_outside_valid_values, inherits, "error"),
  sapply(sapply(test_values_outside_valid_values, getElement, "message"), grepl, pattern = "not in `valid.values`")
)

# now update the invalid values to valid ones for testing output from "valid"
# data.
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(2L, 3L),
    j = "invasive_mechanical_ventilation",
    value = c(0L, 1L)
  )

# because data.table can be used, we want to make sure we don't mutate the
# user's input.  Get the sha265 for the input data and verify that it has not
# changed after applying prepare_imv
testdata_sha <- digest::digest(testdata, algo = "sha256")

# and test for expected outputs
test_prepared_data <-
  lapply(
    X = testdata,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "invasive_mechanical_ventilation"
      )
    }
  )

stopifnot(testdata_sha == digest::digest(testdata, algo = "sha256"))

stopifnot(
  identical(
    sapply(test_prepared_data, inherits, "data.frame"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "data.table"),
    c("DF" = FALSE, "DT" = inherits(testdata[["DT"]], "data.table"), "TB" = FALSE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "tbl_df"),
    c("DF" = FALSE, "DT" = FALSE, "TB" = inherits(testdata[["TB"]], "tbl_df"))
  ),
  identical(names(test_prepared_data[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_data[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_data[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(test_prepared_data[["DF"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["DT"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["TB"]][["hospital"]], rep("H1", 5)),
  identical(test_prepared_data[["DF"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["DT"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["TB"]][["patient"]], rep("P1", 5)),
  identical(test_prepared_data[["DF"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["DT"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["TB"]][["encounter"]], c("E1", "E1", "E2", "E2", "E1")),
  identical(test_prepared_data[["DF"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["DT"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["TB"]][["minutes_from_admission"]], c(1, 2, -1, 200, 3)),
  identical(test_prepared_data[["DF"]][["value"]], c(1L, 0L, 1L, 0L, 1L)),
  identical(test_prepared_data[["DT"]][["value"]], c(1L, 0L, 1L, 0L, 1L)),
  identical(test_prepared_data[["TB"]][["value"]], c(1L, 0L, 1L, 0L, 1L)),
  identical(test_prepared_data[["DF"]][["variable"]], rep("IMV", 5)),
  identical(test_prepared_data[["DT"]][["variable"]], rep("IMV", 5)),
  identical(test_prepared_data[["TB"]][["variable"]], rep("IMV", 5))
)

# the output from test_prepared_data could be "prepared" again, with no
# difference save the class attribute being longer in the reprocessed data.
# NOTE: the `value.var` arguement does need to be updated for the call.
test_prepared_data2 <-
  lapply(
    X = test_prepared_data,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "value"
      )
    }
  )
stopifnot(
  all.equal(test_prepared_data, test_prepared_data2, check.attributes = FALSE)
)

################################################################################
# Explicit class and attribute checks for prepared outputs
stopifnot(
  identical(
    sapply(test_prepared_data, inherits, "phoenix_prepared"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(
    sapply(test_prepared_data, inherits, "phoenix_prepared_imv"),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(attr(test_prepared_data[["DF"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["DT"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["TB"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_data[["DF"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_data[["DT"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_data[["TB"]], "eclock"), "minutes_from_admission")
)

################################################################################
# No duplicates path
testdata_no_dups <- list()
testdata_no_dups[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    invasive_mechanical_ventilation = c(1L, 0L, 1L),
    stringsAsFactors = FALSE
  )
testdata_no_dups[["DT"]] <- as_data_table_if_available(testdata_no_dups[["DF"]])
testdata_no_dups[["TB"]] <- as_tibble_if_available(testdata_no_dups[["DF"]])

test_prepared_no_dups <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "invasive_mechanical_ventilation",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_prepared_no_dups[["DF"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["DT"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["TB"]][["minutes_from_admission"]], c(0, 60, 10)),
  identical(test_prepared_no_dups[["DF"]][["value"]], c(1L, 0L, 1L)),
  identical(test_prepared_no_dups[["DT"]][["value"]], c(1L, 0L, 1L)),
  identical(test_prepared_no_dups[["TB"]][["value"]], c(1L, 0L, 1L))
)

################################################################################
# All duplicates path and custom tie.breaker across all backends
testdata_all_dups <- list()
testdata_all_dups[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 0, 60, 60),
    invasive_mechanical_ventilation = c(0L, 1L, 0L, 1L),
    stringsAsFactors = FALSE
  )
testdata_all_dups[["DT"]] <- as_data_table_if_available(testdata_all_dups[["DF"]])
testdata_all_dups[["TB"]] <- as_tibble_if_available(testdata_all_dups[["DF"]])

test_prepared_all_dups_max <-
  lapply(
    X = testdata_all_dups,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "invasive_mechanical_ventilation",
        tie.breaker = max,
        verbose = FALSE
      )
    }
  )

test_prepared_all_dups_min <-
  lapply(
    X = testdata_all_dups,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "invasive_mechanical_ventilation",
        tie.breaker = min,
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_prepared_all_dups_max[["DF"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["DT"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["TB"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_max[["DF"]][["value"]], c(1L, 1L)),
  identical(test_prepared_all_dups_max[["DT"]][["value"]], c(1L, 1L)),
  identical(test_prepared_all_dups_max[["TB"]][["value"]], c(1L, 1L)),
  identical(test_prepared_all_dups_min[["DF"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["DT"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["TB"]][["minutes_from_admission"]], c(0, 60)),
  identical(test_prepared_all_dups_min[["DF"]][["value"]], c(0L, 0L)),
  identical(test_prepared_all_dups_min[["DT"]][["value"]], c(0L, 0L)),
  identical(test_prepared_all_dups_min[["TB"]][["value"]], c(0L, 0L))
)

################################################################################
# numeric 0/1 input is accepted and normalized to integer output
testdata_numeric_values <- list()
testdata_numeric_values[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    invasive_mechanical_ventilation = c(1, 0, 1),
    stringsAsFactors = FALSE
  )
testdata_numeric_values[["DT"]] <- as_data_table_if_available(testdata_numeric_values[["DF"]])
testdata_numeric_values[["TB"]] <- as_tibble_if_available(testdata_numeric_values[["DF"]])

test_numeric_values <-
  lapply(
    X = testdata_numeric_values,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "invasive_mechanical_ventilation",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_numeric_values[["DF"]][["value"]], c(1L, 0L, 1L)),
  identical(test_numeric_values[["DT"]][["value"]], c(1L, 0L, 1L)),
  identical(test_numeric_values[["TB"]][["value"]], c(1L, 0L, 1L))
)

################################################################################
# id.vars validation
test_bad_id_vars <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "missing_id"),
          eclock = "minutes_from_admission",
          value.var = "invasive_mechanical_ventilation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_id_vars, inherits, "error"),
  sapply(sapply(test_bad_id_vars, getElement, "message"), grepl, pattern = "missing_id")
)

################################################################################
# eclock validation: missing column and non-numeric column
test_bad_eclock_missing <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "missing_eclock",
          value.var = "invasive_mechanical_ventilation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_eclock_missing, inherits, "error"),
  sapply(sapply(test_bad_eclock_missing, getElement, "message"), grepl, pattern = "missing_eclock")
)

testdata_bad_eclock <- list()
testdata_bad_eclock[["DF"]] <- testdata_no_dups[["DF"]]
testdata_bad_eclock[["DT"]] <- testdata_no_dups[["DT"]]
testdata_bad_eclock[["TB"]] <- testdata_no_dups[["TB"]]

testdata_bad_eclock <-
  lapply(
    X = testdata_bad_eclock,
    FUN = phoenix:::phxdft_set,
    j = "minutes_from_admission",
    value = c("0", "60", "10")
  )

test_bad_eclock_type <-
  lapply(
    X = testdata_bad_eclock,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "invasive_mechanical_ventilation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_eclock_type, inherits, "error"),
  sapply(sapply(test_bad_eclock_type, getElement, "message"), grepl, pattern = "numeric vector")
)

################################################################################
# value.var validation: non-numeric column types
testdata_character_value <- list()
testdata_character_value[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    invasive_mechanical_ventilation = c("1", "0", "1"),
    stringsAsFactors = FALSE
  )
testdata_character_value[["DT"]] <- as_data_table_if_available(testdata_character_value[["DF"]])
testdata_character_value[["TB"]] <- as_tibble_if_available(testdata_character_value[["DF"]])

test_bad_character_value <-
  lapply(
    X = testdata_character_value,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "invasive_mechanical_ventilation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_character_value, inherits, "error"),
  sapply(sapply(test_bad_character_value, getElement, "message"), grepl, pattern = "numeric or integer")
)

testdata_factor_value <- list()
testdata_factor_value[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    invasive_mechanical_ventilation = factor(c("1", "0", "1")),
    stringsAsFactors = FALSE
  )
testdata_factor_value[["DT"]] <- as_data_table_if_available(testdata_factor_value[["DF"]])
testdata_factor_value[["TB"]] <- as_tibble_if_available(testdata_factor_value[["DF"]])

test_bad_factor_value <-
  lapply(
    X = testdata_factor_value,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "invasive_mechanical_ventilation",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_factor_value, inherits, "error"),
  sapply(sapply(test_bad_factor_value, getElement, "message"), grepl, pattern = "numeric or integer")
)

################################################################################
# value.var validation: missing column and already named value
test_bad_value_var <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_imv(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "missing_value_var",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_value_var, inherits, "error")
)

testdata_value_var <- list()
testdata_value_var[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H2"),
    patient = c("P1", "P1", "P2"),
    encounter = c("E1", "E1", "E2"),
    minutes_from_admission = c(0, 60, 10),
    value = c(1L, 0L, 1L),
    stringsAsFactors = FALSE
  )
testdata_value_var[["DT"]] <- testdata_value_var[["DF"]]
testdata_value_var[["TB"]] <- testdata_value_var[["DF"]]

if (requireNamespace("data.table", quietly = TRUE)) {
  testdata_value_var[["DT"]] <- getExportedValue(ns = "data.table", name = "as.data.table")(testdata_value_var[["DT"]])
}

if (requireNamespace("dplyr", quietly = TRUE)) {
  testdata_value_var[["TB"]] <- getExportedValue(ns = "dplyr", name = "as_tibble")(testdata_value_var[["TB"]])
}

test_prepared_value_var <-
  lapply(
    X = testdata_value_var,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "value",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(names(test_prepared_value_var[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_value_var[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_value_var[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(test_prepared_value_var[["DF"]][["value"]], c(1L, 0L, 1L)),
  identical(test_prepared_value_var[["DT"]][["value"]], c(1L, 0L, 1L)),
  identical(test_prepared_value_var[["TB"]][["value"]], c(1L, 0L, 1L))
)

################################################################################
# Zero-row input
testdata_zero_row <- list()
testdata_zero_row[["DF"]] <-
  data.frame(
    hospital = character(0),
    patient = character(0),
    encounter = character(0),
    minutes_from_admission = numeric(0),
    invasive_mechanical_ventilation = integer(0),
    stringsAsFactors = FALSE
  )
testdata_zero_row[["DT"]] <- as_data_table_if_available(testdata_zero_row[["DF"]])
testdata_zero_row[["TB"]] <- as_tibble_if_available(testdata_zero_row[["DF"]])

test_prepared_zero_row <-
  lapply(
    X = testdata_zero_row,
    FUN = function(x) {
      prepare_imv(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "invasive_mechanical_ventilation",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(nrow(test_prepared_zero_row[["DF"]]), 0L),
  identical(nrow(test_prepared_zero_row[["DT"]]), 0L),
  identical(nrow(test_prepared_zero_row[["TB"]]), 0L),
  identical(names(test_prepared_zero_row[["DF"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_zero_row[["DT"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(names(test_prepared_zero_row[["TB"]]), c("hospital", "patient", "encounter", "minutes_from_admission", "value", "variable")),
  identical(attr(test_prepared_zero_row[["DF"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["DT"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["TB"]], "id.vars"), c("hospital", "patient", "encounter")),
  identical(attr(test_prepared_zero_row[["DF"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_zero_row[["DT"]], "eclock"), "minutes_from_admission"),
  identical(attr(test_prepared_zero_row[["TB"]], "eclock"), "minutes_from_admission"),
  identical(test_prepared_zero_row[["DF"]][["variable"]], character(0)),
  identical(test_prepared_zero_row[["DT"]][["variable"]], character(0)),
  identical(test_prepared_zero_row[["TB"]][["variable"]], character(0))
)

################################################################################
#                                 End of File                                  #
################################################################################
