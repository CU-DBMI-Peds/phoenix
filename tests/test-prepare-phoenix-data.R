library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-phoenix-data.R
#
# This script tests prepare_phoenix_data(), the function that takes already
# prepared longitudinal inputs and assembles them into the encounter-by-time
# data set needed by the Phoenix respiratory scoring methods.
#
# At present the implementation is narrower than the prepare_<input>() wrappers:
#   - only respiratory inputs (FIO2, SPO2, PAO2) are accepted
#   - the stack/cast path is implemented for data.table inputs
#   - base data.frame and tibble inputs are expected to stop with "not yet built"
#
# The tests below therefore do two things:
#   1. verify the implemented data.table behavior, including carry-forward
#      within the configured respiratory lookback window
#   2. document the current failure mode for data.frame and tibble inputs so a
#      future expansion of backend support can update the tests intentionally
################################################################################

# Ordering matters when we compare expected carry-forward values.  The assembly
# code sorts on id.vars + eclock, so the tests do the same before checking the
# output columns.
sort_phxdata <- function(x, id.vars, eclock) {
  idx <- do.call(order, lapply(c(id.vars, eclock), function(j) x[[j]]))
  x[idx, , drop = FALSE]
}

id.vars <- c("hospital", "patient", "encounter")
eclock  <- "minutes_from_admission"

###############################################################################
# Build one simple longitudinal fixture.  The rows are intentionally sparse:
# each variable is observed at different times.  This makes it easy to verify
# the stacked time grid and the last-observation-carried-forward behavior.
resp_df <-
  data.frame(
    hospital = c("H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E1"),
    minutes_from_admission = c(0, 60, 120, 500),
    value = c(0.30, 95, 80, 96),
    stringsAsFactors = FALSE
  )

fio2_df <- resp_df[c(1), ]
spo2_df <- resp_df[c(2, 4), ]
pao2_df <- resp_df[c(3), ]

names(fio2_df)[names(fio2_df) == "value"] <- "fio2"
names(spo2_df)[names(spo2_df) == "value"] <- "spo2"
names(pao2_df)[names(pao2_df) == "value"] <- "pao2"

fio2_inputs <- make_backends(fio2_df)
spo2_inputs <- make_backends(spo2_df)
pao2_inputs <- make_backends(pao2_df)

prepared_fio2 <-
  lapply(
    X = fio2_inputs,
    FUN = function(x) {
      prepare_fio2(
        x = x,
        id.vars = id.vars,
        eclock = eclock,
        value.var = "fio2",
        verbose = FALSE
      )
    }
  )

prepared_spo2 <-
  lapply(
    X = spo2_inputs,
    FUN = function(x) {
      prepare_spo2(
        x = x,
        id.vars = id.vars,
        eclock = eclock,
        value.var = "spo2",
        verbose = FALSE
      )
    }
  )

prepared_pao2 <-
  lapply(
    X = pao2_inputs,
    FUN = function(x) {
      prepare_pao2(
        x = x,
        id.vars = id.vars,
        eclock = eclock,
        value.var = "pao2",
        verbose = FALSE
      )
    }
  )

###############################################################################
# The current implementation should succeed on the data.table backend and should
# not yet work for plain data.frames or tibbles.
test_assembled <-
  Map(
    f = function(fio2, spo2, pao2) {
      tryCatch(
        prepare_phoenix_data(
          fio2 = fio2,
          spo2 = spo2,
          pao2 = pao2,
          resp.lookback = 360,
          verbose = FALSE
        ),
        error = function(e) e
      )
    },
    fio2 = prepared_fio2,
    spo2 = prepared_spo2,
    pao2 = prepared_pao2
  )

stopifnot(inherits(test_assembled[["DF"]], "error"))
stopifnot(grepl("not yet built", test_assembled[["DF"]][["message"]]))

if (inherits(prepared_fio2[["DT"]], "data.table")) {
  test_assembled[["DT"]] <- sort_phxdata(test_assembled[["DT"]], id.vars = id.vars, eclock = eclock)
  stopifnot(
    inherits(test_assembled[["DT"]], "data.table"),
    isTRUE(all.equal(test_assembled[["DT"]][[eclock]], c(0, 60, 120, 500))),
    identical(test_assembled[["DT"]][["FIO2"]], c(0.30, 0.30, 0.30, NA_real_)),
    isTRUE(all.equal(test_assembled[["DT"]][["FIO2_eclock"]], c(0, 0, 0, NA))),
    identical(test_assembled[["DT"]][["SPO2"]], c(NA_real_, 95, 95, 96)),
    isTRUE(all.equal(test_assembled[["DT"]][["SPO2_eclock"]], c(NA, 60, 60, 500))),
    identical(test_assembled[["DT"]][["PAO2"]], c(NA_real_, NA_real_, 80, NA_real_)),
    isTRUE(all.equal(test_assembled[["DT"]][["PAO2_eclock"]], c(NA, NA, 120, NA)))
  )
} else {
  stopifnot(inherits(test_assembled[["DT"]], "error"))
  stopifnot(grepl("not yet built", test_assembled[["DT"]][["message"]]))
}

if (inherits(prepared_fio2[["TB"]], "tbl_df")) {
  stopifnot(inherits(test_assembled[["TB"]], "error"))
  stopifnot(grepl("not yet built", test_assembled[["TB"]][["message"]]))
} else {
  stopifnot(inherits(test_assembled[["TB"]], "error"))
  stopifnot(grepl("not yet built", test_assembled[["TB"]][["message"]]))
}

###############################################################################
# Single-input assembly should still work on the implemented data.table path.
test_single_input <-
  tryCatch(
    prepare_phoenix_data(
      fio2 = prepared_fio2[["DT"]],
      resp.lookback = 360,
      verbose = FALSE
    ),
    error = function(e) e
  )

if (inherits(prepared_fio2[["DT"]], "data.table")) {
  test_single_input <- sort_phxdata(test_single_input, id.vars = id.vars, eclock = eclock)
  stopifnot(
    inherits(test_single_input, "data.table"),
    identical(names(test_single_input), c(id.vars, eclock, "FIO2", "FIO2_eclock")),
    identical(test_single_input[["FIO2"]], 0.30),
    isTRUE(all.equal(test_single_input[["FIO2_eclock"]], 0))
  )
} else {
  stopifnot(inherits(test_single_input, "error"))
  stopifnot(grepl("not yet built", test_single_input[["message"]]))
}

###############################################################################
# Values should not carry forward across encounter boundaries.  The second
# encounter has no early SPO2 value, so the first row of encounter E2 must stay
# missing rather than inheriting the last SPO2 from encounter E1.
boundary_df <-
  data.frame(
    hospital = c("H1", "H1", "H1", "H1", "H1"),
    patient = c("P1", "P1", "P1", "P1", "P1"),
    encounter = c("E1", "E1", "E1", "E2", "E2"),
    minutes_from_admission = c(0, 60, 120, 0, 300),
    value = c(0.30, 95, 80, 0.40, 97),
    stringsAsFactors = FALSE
  )

boundary_fio2 <- boundary_df[c(1, 4), ]
boundary_spo2 <- boundary_df[c(2, 5), ]
boundary_pao2 <- boundary_df[c(3), ]

names(boundary_fio2)[names(boundary_fio2) == "value"] <- "fio2"
names(boundary_spo2)[names(boundary_spo2) == "value"] <- "spo2"
names(boundary_pao2)[names(boundary_pao2) == "value"] <- "pao2"

if (requireNamespace("data.table", quietly = TRUE)) {
  boundary_fio2 <- as_data_table_if_available(boundary_fio2)
  boundary_spo2 <- as_data_table_if_available(boundary_spo2)
  boundary_pao2 <- as_data_table_if_available(boundary_pao2)

  boundary_prepared_fio2 <-
    prepare_fio2(
      x = boundary_fio2,
      id.vars = id.vars,
      eclock = eclock,
      value.var = "fio2",
      verbose = FALSE
    )
  boundary_prepared_spo2 <-
    prepare_spo2(
      x = boundary_spo2,
      id.vars = id.vars,
      eclock = eclock,
      value.var = "spo2",
      verbose = FALSE
    )
  boundary_prepared_pao2 <-
    prepare_pao2(
      x = boundary_pao2,
      id.vars = id.vars,
      eclock = eclock,
      value.var = "pao2",
      verbose = FALSE
    )

  boundary_assembled <-
    prepare_phoenix_data(
      fio2 = boundary_prepared_fio2,
      spo2 = boundary_prepared_spo2,
      pao2 = boundary_prepared_pao2,
      resp.lookback = 360,
      verbose = FALSE
    )

  boundary_assembled <- sort_phxdata(boundary_assembled, id.vars = id.vars, eclock = eclock)
  idx_e2_0 <- with(boundary_assembled, encounter == "E2" & minutes_from_admission == 0)
  stopifnot(
    length(which(idx_e2_0)) == 1L,
    identical(boundary_assembled[["FIO2"]][idx_e2_0], 0.40),
    is.na(boundary_assembled[["SPO2"]][idx_e2_0]),
    is.na(boundary_assembled[["PAO2"]][idx_e2_0])
  )
}

###############################################################################
# The assembly helper should reject unprepared inputs with a clear message.
test_unprepared <-
  tryCatch(
    prepare_phoenix_data(
      fio2 = fio2_df,
      spo2 = prepared_spo2[["DF"]],
      pao2 = prepared_pao2[["DF"]],
      verbose = FALSE
    ),
    error = function(e) e
  )

stopifnot(
  inherits(test_unprepared, "error"),
  grepl("prepare_fio2", test_unprepared[["message"]])
)

###############################################################################
# All prepared inputs must agree on id.vars.
mismatch_id_source <- spo2_df
mismatch_id_prepared <-
  prepare_spo2(
    x = mismatch_id_source,
    id.vars = c("patient", "encounter"),
    eclock = eclock,
    value.var = "spo2",
    verbose = FALSE
  )

test_id_mismatch <-
  tryCatch(
    prepare_phoenix_data(
      fio2 = prepared_fio2[["DF"]],
      spo2 = mismatch_id_prepared,
      pao2 = prepared_pao2[["DF"]],
      verbose = FALSE
    ),
    error = function(e) e
  )

stopifnot(
  inherits(test_id_mismatch, "error"),
  grepl("same id.vars", test_id_mismatch[["message"]])
)

###############################################################################
# All prepared inputs must also agree on the encounter clock variable.
mismatch_eclock_source <- pao2_df
mismatch_eclock_source[["alt_minutes"]] <- mismatch_eclock_source[[eclock]]

mismatch_eclock_prepared <-
  prepare_pao2(
    x = mismatch_eclock_source,
    id.vars = id.vars,
    eclock = "alt_minutes",
    value.var = "pao2",
    verbose = FALSE
  )

test_eclock_mismatch <-
  tryCatch(
    prepare_phoenix_data(
      fio2 = prepared_fio2[["DF"]],
      spo2 = prepared_spo2[["DF"]],
      pao2 = mismatch_eclock_prepared,
      verbose = FALSE
    ),
    error = function(e) e
  )

stopifnot(
  inherits(test_eclock_mismatch, "error"),
  grepl("same eclock", test_eclock_mismatch[["message"]])
)

###############################################################################
# Non-negative scalar lookback values are required.
test_bad_lookback <-
  tryCatch(
    prepare_phoenix_data(
      fio2 = prepared_fio2[["DF"]],
      resp.lookback = -1,
      verbose = FALSE
    ),
    error = function(e) e
  )

stopifnot(inherits(test_bad_lookback, "error"))

################################################################################
#                                 End of File                                  #
################################################################################
