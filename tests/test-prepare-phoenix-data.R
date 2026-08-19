library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-prepare-phoenix-data.R
#
# This script tests prepare_phoenix_data(), the function that takes already
# prepared longitudinal inputs and assembles them into the encounter-by-time
# data set needed by the Phoenix respiratory scoring methods.
#
# The tests below verify assembly behavior across the supported data backends,
# including carry-forward within configured lookback windows and encounter
# boundary handling.
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

assert_assembled_resp <- function(x, expected_class = NULL) {
  x <- sort_phxdata(x, id.vars = id.vars, eclock = eclock)
  stopifnot(
    inherits(x, "prepared_phoenix_data"),
    is.null(expected_class) || inherits(x, expected_class),
    isTRUE(all.equal(x[[eclock]], c(0, 60, 120, 500))),
    identical(x[["FIO2"]], c(0.30, 0.30, 0.30, NA_real_)),
    isTRUE(all.equal(x[["FIO2_eclock"]], c(0, 0, 0, NA))),
    identical(x[["SPO2"]], c(NA_real_, 95, 95, 96)),
    isTRUE(all.equal(x[["SPO2_eclock"]], c(NA, 60, 60, 500))),
    identical(x[["PAO2"]], c(NA_real_, NA_real_, 80, NA_real_)),
    isTRUE(all.equal(x[["PAO2_eclock"]], c(NA, NA, 120, NA)))
  )
  invisible(x)
}

###############################################################################
# Assembly should work for base data.frames and for optional data.table/tibble
# backends when those suggested packages are available.
test_assembled <-
  Map(
    f = function(fio2, spo2, pao2) {
      prepare_phoenix_data(
        fio2 = fio2,
        spo2 = spo2,
        pao2 = pao2,
        resp.lookback = 360,
        verbose = FALSE
      )
    },
    fio2 = prepared_fio2,
    spo2 = prepared_spo2,
    pao2 = prepared_pao2
  )

assert_assembled_resp(test_assembled[["DF"]], expected_class = "data.frame")

if (inherits(prepared_fio2[["DT"]], "data.table")) {
  assert_assembled_resp(test_assembled[["DT"]], expected_class = "data.table")
} else {
  assert_assembled_resp(test_assembled[["DT"]], expected_class = "data.frame")
}

if (inherits(prepared_fio2[["TB"]], "tbl_df") &&
    requireNamespace("tidyr", quietly = TRUE) &&
    packageVersion("tidyr") >= "1.0.0") {
  assert_assembled_resp(test_assembled[["TB"]], expected_class = "tbl_df")
} else {
  assert_assembled_resp(test_assembled[["TB"]], expected_class = "data.frame")
}

###############################################################################
# Single-input assembly should work through the same backend-aware path.
test_single_input <-
  prepare_phoenix_data(
    fio2 = prepared_fio2[["DT"]],
    resp.lookback = 360,
    verbose = FALSE
  )

test_single_input <- sort_phxdata(test_single_input, id.vars = id.vars, eclock = eclock)
if (inherits(prepared_fio2[["DT"]], "data.table")) {
  stopifnot(
    inherits(test_single_input, "data.table"),
    identical(test_single_input[["FIO2"]], 0.30),
    isTRUE(all.equal(test_single_input[["FIO2_eclock"]], 0))
  )
} else {
  stopifnot(
    inherits(test_single_input, "data.frame"),
    identical(test_single_input[["FIO2"]], 0.30),
    isTRUE(all.equal(test_single_input[["FIO2_eclock"]], 0))
  )
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
# MAP selection should preserve the original source-priority behavior by default,
# but allow freshness-first selection and SBP/DBP pairing limits when requested.
map_base <-
  data.frame(
    hospital = "H1",
    patient = "P1",
    encounter = "E1",
    minutes_from_admission = 0,
    value = 40,
    stringsAsFactors = FALSE
  )
map_newer <-
  data.frame(
    hospital = "H1",
    patient = "P1",
    encounter = "E1",
    minutes_from_admission = 50,
    value = 60,
    stringsAsFactors = FALSE
  )

mapa_df <- map_base
mapc_df <- map_newer
names(mapa_df)[names(mapa_df) == "value"] <- "mapa"
names(mapc_df)[names(mapc_df) == "value"] <- "mapc"

prepared_mapa <-
  prepare_mean_arterial_pressure_arterial(
    x = mapa_df,
    id.vars = id.vars,
    eclock = eclock,
    value.var = "mapa",
    verbose = FALSE
  )
prepared_mapc <-
  prepare_mean_arterial_pressure_cuff(
    x = mapc_df,
    id.vars = id.vars,
    eclock = eclock,
    value.var = "mapc",
    verbose = FALSE
  )

map_original <-
  prepare_phoenix_data(
    mean_arterial_pressure_arterial = prepared_mapa,
    mean_arterial_pressure_cuff = prepared_mapc,
    bp.lookback = 360,
    verbose = FALSE
  )
map_original <-
  sort_phxdata(map_original, id.vars = id.vars, eclock = eclock)
idx_50 <- which(map_original[[eclock]] == 50)
stopifnot(
  identical(map_original[["MAP"]][idx_50], 40),
  identical(map_original[["MAP_source"]][idx_50], "MAPA"),
  isTRUE(all.equal(map_original[["MAP_eclock"]][idx_50], 0))
)

map_fresh <-
  prepare_phoenix_data(
    mean_arterial_pressure_arterial = prepared_mapa,
    mean_arterial_pressure_cuff = prepared_mapc,
    bp.lookback = 360,
    map.delta = 0,
    verbose = FALSE
  )
map_fresh <- sort_phxdata(map_fresh, id.vars = id.vars, eclock = eclock)
idx_50 <- which(map_fresh[[eclock]] == 50)
stopifnot(
  identical(map_fresh[["MAP"]][idx_50], 60),
  identical(map_fresh[["MAP_source"]][idx_50], "MAPC"),
  isTRUE(all.equal(map_fresh[["MAP_eclock"]][idx_50], 50))
)

sbp_df <-
  data.frame(
    hospital = "H1",
    patient = "P1",
    encounter = "E1",
    minutes_from_admission = 10,
    sbpa = 90,
    stringsAsFactors = FALSE
  )
dbp_df <-
  data.frame(
    hospital = "H1",
    patient = "P1",
    encounter = "E1",
    minutes_from_admission = 50,
    dbpa = 30,
    stringsAsFactors = FALSE
  )
prepared_sbpa <-
  prepare_sbp_arterial(
    x = sbp_df,
    id.vars = id.vars,
    eclock = eclock,
    value.var = "sbpa",
    verbose = FALSE
  )
prepared_dbpa <-
  prepare_dbp_arterial(
    x = dbp_df,
    id.vars = id.vars,
    eclock = eclock,
    value.var = "dbpa",
    verbose = FALSE
  )

map_from_old_pair <-
  prepare_phoenix_data(
    sbp_arterial = prepared_sbpa,
    dbp_arterial = prepared_dbpa,
    bp.lookback = 360,
    verbose = FALSE
  )
map_from_old_pair <-
  sort_phxdata(map_from_old_pair, id.vars = id.vars, eclock = eclock)
idx_50 <- which(map_from_old_pair[[eclock]] == 50)
stopifnot(
  isTRUE(all.equal(map_from_old_pair[["MAP"]][idx_50], 50)),
  identical(map_from_old_pair[["MAP_source"]][idx_50], "SBPA_DBPA")
)

map_reject_old_pair <-
  prepare_phoenix_data(
    sbp_arterial = prepared_sbpa,
    dbp_arterial = prepared_dbpa,
    bp.lookback = 360,
    map.sdbp.delta = 0,
    verbose = FALSE
  )
map_reject_old_pair <-
  sort_phxdata(map_reject_old_pair, id.vars = id.vars, eclock = eclock)
idx_50 <- which(map_reject_old_pair[[eclock]] == 50)
stopifnot(
  is.na(map_reject_old_pair[["MAP"]][idx_50]),
  is.na(map_reject_old_pair[["MAP_source"]][idx_50])
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

###############################################################################
# Constructed variables should carry source eclocks.  The source eclock is not
# the row's time point; it is the time of the observed value that supports the
# constructed variable after LOCF.  This mirrors the historical timecourse SQL.
constructed_df <-
  data.frame(
    hospital = "H1",
    patient = "P1",
    encounter = "E1",
    minutes_from_admission = c(0, 30, 60, 90, 120, 150),
    stringsAsFactors = FALSE
  )

prepared_paw_vent <-
  prepare_mean_airway_pressure_ventilator(
    x = transform(constructed_df[1, ], value = 5),
    id.vars = id.vars,
    eclock = eclock,
    value.var = "value",
    verbose = FALSE
  )

prepared_paw_hfov <-
  prepare_mean_airway_pressure_hfov(
    x = transform(constructed_df[2, ], value = 7),
    id.vars = id.vars,
    eclock = eclock,
    value.var = "value",
    verbose = FALSE
  )

prepared_peep <-
  prepare_positive_end_expiratory_pressure(
    x = transform(constructed_df[3, ], value = 6),
    id.vars = id.vars,
    eclock = eclock,
    value.var = "value",
    verbose = FALSE
  )

prepared_o2support <-
  prepare_o2support(
    x = transform(constructed_df[4, ], value = 1),
    id.vars = id.vars,
    eclock = eclock,
    value.var = "value",
    verbose = FALSE
  )

prepared_pupilleft <-
  prepare_pupilleft(
    x = transform(constructed_df[5, ], value = 1),
    id.vars = id.vars,
    eclock = eclock,
    value.var = "value",
    verbose = FALSE
  )

prepared_pupilright <-
  prepare_pupilright(
    x = transform(constructed_df[6, ], value = 1),
    id.vars = id.vars,
    eclock = eclock,
    value.var = "value",
    verbose = FALSE
  )

test_constructed_eclocks <-
  prepare_phoenix_data(
    mean_airway_pressure_ventilator = prepared_paw_vent,
    mean_airway_pressure_hfov = prepared_paw_hfov,
    positive_end_expiratory_pressure = prepared_peep,
    o2support = prepared_o2support,
    pupilleft = prepared_pupilleft,
    pupilright = prepared_pupilright,
    resp.lookback = 360,
    pupil.lookback = 360,
    verbose = FALSE
  )
test_constructed_eclocks <-
  sort_phxdata(test_constructed_eclocks, id.vars = id.vars, eclock = eclock)

stopifnot(
  isTRUE(
    all.equal(
      test_constructed_eclocks[["IMV_eclock"]],
      c(0, 30, 60, 60, 60, 60)
    )
  ),
  isTRUE(
    all.equal(
      test_constructed_eclocks[["ORS_eclock"]],
      c(0, 30, 60, 90, 90, 90)
    )
  ),
  isTRUE(
    all.equal(
      test_constructed_eclocks[["FIXEDPUPILS_eclock"]],
      c(NA, NA, NA, NA, NA, 150)
    )
  )
)

################################################################################
#                                 End of File                                  #
################################################################################
