library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-infection-inputs.R
#
# This script groups the preparation tests for the two suspected-infection
# inputs used in the operational notation work:
#   - antimicrobials
#   - antiinfectioustests
#
# Both wrappers are discrete 0/1 indicators. The checks therefore focus on the
# standard discrete preparation contract:
#   - duplicate reduction at one encounter clock
#   - integer-valued prepared output
#   - rejection of invalid values
#   - consistent behavior across data.frame, data.table, and tibble inputs
################################################################################

run_indicator_case <- function(fun_name, variable_label, prepared_class, value.var) {
  id.vars <- c("hospital", "patient", "encounter")
  eclock <- "minutes_from_admission"
  FUN <- get(fun_name, mode = "function")

  df <- data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 0, 60, 120),
    value = c(0, 1, 0, 1),
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
    identical(sapply(prepared_default, inherits, "data.frame"), c(DF = TRUE, DT = TRUE, TB = TRUE)),
    identical(sapply(prepared_default, inherits, "phoenix_prepared"), c(DF = TRUE, DT = TRUE, TB = TRUE)),
    identical(sapply(prepared_default, inherits, prepared_class), c(DF = TRUE, DT = TRUE, TB = TRUE)),
    identical(prepared_default[["DF"]][["value"]], c(1L, 0L, 1L)),
    identical(prepared_default[["DT"]][["value"]], c(1L, 0L, 1L)),
    identical(prepared_default[["TB"]][["value"]], c(1L, 0L, 1L)),
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
            tie.breaker = min,
            verbose = FALSE
          )
        )
      }
    )
  prepared_custom <- lapply(prepared_custom, sort_prepared)

  stopifnot(
    identical(prepared_custom[["DF"]][["value"]], c(0L, 0L, 1L)),
    identical(prepared_custom[["DT"]][["value"]], c(0L, 0L, 1L)),
    identical(prepared_custom[["TB"]][["value"]], c(0L, 0L, 1L))
  )

  test_invalid <-
    lapply(
      X = make_backends(phoenix:::phxdft_set(df, i = 1L, j = value.var, value = 2)),
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
}

run_indicator_case(
  fun_name = "prepare_antimicrobials",
  variable_label = "ANTIMICROBIALS",
  prepared_class = "phoenix_prepared_antimicrobials",
  value.var = "antimicrobial_indicator"
)

run_indicator_case(
  fun_name = "prepare_antiinfectioustests",
  variable_label = "ANTIINFECTIOUSTESTS",
  prepared_class = "phoenix_prepared_antiinfectioustests",
  value.var = "antiinfectioustest_indicator"
)

################################################################################
#                                 End of File                                  #
################################################################################
