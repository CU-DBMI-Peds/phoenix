library(phoenix)
source("utilities.R")

################################################################################
# Defaut valid range checks 0.21 to 1.00
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

# Error due to the presence of a values outside the valid range
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
  sapply(sapply(test_missing_value, getElement, "message"), grepl, pattern = " < 0\\.21.*1\\.0")
)

# now update the bad values to valid values
testdata <-
  lapply(
    X = testdata,
    FUN = phoenix:::phxdft_set,
    i = c(2L, 3L),
    j = "percent_inspired_oxygen",
    value = c(0.31, 0.999)
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
  identical(test_prepared_data[["DF"]][["value"]], c(0.21, 0.31, 0.3, 0.4, 0.999)),
  identical(test_prepared_data[["DT"]][["value"]], c(0.21, 0.31, 0.3, 0.4, 0.999)),
  identical(test_prepared_data[["TB"]][["value"]], c(0.21, 0.31, 0.3, 0.4, 0.999)),
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
# valid.values support
test_valid_values <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = c("hospital", "patient", "encounter"),
        eclock = "minutes_from_admission",
        value.var = "percent_inspired_oxygen",
        valid.range = NULL,
        valid.values = c(0.21, 0.30, 0.40),
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(test_valid_values[["DF"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_valid_values[["DT"]][["value"]], c(0.21, 0.30, 0.40)),
  identical(test_valid_values[["TB"]][["value"]], c(0.21, 0.30, 0.40))
)

################################################################################
# valid.range and valid.values are mutually exclusive
test_bad_validation_args <-
  lapply(
    X = testdata_no_dups,
    FUN = function(x) {
      tryCatch(
        prepare_fio2(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "percent_inspired_oxygen",
          valid.range = c(0.21, 1.00),
          valid.values = c(0.21, 0.30, 0.40),
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_validation_args, inherits, "error"),
  sapply(sapply(test_bad_validation_args, getElement, "message"), grepl, pattern = "Only one of valid.range and valid.values")
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
testdata_zero_row[["DT"]] <- testdata_zero_row[["DF"]]
testdata_zero_row[["TB"]] <- testdata_zero_row[["DF"]]

if (requireNamespace("data.table", quietly = TRUE)) {
  testdata_zero_row[["DT"]] <- getExportedValue(ns = "data.table", name = "as.data.table")(testdata_zero_row[["DT"]])
}

if (requireNamespace("dplyr", quietly = TRUE)) {
  testdata_zero_row[["TB"]] <- getExportedValue(ns = "dplyr", name = "as_tibble")(testdata_zero_row[["TB"]])
}

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
