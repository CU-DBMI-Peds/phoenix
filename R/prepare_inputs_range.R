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
#' \code{valid.range} is used for simple checks for valid values via
#' \code{x[[value.var]] >= min(valid.range) & x[[value.var]] <= max(valid.range)}.
#'
#' There is an expectation when going to Phoenix scoring that the
#' \code{x[[c(id.vars, eclock)]]} are unique for each input.  These functions
#' check this assumption and will aggregate, if needed, using the
#' \code{tie.breaker} method.
#'
#' Default values are based on the values used when building the Phoenix
#' criteria, see Sanchez-Pinto, Bennett, DeWitt, Russell, et al. (2024).
#'
#' @references See reference details in \code{\link{phoenix-package}} or by calling
#' \code{citation('phoenix')}.
#'
#' @param x a data.frame, or object that inherits from a data.frame such as
#' data.table or tibble.
#'
#' @param id.vars a character vector, expected to be a at least length 1, of the
#' names of the columns of \code{x} to be used to identifiers, e.g., hospital
#' id, patient id, encounter id.
#'
#' @param eclock A character vector of length 1, the name of the column in
#' \code{x} denoting the time, in minutes, from admission start.
#'
#' @param value.var A character vector of length 1, the name of the column in
#' \code{x} containing the value for the observation, intervention, event,
#' medication, or test.
#'
#' @param valid.range A numeric vector of length two defining an interval of
#' valid values for \code{x[[value.var]]}. The defaults are set to be
#' considerably wider than clinically possible in some cases, e.g., infinite
#' upper limit for blood pressures.
#'
#' @param tie.breaker When \code{x[c(id.vars, eclock)]} is not unique this
#' function is uses to aggregate \code{x[[value.var]]} into one value.
#'
#' @param verbose when \code{TRUE} print messages showing the progress
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
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "FIO2",
      valid.range = valid.range,
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
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "SPO2",
      valid.range = valid.range,
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
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PAO2",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_pao2", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_vent <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "VENT",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_vent", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_hfov <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "HFOV",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_hfov", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_peep <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PEEP",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_peep", class(rtn))
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
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "LACTATE",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_lactate", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_sbpc <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "SBPC",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_sbpc", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_sbpa <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "SBPA",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_sbpa", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_dbpc <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "DBPC",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_dbpc", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_dbpa <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "DBPA",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_dbpa", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_mapc <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "MAPC",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_mapc", class(rtn))
  rtn
}

#' @rdname prepare_inputs_range
#' @export
prepare_mapa <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "MAPA",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  class(rtn) <- c("phoenix_prepared_mapa", class(rtn))
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
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "PLATELETS",
      valid.range = valid.range,
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
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "INR",
      valid.range = valid.range,
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
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "DDIMER",
      valid.range = valid.range,
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
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "FIBRINOGEN",
      valid.range = valid.range,
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
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "GLUCOSE",
      valid.range = valid.range,
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
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "ANC",
      valid.range = valid.range,
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
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "ALC",
      valid.range = valid.range,
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
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "CREATININE",
      valid.range = valid.range,
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
    valid.range = c(0, Inf),
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "BILIRUBIN",
      valid.range = valid.range,
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
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      eclock = eclock,
      value.var = value.var,
      variable.name = "ALT",
      valid.range = valid.range,
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
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  rtn <-
    prepare_variable(
      x = x,
      id.vars = id.vars,
      value.var = value.var,
      variable.name = "AGE",
      valid.range = valid.range,
      tie.breaker = tie.breaker,
      verbose = verbose
    )
  rtn <- phxdft_set(rtn, j = "variable", value = NULL)
  rtn <- phxdft_setnames(rtn, old = "value", new = "AGE")
  class(rtn) <- c("phoenix_prepared_age", class(rtn))
  rtn
}
