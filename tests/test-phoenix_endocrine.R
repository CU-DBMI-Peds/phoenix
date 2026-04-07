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
    FUN = function(x) phoenix_endocrine(glucose, x)
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
stopifnot(identical(phoenix_endocrine(), 0L))

test_empty_result <-
  lapply(
    X = testdata,
    FUN = function(x) phoenix_endocrine(data = x)
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
    FUN = function(x) phoenix_endocrine(glucose, x[0, ])
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

test_list_result <- phoenix_endocrine(glucose = glucose, data = test_list_data)
test_env_result <- phoenix_endocrine(glucose = glucose, data = test_env_data)

stopifnot(
  identical(test_list_result, eg[["DF"]]),
  identical(test_env_result, eg[["DF"]])
)

################################################################################
# verify environments with parent emptyenv() error clearly
test_bad_env_data <- list2env(as.list(sepsis), parent = emptyenv())
test_bad_env_result <- tryCatch(
  phoenix_endocrine(glucose = glucose, data = test_bad_env_data),
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
#                                 End of File                                  #
################################################################################
