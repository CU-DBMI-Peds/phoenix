library(phoenix)

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
testdata[["DT"]] <- testdata[["DF"]]
testdata[["TB"]] <- testdata[["DF"]]

if (requireNamespace("data.table", quietly = TRUE)) {
  testdata[["DT"]] <- getExportedValue(ns = "data.table", name = "as.data.table")(testdata[["DT"]])
}

if (requireNamespace("dplyr", quietly = TRUE)) {
  testdata[["TB"]] <- getExportedValue(ns = "dplyr", name = "as_tibble")(testdata[["TB"]])
}

# Error due to the presence of a missing value
test_missing_value <-
  lapply(
    X = testdata,
    FUN = function(x) tryCatch(prepare_fio2(x, value.var = "percent_inspired_oxygen"), error = function(e) e)
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
    FUN = function(x) tryCatch(prepare_fio2(x, value.var = "percent_inspired_oxygen"), error = function(e) e)
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
#                                 End of File                                  #
################################################################################
