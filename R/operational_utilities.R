# Non exported functions used in
#
#   prepare_inputs_range
#   prepare_inputs_discrete
#   prepare_phoenix_data

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
      stop(sprintf("There are %s not in `valid.values`.", xv), call. = FALSE)
    }
  } else {
    msg <- sprintf("%s values not validated.", xv)
    warning(msg, call. = FALSE)
  }

  verify_id_vars(names(x), id.vars)

  if (variable.name != "AGE") {
    verify_elcock(x, eclock)
  } else {
    if (!is.null(eclock)) {
      warning("Age is expected to be in months and static for the encounter.  `eclock` is ignored.", call. = FALSE)
    }
    eclock <- NULL
  }

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
      xs[["TRUE"]] <-
        stats::aggregate.data.frame(
          x   = phxdft_select(xs[["TRUE"]], value.var),
          by  = phxdft_select(xs[["TRUE"]], c(id.vars, eclock)),
          FUN = tie.breaker
        )
      x <- do.call(rbind, xs)
      rownames(x) <- NULL
    } else {
      x <-
        stats::aggregate.data.frame(
          x = phxdft_select(x, value.var),
          by = phxdft_select(x, c(id.vars, eclock)),
          FUN = tie.breaker
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

  if (!is.null(valid.values) && isTRUE(all.equal(as.integer(valid.values), as.numeric(valid.values)))) {
    x <- phxdft_set(x, j = "value", value = as.integer(x[["value"]]))
  }

  if (nrow(x) == 0L) {
    x <- phxdft_set(x, j = "variable", value = character(0))
  } else {
    x <- phxdft_set(x, j = "variable", value = variable.name)
  }

  attr(x, "id.vars") <- id.vars
  attr(x, "eclock") <- eclock
  class(x) <- c("phoenix_prepared", class(x))

  x
}
