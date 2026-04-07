library(phoenix)
source("utilities.R")

################################################################################
# verify that the return is an integer vector across all backends
testdata <- list()
testdata[["DF"]] <- sepsis
testdata[["DT"]] <- as_data_table_if_available(sepsis)
testdata[["TB"]] <- as_tibble_if_available(sepsis)

eg <-
  lapply(
    X = testdata,
    FUN = function(x) {
      phoenix_neurologic(
        gcs = gcs_total,
        fixed_pupils = as.integer(pupil == "both-fixed"),
        data = x
      )
    }
  )

stopifnot(
  identical(
    sapply(eg, is.integer),
    c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
  ),
  identical(eg[["DF"]], eg[["DT"]]),
  identical(eg[["DF"]], eg[["TB"]])
)

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed, across all backends
stopifnot(identical(phoenix_neurologic(), 0L))

test_empty_result <-
  lapply(
    X = testdata,
    FUN = function(x) phoenix_neurologic(data = x)
  )

stopifnot(
  identical(test_empty_result[["DF"]], 0L),
  identical(test_empty_result[["DT"]], 0L),
  identical(test_empty_result[["TB"]], 0L)
)

################################################################################
# verify zero-row data returns integer(0) across all backends
test_zero_row_result <-
  lapply(
    X = testdata,
    FUN = function(x) {
      phoenix_neurologic(
        gcs = gcs_total,
        fixed_pupils = as.integer(pupil == "both-fixed"),
        data = x[0, ]
      )
    }
  )

stopifnot(
  identical(test_zero_row_result[["DF"]], integer(0L)),
  identical(test_zero_row_result[["DT"]], integer(0L)),
  identical(test_zero_row_result[["TB"]], integer(0L))
)

################################################################################
# verify list and environment data paths
test_list_data <- as.list(sepsis)
test_env_data <- list2env(test_list_data, parent = baseenv())

test_list_result <-
  phoenix_neurologic(
    gcs = gcs_total,
    fixed_pupils = as.integer(pupil == "both-fixed"),
    data = test_list_data
  )

test_env_result <-
  phoenix_neurologic(
    gcs = gcs_total,
    fixed_pupils = as.integer(pupil == "both-fixed"),
    data = test_env_data
  )

stopifnot(
  identical(test_list_result, eg[["DF"]]),
  identical(test_env_result, eg[["DF"]])
)

################################################################################
# verify environments with parent emptyenv() error clearly
test_bad_env_data <- list2env(as.list(sepsis), parent = emptyenv())
test_bad_env_result <- tryCatch(
  phoenix_neurologic(
    gcs = gcs_total,
    fixed_pupils = as.integer(pupil == "both-fixed"),
    data = test_bad_env_data
  ),
  error = function(e) e
)

stopifnot(
  inherits(test_bad_env_result, "error"),
  identical(
    test_bad_env_result$message,
    paste0(
      "`data` is an environment with parent `emptyenv()`, so expressions ",
      "cannot resolve base functions/operators. Use `baseenv()` as the parent, ",
      "for example `list2env(x, parent = baseenv())`."
    )
  )
)

################################################################################
# verify error if lengths differ
x <- tryCatch(phoenix_neurologic(gcs = numeric(0)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of gcs is 0; Length of fixed_pupils is 1."
))

x <- tryCatch(phoenix_neurologic(gcs = c(NA, NA), fixed_pupils = c(NA, NA, NA)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of gcs is 2; Length of fixed_pupils is 3."
))

################################################################################
#                                 End of File                                  #
################################################################################
