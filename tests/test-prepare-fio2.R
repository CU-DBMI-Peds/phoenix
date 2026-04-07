library(phoenix)

################################################################################
# Defaut valid range checks 0.21 to 1.00
testdata <- list()
testdata[["DF"]] <-
  data.frame(
    hospital = c("H1", "H1", "H1"),
    patient = c("P1"),
    encounter = c("E1"),
    minutes_from_admission = 1:3,
    percent_inspired_oxygen = c(NA, -0.3, 21),
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


################################################################################
#                                 End of File                                  #
################################################################################
