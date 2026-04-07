library(phoenix)
source("utilities.R")

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
