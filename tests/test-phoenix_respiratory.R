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
      phoenix_respiratory(
        pf_ratio = pao2 / fio2,
        sf_ratio = spo2 / fio2,
        imv      = vent,
        other_respiratory_support = as.integer(fio2 > 0.21),
        data = x
      )
    }
  )

stopifnot(
  "return is an integer vector" =
    identical(
      sapply(eg, is.integer),
      c("DF" = TRUE, "DT" = TRUE, "TB" = TRUE)
    )
)

stopifnot(
  identical(eg[["DF"]], eg[["DT"]]),
  identical(eg[["DF"]], eg[["TB"]])
)

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed, across all backends
stopifnot(identical(phoenix_respiratory(), 0L))

test_empty_data <- list()
test_empty_data[["DF"]] <- sepsis
test_empty_data[["DT"]] <- as_data_table_if_available(sepsis)
test_empty_data[["TB"]] <- as_tibble_if_available(sepsis)

test_empty_result <-
  lapply(
    X = test_empty_data,
    FUN = function(x) phoenix_respiratory(data = x)
  )

stopifnot(
  identical(test_empty_result[["DF"]], 0L),
  identical(test_empty_result[["DT"]], 0L),
  identical(test_empty_result[["TB"]], 0L)
)

test_empty_result <-
  lapply(
    X = test_empty_data,
    FUN = function(x) phoenix_respiratory(data = x[0, ])
  )

data <- test_empty_data[[1]][0, ]

stopifnot(
  identical(test_empty_result[["DF"]], integer(0L)),
  identical(test_empty_result[["DT"]], integer(0L)),
  identical(test_empty_result[["TB"]], integer(0L))
)

test_zero_row_df_result <-
  lapply(
    X = test_empty_data,
    FUN = function(x) phoenix_respiratory(pf_ratio = pao2/fio2, sf_ratio = spo2/fio2, data = x[0, ])
  )

stopifnot(
  identical(test_empty_result[["DF"]], integer(0L)),
  identical(test_empty_result[["DT"]], integer(0L)),
  identical(test_empty_result[["TB"]], integer(0L))
)

################################################################################
# verify error if lengths differ
x <- tryCatch(phoenix_respiratory(pf_ratio = numeric(0)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of pf_ratio is 0; Length of sf_ratio is 1; Length of imv is 1; Length of other_respiratory_support is 1."
))

x <- tryCatch(phoenix_respiratory(pf_ratio = c(NA, NA), imv = c(NA, NA, NA)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of pf_ratio is 2; Length of sf_ratio is 1; Length of imv is 3; Length of other_respiratory_support is 1."
))

################################################################################
#                                 End of File                                  #
################################################################################
