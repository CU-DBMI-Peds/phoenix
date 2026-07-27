# Prepare Utilities:
#
# Non exported functions used in
#
#   prepare_inputs_range
#   prepare_inputs_discrete
#   prepare_phoenix_data
#
# Notes:
#   These functions are internal to the package and not expected to be called by
#   end users.  End users should only be calling the `prepare_*()` functions.
#   The goal of this file is to centralize the repeated preparation rules so
#   every Phoenix input is checked and reshaped in the same way.

################################################################################

#' Verify Identifier Columns
#'
#' Internal helper used by the Phoenix preparation functions to confirm that the
#' requested encounter identifier columns exist in an input data frame.
#'
#' Phoenix inputs are prepared separately and later combined by
#' \code{\link{prepare_phoenix_data}}. The identifier columns are how those
#' separate inputs are aligned back to the same encounter. If a requested
#' identifier column is missing, the prepared inputs cannot be safely combined,
#' so this helper stops early with an informative error.
#'
#' @param names a character vector of available column names, usually
#'   \code{names(x)} for the input data frame being prepared.
#'
#' @param id.vars a character vector of one or more column names that should
#'   identify the encounter. Each value in \code{id.vars} must appear in
#'   \code{names}.
#'
#' @return Invisibly returns \code{TRUE} when all identifier columns are present.
#'   Otherwise, stops with an error.
#'
#' @noRd
#' @keywords internal
verify_id_vars <- function(names, id.vars) {
  # `id.vars` identifies an encounter.  It can be one column or several columns
  # such as site + patient + encounter.  Every requested ID column must exist in
  # the input data.
  stopifnot(is.character(id.vars))
  stopifnot(length(id.vars) > 0L)
  not_in_names <- id.vars[!(id.vars %in% names)]

  if (length(not_in_names)) {
    stop(sprintf("There are id.vars not in the names of the input data.frame. Value(s) not found: %s", paste(not_in_names, collapse = ", ")))
  }
  invisible(TRUE)
}

################################################################################

#' Verify Encounter Clock
#'
#' Internal helper used by the Phoenix preparation functions to confirm that the
#' encounter-clock column exists and is numeric.
#'
#' The encounter clock is the time scale used for sorting observations,
#' resolving duplicates, carrying values forward, and applying look-back
#' windows. It is usually measured in minutes from encounter start. A numeric
#' encounter clock is required before an input can be safely passed to
#' \code{\link{prepare_phoenix_data}}.
#'
#' @param x a data.frame, or an object that inherits from a data.frame such as a
#'   data.table or tibble.
#'
#' @param eclock a character vector of length one naming the encounter-clock
#'   column in \code{x}.
#'
#' @return Invisibly returns \code{TRUE} when \code{eclock} exists and is
#'   numeric. Otherwise, stops with an error.
#'
#' @noRd
#' @keywords internal
verify_eclock <- function(x, eclock) {
  # `eclock` is the encounter clock, usually minutes from encounter start.
  # Phoenix preparation requires a numeric time variable so observations can be
  # sorted and carried forward later in `prepare_phoenix_data()`.
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

################################################################################

#' Prepare Variable
#'
#' Non-exported general utility for preparing variables for Phoenix Scoring.  It
#' is common engine behind all public `prepare_*()` functions.
#'
#' `prepare_variable()` does five things:
#'
#' 1. Check that the input is a data frame and that the value column is numeric.
#' 2. Reject missing raw values.  Missingness should be represented by omitted
#'    rows; once prepared, absent observations become missing after casting.
#' 3. Validate the observed values against either a numeric range or a fixed
#'    set of allowable values.
#' 4. Resolve duplicate observations at the same encounter/time using the
#'    input-specific `tie.breaker`.
#' 5. Return a standard long data set with columns:
#'      id.vars, eclock, value, variable
#'
#' The `variable` column stores the Phoenix-internal uppercase name such as
#' "FIO2" or "LACTATE".  `prepare_phoenix_data()` later casts those names into
#' wide columns.
#'
#' @param x a data.frame, or an object that inherits from a data.frame such as a
#'   data.table or tibble, containing one Phoenix input in long format.
#'
#' @param id.vars a character vector of one or more column names in \code{x}
#'   that identify the encounter. Common examples are site, patient, and
#'   encounter identifiers. The same \code{id.vars}, in the same order, must be
#'   used for all inputs that will be combined with
#'   \code{\link{prepare_phoenix_data}}.
#'
#' @param value.var a character vector of length one naming the column in
#'   \code{x} that contains the observed value for the Phoenix input being
#'   prepared.
#'
#' @param variable.name a character vector of length one giving the
#'   Phoenix-internal variable name, such as \code{"FIO2"} or \code{"LACTATE"}.
#'   This value is written to the prepared long-format data and later becomes a
#'   column name in \code{\link{prepare_phoenix_data}}.
#'
#' @param valid.range a numeric vector of length two defining the allowable
#'   interval for \code{x[[value.var]]}. Defaults are input-specific and match
#'   the operational Phoenix definition. Users may pass a different interval when
#'   their source data require a different validation rule.
#'
#' @param valid.values a numeric vector of allowable values for discrete
#'   Phoenix inputs, such as \code{c(0, 1)} for binary indicators or the allowed
#'   score set for a Glasgow Coma Scale component. Exactly one of
#'   \code{valid.range} and \code{valid.values} should be supplied.
#'
#' @param valid.range.closed A logical vector of length one or two denoting
#' whether the lower and upper bounds of \code{valid.range} are closed
#' (inclusive) or open (exclusive). A length-one value is recycled for both
#' bounds. Most inputs default to \code{c(TRUE, TRUE)}. \code{prepare_age()}
#' defaults to \code{c(TRUE, FALSE)} to match the expected age interval of
#' [0, 216) months.
#'
#' @param eclock a character vector of length one naming the encounter-clock
#'   column in \code{x}. The encounter clock is expected to be numeric, usually
#'   minutes from encounter start, with 0 denoting the start of the encounter.
#'   Age is static for the encounter and ignores \code{eclock}.
#'
#' @param tie.breaker a function used when more than one row has the same
#'   encounter identifier and encounter-clock value. The default is chosen
#'   separately for each Phoenix input so duplicate observations are resolved in
#'   the clinically conservative direction.
#'
#' @param verbose when \code{TRUE}, print messages describing validation,
#'   duplicate handling, and preparation progress.
#'
#' @return A long-format \code{data.frame} with columns: id.vars, eclock, value,
#' and variable.
#'
#' @keywords internal
prepare_variable <-
  function(
    x,
    id.vars,
    value.var,
    variable.name,
    valid.range = NULL,
    valid.values = NULL,
    valid.range.closed = c(TRUE, TRUE),
    eclock = NULL,
    tie.breaker = NULL,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  stopifnot(inherits(x, "data.frame"))
  stopifnot(is.character(value.var))
  stopifnot(value.var %in% names(x))

  xv <- sprintf("%s[['%s']]", deparse1(substitute(x)), value.var)

  if (!is.numeric(x[[value.var]])) {
    stop(
      sprintf(
        "All values in %s are expected to be numeric or integer, not %s.",
        xv,
        paste(class(x[[value.var]]), collapse = "/")
      ),
      call. = FALSE
    )
  }

  if (any(is.na(x[[value.var]]))) {
    msg <- sprintf("All values in %s are expected to be non-missing.", xv)
    stop(msg, call. = FALSE)
  }

  if (!is.null(valid.range) & !is.null(valid.values)) {
    stop("Only one of valid.range and valid.values should be provided")
  } else if (!is.null(valid.range)) {
    # Continuous inputs use an allowed numeric interval.  Most variables use
    # closed intervals, but age uses an open upper bound to represent [0, 216)
    # months.
    valid.range.closed <- rep(valid.range.closed, length.out = 2L)
    below <- if (isTRUE(valid.range.closed[1L])) {
      any(x[[value.var]] < min(valid.range))
    } else {
      any(x[[value.var]] <= min(valid.range))
    }
    above <- if (isTRUE(valid.range.closed[2L])) {
      any(x[[value.var]] > max(valid.range))
    } else {
      any(x[[value.var]] >= max(valid.range))
    }
    if (below | above) {
      bmsg <- sprintf(
        "%s %s %f",
        xv,
        if (isTRUE(valid.range.closed[1L])) "<" else "<=",
        min(valid.range)
      )
      amsg <- sprintf(
        "%s %s %f",
        xv,
        if (isTRUE(valid.range.closed[2L])) ">" else ">=",
        max(valid.range)
      )
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
    # Discrete inputs use a fixed set of allowed values, for example c(0, 1) for
    # binary indicators or c(1, ..., 6) for GCS motor.
    out <- !all(x[[value.var]] %in% valid.values)
    if (out) {
      stop(sprintf("There are %s not in `valid.values`.", xv), call. = FALSE)
    }
  } else {
    msg <- sprintf("%s values not validated.", xv)
    warning(msg, call. = FALSE)
  }

  verify_id_vars(names(x), id.vars)

  if (variable.name != "AGE") {
    verify_eclock(x, eclock)
  } else {
    if (!is.null(eclock)) {
      warning("Age is expected to be in months and static for the encounter.  `eclock` is ignored.", call. = FALSE)
    }
    eclock <- NULL
  }

  # Check for duplicated id.vars:
  #
  # Duplicate rows mean there is more than one value for the same variable at
  # the same encounter/time.  That can happen when data come from multiple EHR
  # sources.  The public `prepare_*()` wrapper chooses a conservative
  # tie-breaker, such as max for indicators or min for values where lower is
  # clinically worse.
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
      xs[["TRUE"]] <-
        phxdft_aggregate(
          data = xs[["TRUE"]],
          y    = value.var,
          by   = c(id.vars, eclock),
          FUN  = tie.breaker
        )
      x <- do.call(rbind, xs)
      rownames(x) <- NULL
    } else {
      x <-
        phxdft_aggregate(
          data = x,
          y    = value.var,
          by   = c(id.vars, eclock),
          FUN  = tie.breaker
        )
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

  # If all valid values are whole numbers, store the prepared value as integer.
  # This keeps binary indicators and GCS components from becoming unnecessary
  # floating-point columns.
  if (!is.null(valid.values) && isTRUE(all.equal(as.integer(valid.values), as.numeric(valid.values)))) {
    x <- phxdft_set(x, j = "value", value = as.integer(x[["value"]]))
  }

  # Store the internal Phoenix variable name on every row.  Empty inputs are
  # allowed, so handle the zero-row case without recycling a scalar string.
  if (nrow(x) == 0L) {
    x <- phxdft_set(x, j = "variable", value = character(0))
  } else {
    x <- phxdft_set(x, j = "variable", value = variable.name)
  }

  attr(x, "id.vars") <- id.vars
  attr(x, "eclock") <- eclock

  x
}
