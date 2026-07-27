#' Prepare Continuous Observation, Intervention, Medication, and Test Inputs for
#' Phoenix Scoring
#'
#' Functions for checking the basic structure and values for the input data for
#' Assessing Phoenix.
#'
#' The input data is expected to be in a "long" format with \code{id.vars}
#' (examples: hospital id, patient id, encounter id). A column for reporting the
#' amount of time from admission, \code{eclock}
#' ('encounter clock'; generally expected to be in minutes with 0 being the encounter start).
#' \code{value.var} denotes the reported values for the input of interest.
#' \code{valid.range} is used for simple inclusive checks for valid values via
#' \code{x[[value.var]] >= min(valid.range) & x[[value.var]] <= max(valid.range)}.
#' \code{prepare_age()} is the exception; its default upper limit is exclusive
#' to match the expected age interval of [0, 216) months.
#'
#' There is an expectation when going to Phoenix scoring that the
#' \code{x[[c(id.vars, eclock)]]} are unique for each input.  These functions
#' check this assumption and will aggregate, if needed, using the
#' \code{tie.breaker} method.
#'
#' Every function below is a thin wrapper around `prepare_variable()`.  The
#' wrapper's main job is to provide the Phoenix-internal variable name, the
#' clinically expected range, and a duplicate-row tie breaker.  For example,
#' `prepare_spo2()` maps a user-supplied value column to the internal column
#' `SPO2`, checks that values are between 0 and 100, and uses the lower value
#' when duplicate SpO2 values are reported for the same encounter/time.
#'
#' These wrappers are intentionally repetitive.  Keeping each input explicit
#' makes it easier for analysts to confirm which raw EHR field maps to which
#' Phoenix definition and TeX equation.
#'
#' Default values match the values used when developing the Phoenix Sepsis
#' Criteria, see Sanchez-Pinto, Bennett, DeWitt, Russell, et al. (2024). End
#' users can modify these checks by passing a different \code{valid.range}.
#'
#' @references See reference details in \code{\link{phoenix-package}} or by calling
#' \code{citation('phoenix')}.
#'
#' @inheritParams prepare_variable
#'
#' @name prepare_inputs_range
NULL

#' @rdname prepare_inputs_range
#' @export
prepare_fio2 <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0.21, 1.00),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: respiratory EHR input \fiotwo; used in eq:pfr, eq:sfr, and eq:imv-conditions-part2.

  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "FIO2",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_fio2", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_spo2 <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, 100),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: respiratory EHR input \spotwo; used in eq:sfr.

  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "SPO2",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_spo2", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_pao2 <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: respiratory EHR input \paotwo; used in eq:pfr.

  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PAO2",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_pao2", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_mean_airway_pressure_ventilator <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: respiratory EHR input \pawvent, used in eq:imv-conditions.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PAW_VENT",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_mean_airway_pressure_ventilator", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_mean_airway_pressure_hfov <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: respiratory EHR input \pawhfov, used in eq:imv-conditions.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PAW_HFOV",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_mean_airway_pressure_hfov", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_positive_end_expiratory_pressure <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, 100),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: respiratory EHR input \pawpeep, used in eq:imv-conditions.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PAW_PEEP",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_positive_end_expiratory_pressure", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_lactate <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, 50),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular EHR input Lactate; used in eq:lactate.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "LACTATE",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_lactate", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_sbp_cuff <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(1, 300),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular EHR input \sbpc; used in eq:map-candidates.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "SBPC",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_sbp_cuff", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_sbp_arterial <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(1, 300),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular EHR input \sbpa; used in eq:map-candidates.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "SBPA",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_sbp_arterial", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_dbp_cuff <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(1, 200),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular EHR input \dbpc; used in eq:map-candidates.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "DBPC",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_dbp_cuff", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_dbp_arterial <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(1, 200),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular EHR input \dbpa; used in eq:map-candidates.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "DBPA",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_dbp_arterial", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_mean_arterial_pressure_cuff <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(1, 300),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular EHR input \mapc; used in eq:map-candidates and eq:map-priority.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "MAPC",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_mean_arterial_pressure_cuff", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_mean_arterial_pressure_arterial <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(1, 300),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular EHR input \mapa; used in eq:map-candidates and eq:map-priority.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "MAPA",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_mean_arterial_pressure_arterial", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_platelets <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: coagulation EHR input Platelets; used in eq:coag-component-platelets.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PLATELETS",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_platelets", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_inr <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: coagulation EHR input INR; used in eq:coag-component-inr.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "INR",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_inr", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_ddimer <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, 500),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: coagulation EHR input DDimer; used in eq:coag-component-ddimer.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "DDIMER",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_ddimer", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_fibrinogen <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: coagulation EHR input Fibrinogen; used in eq:coag-component-fibrinogen.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "FIBRINOGEN",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_fibrinogen", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_glucose <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(5, 2000),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: endocrine EHR input Glucose; used in eq:endo.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "GLUCOSE",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_glucose", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_anc <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: immunologic EHR input ANC; used in eq:anc and eq:immu.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "ANC",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_anc", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_alc <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: immunologic EHR input ALC; used in eq:alc and eq:immu.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "ALC",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_alc", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_creatinine <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, 50),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: renal EHR input Creatinine; used in eq:renal-score.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "CREATININE",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_creatinine", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_bilirubin <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, 100),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: hepatic EHR input Bilirubin; used in eq:bilirubin and eq:hepatic.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "BILIRUBIN",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_bilirubin", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_alt <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.range.closed = c(TRUE, TRUE),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: hepatic EHR input ALT; used in eq:alt and eq:hepatic.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "ALT",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_alt", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_age <-
  function(
    x,
    id.vars,
    value.var,
    valid.range = c(0, 216),
    valid.range.closed = c(TRUE, FALSE),
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  # TeX: cardiovascular and renal EHR input Age; used in eq:theta1, eq:theta2, eq:map, and eq:renal-score.
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      value.var = value.var,
      variable.name = "AGE",
      valid.range = valid.range,
      valid.range.closed = valid.range.closed,
      tie.breaker = tie.breaker,
      verbose = verbose
  )
  rtn <- phxdft_set(rtn, j = "variable", value = NULL)
  rtn <- phxdft_setnames(rtn, old = "value", new = "AGE")
  rtn <- phxdft_select(rtn, c(id.vars, "AGE"))
  # phxdft_select() returns a new subset object and base data.frame subsetting
  # drops custom attributes.  Age is static per encounter, so keep only id.vars
  # and AGE, then restore the preparation contract expected downstream.
  attr(rtn, "id.vars") <- id.vars
  attr(rtn, "eclock") <- NULL
  class(rtn) <- c("phoenix_prepared_age", class(rtn))
  rtn
}
