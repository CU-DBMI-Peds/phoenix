library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-renal-inputs.R
#
# Phoenix-8 renal preparation currently consists of creatinine only.
#
# Age is part of renal scoring, but it is static to an encounter and is not
# currently being routed through the longitudinal preparation pipeline.
################################################################################

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
    identical(prepared_default[["TB"]][["variable"]], rep(variable_label, 3))
  )

  prepared_custom <- lapply(
    X = testdata,
    FUN = function(x) do.call(FUN, list(x = x, id.vars = id.vars, eclock = eclock, value.var = value.var, tie.breaker = custom_tie.breaker, verbose = FALSE))
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
}

run_range_case("prepare_creatinine", "CREATININE", "creatinine_value", c(0.8, 0.3, 0.6, 1.0), c(0.8, 0.6, 1.0), c(0.3, 0.6, 1.0), c(0, 5), max, min)

test_creatinine_above_default_range <-
  lapply(
    X = make_backends(
      data.frame(
        hospital = "H1",
        patient = "P1",
        encounter = "E1",
        minutes_from_admission = 0,
        creatinine = 51
      )
    ),
    FUN = function(x) {
      tryCatch(
        prepare_creatinine(
          x = x,
          id.vars = c("hospital", "patient", "encounter"),
          eclock = "minutes_from_admission",
          value.var = "creatinine",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_creatinine_above_default_range, inherits, "error"),
  sapply(sapply(test_creatinine_above_default_range, getElement, "message"), grepl, pattern = "> 50\\.000000")
)

################################################################################
#                                 End of File                                  #
################################################################################
