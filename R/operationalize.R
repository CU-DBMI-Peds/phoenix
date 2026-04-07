#' Prepare Observation, Interventions, Event, Medications, Tests for Phoenix
#' Scoring
#'
#' Functions for checking the basic structure and values for the input data for
#' Assessing Phoenix.
#'
#' The input data is expected to be in a "long" format with \code{id.vars}
#' (examples: hospital id, patient id, encounter id). A column for reporting the
#' amount of time from admission, \code{eclock}
#' ('encounter clock'; generally expected to be in minutes with 0 being the encounter start).
#' \code{value.var} denotes the reported values for the input of interest.
#' \code{valid.range} and \code{valid.values} are used for simple checks for
#' valid values.  Only one of the two can be specified.  The checks are
#' \code{x[[value.var]] >= min(valid.range) & x[[value.var]] <= max(valid.range)}
#' or \code{x[[value.var]] \%in\% valid.values}.
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
#' @param valid.range A numeric vector of length two defining an interval of
#' valid values for \code{x[[value.var]]}. The defaults are set to be
#' considerably wider than clinically possible in some cases, e.g., infinite
#' upper limit for blood pressures.  Only one of \code{valid.range} and
#' \code{valid.values} is allowed to be non-NULL.
#'
#' @param valid.values A set of values which \code{x[[value.var]]} can take on,
#' example, indicators are checked againt \code{c(0, 1)} and GCS Total is
#' checked against 3:15. Only one of \code{valid.range} and \code{valid.values}
#' is allowed to be non-NULL.
#'
#' @param tie.breaker When \code{x[c(id.vars, eclock)]} is not unique this
#' function is uses to aggregate \code{x[[value.var]]} into one value.
#'
#' @param verbose when \code{TRUE} print messages showing the progress
#'
#' @name prepare_inputs
NULL

#' @rdname prepare_inputs
#' @export
prepare_fio2 <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0.21, 1.00),
    valid.values = NULL,
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["variable.name"]] <- "FIO2"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_fio2", class(rtn))
  rtn
}

#' @rdname prepare_inputs
#' @export
prepare_spo2 <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, 100),
    valid.values = NULL,
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["variable.name"]] <- "SPO2"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_spo2", class(rtn))
  rtn
}

#' @rdname prepare_inputs
#' @export
prepare_pao2 <-
  function(
    x,
    id.vars,
    eclock,
    value.var,
    valid.range = c(0, Inf),
    valid.values = NULL,
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  cl[["variable.name"]] <- "PAO2"
  rtn <- eval(cl)
  class(rtn) <- c("phoenix_prepared_pao2", class(rtn))
  rtn
}


#' Prepare Phoenix Data
#'
#' Take the outputs from the \code{prepare_*()} and create the longitudinal data
#' set needed for assessing Phoenix Sepsis.
#'
#' @param fio2 an object returned from \code{prepare_fio2()}
#' @param spo2 an object returned from \code{prepare_spo2()}
#' @param pao2 an object returned from \code{prepare_pao2()}
#'
#' @param resp_lookback The number of minutes to look back in an encounter for carry-forward respiratory values, e.g., FIO2, SPO2, IMV, ...
#' @param vaso_lookback The number of minutes to look back in an encounter for carry-forward vasocactive medication status
#' @param map_lookback The number of minutes to look back in an encounter for carry-forward blood pressure values
#' @param lac_lookback The number of minutes to look back in an encounter for carry-forward of lactate values
#' @param gcs_lookback The number of minutes to look back in an encounter for carry-forward of GCS (Eye, Verbal, Motor, and Total).
#' @param pupil_lookback The number of minutes to look back in an encounter for carry-forwared of pupil status (fixed or unfixed)
#' @param coag_lookback The number of minutes to look back in an encounter for carry-forward of coagulation variables: fibrinogen, platteles, INR, and D-Dimer.
#'
#' @param verbose when \code{TRUE} print messages showing the progress
#'
#' @export
prepare_phoenix_data <-
  function(
    fio2 = NULL,
    spo2 = NULL,
    pao2 = NULL,
    resp_lookback  = 360,
    vaso_lookback  = 720,
    map_lookback   = 360,
    lac_lookback   = 360,
    gcs_lookback   = 360,
    pupil_lookback = 720,
    coag_lookback  = 1440,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  stopifnot(is.numeric(resp_lookback)  && length(resp_lookback)  == 1 && resp_lookback >= 0)
  stopifnot(is.numeric(vaso_lookback)  && length(vaso_lookback)  == 1 && vaso_lookback >= 0)
  stopifnot(is.numeric(map_lookback)   && length(map_lookback)   == 1 && map_lookback >= 0)
  stopifnot(is.numeric(gcs_lookback)   && length(gcs_lookback)   == 1 && gcs_lookback >= 0)
  stopifnot(is.numeric(pupil_lookback) && length(pupil_lookback) == 1 && pupil_lookback >= 0)
  stopifnot(is.numeric(coag_lookback)  && length(coag_lookback)  == 1 && coag_lookback >= 0)

  phxdata <-
    list(
      fio2 = fio2,
      spo2 = spo2,
      pao2 = pao2
    )
  phxdata <- Filter(f = Negate(is.null), phxdata)

  # verify that all the input data sets are either null or phoenix_prepared
  check <-
    Map(f = function(obj, cls) { is.null(obj) || inherits(obj, cls) },
      obj = phxdata,
      cls = paste0("phoenix_prepared_", tolower(names(phxdata)))
    )
  check <- unlist(check)

  if (!all(check)) {
    msg <- paste0("The input to ", names(check)[!check], " needs to be processed through prepare_", tolower(names(check)[!check]), "().  ")
    stop(msg)
  }

  # check that all the inputs have the same id.vars and eclocks
  id.vars <- unique(lapply(phxdata, attr, "id.vars"))
  if (length(id.vars) > 1L) {
    stop("All input data sets need to have the same id.vars")
  }
  id.vars <- unlist(id.vars)

  eclock <- unique(lapply(phxdata, attr, "eclock"))
  if (length(eclock) > 1L) {
    stop("All input data sets need to have the same eclock")
  }
  eclock <- unlist(eclock)

  # stack, cast, and sort
  f <- sprintf("%s ~ variable", paste(c(id.vars, eclock), collapse = "+"))
  if (verbose) message("stacking data...")
  phxdata <- phxdft_rbindlist(x = phxdata)
  if (verbose) message("casting data....")
  phxdata <- phxdft_dcast(data = phxdata, formula = f, value.var = "value")
  if (verbose) message("sorting data...")
  phxdata <- phxdft_setorder(phxdata, c(id.vars, eclock))

  # locf
  if (verbose) message("locf....")

  row <- seq_len(nrow(phxdata))
  id <- phxdft_select(phxdata, cols = id.vars)
  id <- do.call(paste, c(id, sep = "\r\r"))

  for (j in c("FIO2", "SPO2", "PAO2")) {
    if (j %in% names(phxdata)) {
      if (verbose) message(sprintf("   %s...", j))
      obs <- !is.na(phxdata[[j]])
      last_obs <- cummax(ifelse(obs, row, 0L))
      ok <- last_obs > 0L
      ok[ok] <- id[last_obs[ok]] == id[ok]
      out <- phxdata[[j]]
      out[ok] <- out[last_obs[ok]]

      outeclock <- NA
      outeclock[ok] <- phxdata[[eclock]][last_obs[ok]]

      phxdata <- phxdft_set(phxdata, j = j, value = out)
      phxdata <- phxdft_set(phxdata, j = paste0(j, "_eclock"), value = outeclock)

      if (j %in% c("FIO2", "SPO2", "PAO2")) {
        idx <- which((phxdata[[eclock]] - phxdata[[paste0(j, "_eclock")]]) > resp_lookback)
        phxdata <- phxdft_set(phxdata, i = idx, j = j, value = NA)
        phxdata <- phxdft_set(phxdata, i = idx, j = paste0(j, "_eclock"), value = NA)
      }

    }
  }

  phxdata
}


################################################################################
# Non exported functions

verify_id_vars <- function(names, id.vars) {
  stopifnot(is.character(id.vars))
  stopifnot(length(id.vars) > 0L)
  not_in_names <- id.vars[!(id.vars %in% names)]

  if (length(not_in_names)) {
    stop(sprintf("There are id.vars not in the names of the input data.frame. Value(s) not found: %s", paste(not_in_names, collapse = ", ")))
  }
  invisible(TRUE)
}

verify_elcock <- function(x, eclock) {
  stopifnot(is.character(eclock))
  stopifnot(length(eclock) == 1L)
  if (is.null(x[[eclock]])) {
    stop(sprintf("%s[[%s]] is null.", deparse(substitute(x)), eclock))
  }
  if (!is.numeric(x[[eclock]])) {
    stop(sprintf("%s[[%s]] is expected to be a numeric vector, preferably integer valued.", deparse(substitute(x)), eclock))
  }
  invisible(TRUE)
}

match.call.with.defaults <- expression({
  cl <- as.list(match.call())
  f <- formals()
  addtocl <- setdiff(names(f), names(cl))
  cl[addtocl] <- f[addtocl]
  cl <- as.call(cl)
})

prepare_variable <-
  function(
    x,
    id.vars,
    value.var,
    variable.name,
    valid.range = NULL,
    valid.values = NULL,
    eclock = "eclock",
    tie.breaker = NULL,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  stopifnot(inherits(x, "data.frame"))
  stopifnot(is.character(value.var))
  stopifnot(value.var %in% names(x))

  xv <- sprintf("%s[['%s']]", deparse1(substitute(x)), value.var)

  if (any(is.na(x[[value.var]]))) {
    msg <- sprintf("All values in %s are expected to be non-missing.", xv)
    stop(msg, call. = FALSE)
  }

  if (!is.null(valid.range) & !is.null(valid.values)) {
    stop("Only one of valid.range and valid.values should be provided")
  } else if (!is.null(valid.range)) {
    below <- any(x[[value.var]] < min(valid.range))
    above <- any(x[[value.var]] > max(valid.range))
    if (below | above) {
      bmsg <- sprintf("%s < %f", xv, min(valid.range))
      amsg <- sprintf("%s > %f", xv, max(valid.range))
      if (below & above) {
        msg <- sprintf("There are %s and %s.", bmsg, amsg)
      } else if (below) {
        msg <- sprintf("There are %s.", bmsg)
      } else if (above) {
        msg <- sprintf("There are %s.", amsg)
      }
      stop(msg, call. = FALSE)
    }
  } else if (!is.null(valid.values)) {
    out <- !all(x[[value.var]] %in% valid.values)
    if (out) {
      stop(sprintf("There are %s not in the valid.range.", xv), call. = FALSE)
    }
  } else {
    msg <- sprintf("%s values not validated.", xv)
    warning(msg, call. = FALSE)
  }

  verify_id_vars(names(x), id.vars)

  verify_elcock(x, eclock)

  # check for duplicated id vars
  dups <-
    phxdft_duplicated(x, by = c(id.vars, eclock)) |
    phxdft_duplicated(x, by = c(id.vars, eclock), fromLast = TRUE)

  if (any(dups)) {
    if (verbose) {
      message(sprintf("Duplicate rows in %s based on c(%s). Aggregating....",
          deparse1(substitute(x)),
          paste(paste0("'", c(id.vars, eclock), "'"), collapse = ", ")))
    }
    if (!all(dups)) {
      xs <- split(x, f = dups)
      xs[["FALSE"]] <- phxdft_select(xs[["FALSE"]], c(id.vars, eclock, value.var))
      xs[["TRUE"]] <- phxdft_aggregate(value.var, by = c(id.vars, eclock), data = xs[["TRUE"]], FUN = tie.breaker)
      x <- do.call(rbind, xs)
    } else {
      x <- phxdft_aggregate(value.var, by = c(id.vars, eclock), data = x, FUN = tie.breaker)
    }
  } else {
    if (verbose) {
      message(sprintf("No duplicate rows in %s based on c(%s).",
          deparse1(substitute(x)),
          paste0("'", paste(c(id.vars, eclock), collapse = ", "), "'")))
    }
    # in if(any(dups), if x is a data.table then the splits and the aggregations
    # will result in a "new" data.table.  If no dups, then the data.table needs
    # to be copied before changing names and mutating the object
    if (inherits(x, "data.table") && requireNamespace("data.table", quietly = TRUE)) {
      x <- getExportedValue(ns = "data.table", name = "copy")(x)
    }
  }

  if (value.var != "value") {
    x <- phxdft_setnames(x, old = value.var, new = "value")
  }

  x <- phxdft_set(x, j = "variable", value = variable.name)

  attr(x, "id.vars") <- id.vars
  attr(x, "eclock") <- eclock
  class(x) <- c("phoenix_prepared", class(x))

  x
}

