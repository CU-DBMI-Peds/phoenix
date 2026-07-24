library(phoenix)
source("utilities.R")

################################################################################
# file: tests/test-score-prepared-phoenix-data.R
#
# End-to-end tests for the operationalization workflow:
#   prepare_<input>() -> prepare_phoenix_data() -> score_prepared_phoenix_data()
#
# The fixture has two encounters.  E1 has suspected infection and organ
# dysfunction across all Phoenix/Phoenix-8 systems.  E2 has no suspected
# infection, so it should be carried through the output but not scored.
################################################################################

id.vars <- c("hospital", "patient", "encounter")
eclock <- "minutes_from_admission"

make_observations <- function(value.var, values) {
  x <-
    data.frame(
      hospital = c("H1", "H1"),
      patient = c("P1", "P2"),
      encounter = c("E1", "E2"),
      minutes_from_admission = c(0, 0),
      value = values,
      stringsAsFactors = FALSE
    )
  names(x)[names(x) == "value"] <- value.var
  x
}

backend_data <- function(x, backend) {
  make_backends(x)[[backend]]
}

prepare_range_input <- function(fun, value.var, values, backend) {
  do.call(
    what = fun,
    args =
      list(
        x = backend_data(make_observations(value.var, values), backend),
        id.vars = id.vars,
        eclock = eclock,
        value.var = value.var,
        verbose = FALSE
      )
  )
}

prepare_age_input <- function(backend) {
  prepare_age(
    x = backend_data(make_observations("age_months", c(24, 24)), backend),
    id.vars = id.vars,
    value.var = "age_months",
    verbose = FALSE
  )
}

build_prepared_end_to_end <- function(backend) {
  prepare_phoenix_data(
    fio2 = prepare_range_input(prepare_fio2, "fio2", c(0.50, 0.21), backend),
    spo2 = prepare_range_input(prepare_spo2, "spo2", c(90, 99), backend),
    mean_airway_pressure_ventilator = prepare_range_input(prepare_mean_airway_pressure_ventilator, "vent", c(0, 0), backend),
    mean_airway_pressure_hfov = prepare_range_input(prepare_mean_airway_pressure_hfov, "hfov", c(0, 0), backend),
    positive_end_expiratory_pressure = prepare_range_input(prepare_positive_end_expiratory_pressure, "peep", c(0, 0), backend),
    invasive_mechanical_ventilation_indicator =
      prepare_range_input(
        prepare_invasive_mechanical_ventilation_indicator,
        "invasive_mechanical_ventilation",
        c(1, 0),
        backend
      ),
    o2support = prepare_range_input(prepare_o2support, "o2support", c(0, 0), backend),
    dopamine = prepare_range_input(prepare_dopamine, "dopamine", c(1, 0), backend),
    mean_arterial_pressure_arterial =
      prepare_range_input(
        prepare_mean_arterial_pressure_arterial,
        "mean_arterial_pressure_arterial",
        c(50, 70),
        backend
      ),
    gcseye = prepare_range_input(prepare_gcseye, "gcseye", c(2, 4), backend),
    gcsverbal = prepare_range_input(prepare_gcsverbal, "gcsverbal", c(3, 5), backend),
    gcsmotor = prepare_range_input(prepare_gcsmotor, "gcsmotor", c(4, 6), backend),
    pupils = prepare_range_input(prepare_pupils, "pupils", c(0, 0), backend),
    platelets = prepare_range_input(prepare_platelets, "platelets", c(80, 200), backend),
    glucose = prepare_range_input(prepare_glucose, "glucose", c(160, 100), backend),
    anc = prepare_range_input(prepare_anc, "anc", c(0.4, 2.0), backend),
    creatinine = prepare_range_input(prepare_creatinine, "creatinine", c(0.7, 0.3), backend),
    bilirubin = prepare_range_input(prepare_bilirubin, "bilirubin", c(4.0, 0.5), backend),
    antimicrobials =
      prepare_range_input(prepare_antimicrobials, "antimicrobials", c(1, 1), backend),
    antiinfectioustests =
      prepare_range_input(prepare_antiinfectioustests, "antiinfectioustests", c(1, 0), backend),
    age = prepare_age_input(backend),
    verbose = FALSE
  )
}

expected_prepared_class <- function(backend) {
  if (backend == "DT" && requireNamespace("data.table", quietly = TRUE)) {
    "data.table"
  } else if (backend == "TB" &&
             requireNamespace("dplyr", quietly = TRUE) &&
             requireNamespace("tidyr", quietly = TRUE) &&
             packageVersion("dplyr") >= "1.1.0" &&
             packageVersion("tidyr") >= "1.0.0") {
    "tbl_df"
  } else {
    "data.frame"
  }
}

sort_by_encounter <- function(x) {
  x[order(x[["encounter"]]), , drop = FALSE]
}

assert_end_to_end <- function(backend) {
  prepared <- build_prepared_end_to_end(backend)
  prepared <- sort_by_encounter(prepared)

  stopifnot(
    inherits(prepared, "prepared_phoenix_data"),
    inherits(prepared, expected_prepared_class(backend)),
    identical(prepared[["SUSPECTED_INFECTION"]], c(1L, 0L)),
    identical(prepared[["IMV"]], c(1L, 0L)),
    identical(prepared[["ORS"]], c(1L, 0L)),
    isTRUE(all.equal(prepared[["SFR"]], c(180, NA))),
    isTRUE(all.equal(prepared[["GCS"]], c(9, 15))),
    identical(prepared[["FIXEDPUPILS"]], c(0L, 0L))
  )

  scored <- score_prepared_phoenix_data(prepared, T0 = 0, T1 = 1440, verbose = FALSE)
  scored <- sort_by_encounter(scored)

  stopifnot(
    inherits(scored, "scored_prepared_phoenix_data"),
    inherits(scored, expected_prepared_class(backend)),
    identical(scored[["suspected_infection"]], c(1L, 0L)),
    isTRUE(all.equal(scored[["phoenix_sepsis_score"]][1], 5)),
    isTRUE(all.equal(scored[["phoenix_sepsis"]][1], 1)),
    isTRUE(all.equal(scored[["phoenix_septic_shock"]][1], 1)),
    isTRUE(all.equal(scored[["phoenix8_sepsis_score"]][1], 9)),
    is.na(scored[["phoenix_sepsis_score"]][2]),
    is.na(scored[["phoenix_sepsis"]][2]),
    is.na(scored[["phoenix_septic_shock"]][2]),
    is.na(scored[["phoenix8_sepsis_score"]][2])
  )

  olm <- score_prepared_phoenix_data(prepared, T0 = 0, T1 = 1440, aggregation = "olm", verbose = FALSE)
  olm <- sort_by_encounter(olm)

  ccd <- score_prepared_phoenix_data(prepared, T0 = 0, T1 = 1440, aggregation = "ccd", verbose = FALSE)
  ccd <- sort_by_encounter(ccd)

  stopifnot(
    isTRUE(all.equal(olm[["olm_sepsis_score"]][1], 5)),
    isTRUE(all.equal(olm[["olm_sepsis"]][1], 1)),
    isTRUE(all.equal(olm[["olm_septic_shock"]][1], 1)),
    isTRUE(all.equal(olm[["olm_8_sepsis_score"]][1], 9)),
    isTRUE(all.equal(ccd[["ccd_sepsis_score"]][1], 5)),
    isTRUE(all.equal(ccd[["ccd_sepsis"]][1], 1)),
    isTRUE(all.equal(ccd[["ccd_septic_shock"]][1], 1)),
    isTRUE(all.equal(ccd[["ccd_8_sepsis_score"]][1], 9))
  )
}

invisible(lapply(c("DF", "DT", "TB"), assert_end_to_end))

################################################################################
#                                 End of File                                  #
################################################################################
