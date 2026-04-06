#' Functions for operationalizing Phoenix
#'
#' All
#'
#' @param x a data.frame, or object that inherits from a data.frame
#' @param variable
#' @param
#'
#' @export
prepare_fio2 <-
  function(
    x,
    id.vars,
    value.var,
    variable.name = "FIO2",
    valid.range = c(0.21, 1.00),
    valid.values = NULL,
    eclock = "eclock",
    tie.breaker = max,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  eval(cl)
}

#' @export
prepare_spo2 <-
  function(
    x,
    id.vars,
    value.var,
    variable.name = "SPO2",
    valid.range = c(0, 100),
    valid.values = NULL,
    eclock = "eclock",
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", TRUE)
  ) {

  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  eval(cl)
}

#' @export
prepare_pao2 <-
  function(
    x,
    id.vars,
    value.var,
    variable.name = "PAO2",
    valid.range = c(0, Inf),
    valid.values = NULL,
    eclock = "eclock",
    tie.breaker = min,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  cl <- eval(match.call.with.defaults)
  cl[[1]] <- quote(prepare_variable)
  eval(cl)
}

#' @export
prepare_data <-
  function(
    FIO2 = NULL,
    SPO2 = NULL,
    PAO2 = NULL,
    respiratory_lookback = 360,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  phxdata <-
    list(
      FIO2 = FIO2,
      SPO2 = SPO2,
      PAO2 = PAO2
    )

  # verify that all the input data sets are either null or phoenix_prepared
  check <- sapply(phxdata, function(x) {is.null(x) || inherits(x, "phoenix_prepared")})
  if (!all(check)) {
    issues <- names(check)[!check]
    if (length(issues) == 2L) {
      msg <- sprintf("%s and %s", issues[1], issues[2])
    } else if (length(issues) > 2L) {
      msg <- sprintf("%s, and %s", paste(issues[-length(issues)], collapse = ", "), issues[length(issues)])
    } else {
      msg <- issues
    }
    msg <-
      sprintf("All input data sets need to be phoenix_prepared objects. Please run the input to %s through phoenix::prepare_variable().", msg)
    stop(msg, call. = FALSE)
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
    if (verbose) message(sprintf("   %s...", j))
    obs <- !is.na(phxdata[[j]])
    last_obs <- cummax(ifelse(obs, row, 0L))
    ok <- last_obs > 0L
    ok[ok] <- id[last_obs[ok]] == id[ok]
    out <- phxdata[[j]]
    out[ok] <- out[last_obs[ok]]

    outeclock <- NA
    outeclock[ok] <- phxdata[[eclock]][last_obs[ok]]

    phxdata <- phxdft_set(phxdata, j = paste0(j, "_locf"), value = out)
    phxdata <- phxdft_set(phxdata, j = paste0(j, "_eclock"), value = outeclock)

    if (j %in% c("FIO2", "SPO2", "PAO2")) {
      idx <- which((phxdata[[eclock]] - phxdata[[paste0(j, "_eclock")]]) > respiratory_lookback)
      phxdata <- phxdft_set(phxdata, i = idx, j = paste0(j, "_locf"), value = NA)
      phxdata <- phxdft_set(phxdata, i = idx, j = paste0(j, "_eclock"), value = NA)
    }
  }

  #obs <- !is.na(phxdata[["FIO2"]])
  #last_obs <- cummax(ifelse(obs, row, 0L))
  #ok <- last_obs > 0L
  #ok[ok] <- id[last_obs[ok]] == id[ok]
  #out <- phxdata[["FIO2"]]
  #out[ok] <- out[last_obs[ok]]

  #outeclock <- NA
  #outeclock[ok] <- phxdata[[eclock]][last_obs[ok]]

  #phxdata <- phxdft_set(phxdata, j = "FIO2_locf", value = out)
  #phxdata <- phxdft_set(phxdata, j = "FIO2_eclock", value = outeclock)

  phxdata

}


################################################################################
# Non exported functions

verify_id_vars <- function(names, id.vars) {
  stopifnot(is.character(id.vars))
  stopifnot(length(id.vars) > 0L)
  not_in_names <- id.vars[!(id.vars %in% names)]

  if (length(not_in_names)) {
    stop(sprintf("There are id.vars not in the names of the input data.frame. Value(s) not found: %",
        paste(not_in_names, collapse = ", ")
        ))
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
    xs <- split(x, f = dups)
    xs[["FALSE"]] <- phxdft_select(xs[["FALSE"]], c(id.vars, eclock, value.var))
    xs[["TRUE"]] <- phxdft_aggregate(value.var, by = c(id.vars, eclock), data = xs[["TRUE"]], FUN = tie.breaker)
    x <- do.call(rbind, xs)
  } else {
    if (verbose) {
      message(sprintf("No duplicate rows in %s based on c(%s).",
          deparse1(substitute(x)),
          paste0("'", paste(c(id.vars, eclock), collapse = ", "), "'")))
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

