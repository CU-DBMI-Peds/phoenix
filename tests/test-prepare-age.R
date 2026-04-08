library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-age.R
#
# Age is prepared separately from the other Phoenix inputs because it is static
# to an encounter rather than varying over the encounter clock.  The purpose of
# this script is to verify that prepare_age():
#   - validates numeric/integer age values and the valid.range
#   - aggregates duplicates by id.vars only
#   - returns the standard prepared-object structure across data.frame,
#     data.table, and tibble inputs
#   - does not require an eclock argument
################################################################################

id.vars <- c("hospital", "patient", "encounter")

age_df <-
  data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P2", "P2"),
    encounter = c("E1", "E1", "E2", "E2"),
    age_months = c(72, 60, 24, 24),
    stringsAsFactors = FALSE
  )

testdata <- make_backends(age_df)

###############################################################################
# Missing values should be rejected.
test_missing_age <-
  lapply(
    X = make_backends(phoenix:::phxdft_set(age_df, i = 1L, j = "age_months", value = NA_real_)),
    FUN = function(x) {
      tryCatch(
        prepare_age(
          x = x,
          id.vars = id.vars,
          value.var = "age_months",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_missing_age, inherits, "error"),
  sapply(sapply(test_missing_age, getElement, "message"), grepl, pattern = "non-missing")
)

###############################################################################
# Values below and above the default valid.range should error.
test_age_below_range <-
  lapply(
    X = make_backends(phoenix:::phxdft_set(age_df, i = 1L, j = "age_months", value = -1)),
    FUN = function(x) {
      tryCatch(
        prepare_age(
          x = x,
          id.vars = id.vars,
          value.var = "age_months",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_age_below_range, inherits, "error"),
  sapply(sapply(test_age_below_range, getElement, "message"), grepl, pattern = "< 0\\.000000")
)

test_age_above_range <-
  lapply(
    X = make_backends(phoenix:::phxdft_set(age_df, i = 1L, j = "age_months", value = 217)),
    FUN = function(x) {
      tryCatch(
        prepare_age(
          x = x,
          id.vars = id.vars,
          value.var = "age_months",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_age_above_range, inherits, "error"),
  sapply(sapply(test_age_above_range, getElement, "message"), grepl, pattern = "> 216\\.000000")
)

###############################################################################
# Character and factor inputs should be rejected.
test_bad_type_chr_df <- age_df
test_bad_type_chr_df[["age_months"]] <- as.character(test_bad_type_chr_df[["age_months"]])

test_bad_type_chr <-
  lapply(
    X = make_backends(test_bad_type_chr_df),
    FUN = function(x) {
      tryCatch(
        prepare_age(
          x = x,
          id.vars = id.vars,
          value.var = "age_months",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_type_chr, inherits, "error"),
  sapply(sapply(test_bad_type_chr, getElement, "message"), grepl, pattern = "numeric or integer")
)

test_bad_type_fct_df <- age_df
test_bad_type_fct_df[["age_months"]] <- factor(test_bad_type_fct_df[["age_months"]])

test_bad_type_fct <-
  lapply(
    X = make_backends(test_bad_type_fct_df),
    FUN = function(x) {
      tryCatch(
        prepare_age(
          x = x,
          id.vars = id.vars,
          value.var = "age_months",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_type_fct, inherits, "error"),
  sapply(sapply(test_bad_type_fct, getElement, "message"), grepl, pattern = "numeric or integer")
)

###############################################################################
# Successful preparation should aggregate by id.vars only.  The default
# tie.breaker is min, so patient P1 / encounter E1 should reduce from
# c(72, 60) to 60.
test_prepared_age <-
  lapply(
    X = testdata,
    FUN = function(x) {
      prepare_age(
        x = x,
        id.vars = id.vars,
        value.var = "age_months",
        verbose = FALSE
      )
    }
  )

test_prepared_age <- lapply(test_prepared_age, sort_prepared, eclock = "hospital")

stopifnot(
  identical(sapply(test_prepared_age, inherits, "data.frame"), c(DF = TRUE, DT = TRUE, TB = TRUE)),
  identical(sapply(test_prepared_age, inherits, "phoenix_prepared"), c(DF = TRUE, DT = TRUE, TB = TRUE)),
  identical(sapply(test_prepared_age, inherits, "phoenix_prepared_age"), c(DF = TRUE, DT = TRUE, TB = TRUE)),
  identical(test_prepared_age[["DF"]][["value"]], c(60, 24)),
  identical(test_prepared_age[["DT"]][["value"]], c(60, 24)),
  identical(test_prepared_age[["TB"]][["value"]], c(60, 24)),
  identical(test_prepared_age[["DF"]][["variable"]], c("AGE", "AGE")),
  identical(test_prepared_age[["DT"]][["variable"]], c("AGE", "AGE")),
  identical(test_prepared_age[["TB"]][["variable"]], c("AGE", "AGE")),
  identical(attr(test_prepared_age[["DF"]], "id.vars"), id.vars),
  identical(attr(test_prepared_age[["DT"]], "id.vars"), id.vars),
  identical(attr(test_prepared_age[["TB"]], "id.vars"), id.vars),
  is.null(attr(test_prepared_age[["DF"]], "eclock")),
  is.null(attr(test_prepared_age[["DT"]], "eclock")),
  is.null(attr(test_prepared_age[["TB"]], "eclock"))
)

###############################################################################
# A custom tie.breaker should also work when the encounter-level age is
# duplicated.
test_prepared_age_min <-
  lapply(
    X = testdata,
    FUN = function(x) {
      prepare_age(
        x = x,
        id.vars = id.vars,
        value.var = "age_months",
        tie.breaker = min,
        verbose = FALSE
      )
    }
  )

test_prepared_age_min <- lapply(test_prepared_age_min, sort_prepared, eclock = "hospital")

stopifnot(
  identical(test_prepared_age_min[["DF"]][["value"]], c(60, 24)),
  identical(test_prepared_age_min[["DT"]][["value"]], c(60, 24)),
  identical(test_prepared_age_min[["TB"]][["value"]], c(60, 24))
)

###############################################################################
# A custom valid.range should be accepted.
test_prepared_age_custom_range <-
  lapply(
    X = testdata,
    FUN = function(x) {
      prepare_age(
        x = x,
        id.vars = id.vars,
        value.var = "age_months",
        valid.range = c(0, 120),
        verbose = FALSE
      )
    }
  )

test_prepared_age_custom_range <- lapply(test_prepared_age_custom_range, sort_prepared, eclock = "hospital")

stopifnot(
  identical(test_prepared_age_custom_range[["DF"]][["value"]], c(60, 24)),
  identical(test_prepared_age_custom_range[["DT"]][["value"]], c(60, 24)),
  identical(test_prepared_age_custom_range[["TB"]][["value"]], c(60, 24))
)

###############################################################################
# The caller's raw object should not be mutated by reference.
test_input_copy <- testdata

invisible(
  lapply(
    X = test_input_copy,
    FUN = function(x) {
      prepare_age(
        x = x,
        id.vars = id.vars,
        value.var = "age_months",
        verbose = FALSE
      )
    }
  )
)

stopifnot(
  identical(names(test_input_copy[["DF"]]), names(age_df)),
  identical(names(test_input_copy[["DT"]]), names(age_df)),
  identical(names(test_input_copy[["TB"]]), names(age_df))
)

###############################################################################
# Validation of id.vars and value.var should still work without an eclock.
test_bad_idvars <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_age(
          x = x,
          id.vars = c(id.vars, "missing_id"),
          value.var = "age_months",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(test_bad_idvars, inherits, "error"),
  sapply(sapply(test_bad_idvars, getElement, "message"), grepl, pattern = "missing_id")
)

test_bad_value_var <-
  lapply(
    X = testdata,
    FUN = function(x) {
      tryCatch(
        prepare_age(
          x = x,
          id.vars = id.vars,
          value.var = "missing_age",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(sapply(test_bad_value_var, inherits, "error"))

###############################################################################
# If the source column is already named value, preparation should still work.
age_value_df <- age_df
names(age_value_df)[names(age_value_df) == "age_months"] <- "value"

test_prepared_value_col <-
  lapply(
    X = make_backends(age_value_df),
    FUN = function(x) {
      prepare_age(
        x = x,
        id.vars = id.vars,
        value.var = "value",
        verbose = FALSE
      )
    }
  )

test_prepared_value_col <- lapply(test_prepared_value_col, sort_prepared, eclock = "hospital")

stopifnot(
  identical(test_prepared_value_col[["DF"]][["value"]], c(60, 24)),
  identical(test_prepared_value_col[["DT"]][["value"]], c(60, 24)),
  identical(test_prepared_value_col[["TB"]][["value"]], c(60, 24))
)

###############################################################################
# Zero-row input should still return a valid prepared object.
test_zero_row_age <-
  lapply(
    X = make_backends(age_df[0, ]),
    FUN = function(x) {
      prepare_age(
        x = x,
        id.vars = id.vars,
        value.var = "age_months",
        verbose = FALSE
      )
    }
  )

stopifnot(
  identical(nrow(test_zero_row_age[["DF"]]), 0L),
  identical(nrow(test_zero_row_age[["DT"]]), 0L),
  identical(nrow(test_zero_row_age[["TB"]]), 0L),
  identical(test_zero_row_age[["DF"]][["variable"]], character(0)),
  identical(test_zero_row_age[["DT"]][["variable"]], character(0)),
  identical(test_zero_row_age[["TB"]][["variable"]], character(0)),
  is.null(attr(test_zero_row_age[["DF"]], "eclock")),
  is.null(attr(test_zero_row_age[["DT"]], "eclock")),
  is.null(attr(test_zero_row_age[["TB"]], "eclock"))
)

################################################################################
#                                 End of File                                  #
################################################################################
