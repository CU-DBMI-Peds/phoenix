#' Prepare Discrete Observation, Intervention, Event, and Test Inputs for
#' Phoenix Scoring
#'
#' Functions for checking the basic structure and values for Phoenix inputs with
#' fixed allowable values.
#'
#' The input data is expected to be in a "long" format with \code{id.vars}
#' (examples: hospital id, patient id, encounter id). A column for reporting the
#' amount of time from admission, \code{eclock}
#' ('encounter clock'; generally expected to be in minutes with 0 being the encounter start).
#' \code{value.var} denotes the reported values for the input of interest.
#'
#' These functions validate against input-specific fixed allowable values such
#' as \code{c(0, 1)} for indicators or the known score sets for GCS
#' components/subscores. End users are not expected to change those allowable
#' values.
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
#' medicaiton, or test.
#'
#' @param tie.breaker When \code{x[c(id.vars, eclock)]} is not unique this
#' function is uses to aggregate \code{x[[value.var]]} into one value.
#'
#' @param verbose when \code{TRUE} print messages showing the progress
#'
#' @name prepare_inputs_discrete
NULL

#' @rdname prepare_inputs_discrete
#' @export
prepare_imv <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "IMV"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_imv", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_o2support <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "O2SUPPORT"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_o2support", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_dobutamine <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "DOBUTAMINE"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_dobutamine", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_dopamine <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "DOPAMINE"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_dopamine", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_epinephrine <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "EPINEPHRINE"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_epinephrine", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_milrinone <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "MILRINONE"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_milrinone", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_norepinephrine <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "NOREPINEPHRINE"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_norepinephrine", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_vasopressin <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "VASOPRESSIN"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_vasopressin", class(rtn))
  rtn
}


#' @rdname prepare_inputs_discrete
#' @export
prepare_gcseye <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(1, 2, 3, 4)
  cl[["variable.name"]] <- "GCSEYE"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_gcseye", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_gcsmotor <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(1, 2, 3, 4, 5, 6)
  cl[["variable.name"]] <- "GCSMOTOR"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_gcsmotor", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_gcsverbal <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(1, 2, 3, 4, 5)
  cl[["variable.name"]] <- "GCSVERBAL"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_gcsverbal", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_gcstotal <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
  cl[["variable.name"]] <- "GCSTOTAL"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_gcstotal", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_pupilleft <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "PUPILLEFT"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_pupilleft", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_pupilright <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "PUPILRIGHT"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_pupilright", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_pupils <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "PUPILS"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_pupils", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_antimicrobials <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "ANTIMICROBIALS"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_antimicrobials", class(rtn))
  rtn
}

#' @rdname prepare_inputs_discrete
#' @export
prepare_antiinfectioustests <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", interactive())
  ) {
  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["valid.values"]] <- c(0, 1)
  cl[["variable.name"]] <- "ANTIINFECTIOUSTESTS"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_antiinfectioustests", class(rtn))
  rtn
}
