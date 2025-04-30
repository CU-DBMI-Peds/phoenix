#' Checking Data Assumptions for Phoenix
#'
#' A suite of tests for identifying potentially invalid data values in the
#' input data for Phoenix scoring.
#'
#' @inheritParams phoenix8
#' @param pao2 numeric vector,  PaO2 is the arterial oxygen pressure measured in
#' mmHg
#' @param spo2 numeric vector, SpO2 is oxygen saturation, measured in as a
#' percent, expected values are integer values between 0 and 100.  A warning
#' will be given for values between 0 and 1 along with any value outside of 0 to
#' 100.  A warning is also given for values exceeding 97 as sf_ratio is only
#' valid for use in Phoenix if SpO2 is less than or equal to 97.
#' @param fio2 numeric vector,  FiO2 is the fraction of inspired oxygen with
#' expected values between 0.21 (room air) to 1.00.
#'
#' @return
#'
#' \code{check_data} returns a \code{phoenix_data_check} object.  This
#' is a list of tests and a \code{data.frame} called "considered_data" which is
#' the effective data set considered.  This is an important distinction.  Say
#' you check \code{sf_ratio = spo2/fio2}.  The \code{check_data} will only check
#' the assuptions around sf_ration specifically, and will not check assumptions
#' about spo2 or fio2.  To get checks of all three you will need to specify all
#' three in the call to \code{check_data}.
#'
#' @example examples/check_data.R
#'
#' @export
check_data <- function(
    pf_ratio = NA_real_
  , sf_ratio = NA_real_
  , pao2 = NA_real_
  , spo2 = NA_real_
  , fio2 = NA_real_
  , imv = NA_integer_
  , other_respiratory_support = NA_integer_
  , data = parent.frame()
  ) {

  pf_ratio <- eval(expr = substitute(pf_ratio), envir = data, enclos = parent.frame())
  sf_ratio <- eval(expr = substitute(sf_ratio), envir = data, enclos = parent.frame())
  pao2     <- eval(expr = substitute(pao2),     envir = data, enclos = parent.frame())
  spo2     <- eval(expr = substitute(spo2),     envir = data, enclos = parent.frame())
  fio2     <- eval(expr = substitute(fio2),     envir = data, enclos = parent.frame())
  imv      <- eval(expr = substitute(imv),      envir = data, enclos = parent.frame())
  other_respiratory_support  <- eval(expr = substitute(other_respiratory_support), envir = data, enclos = parent.frame())

  length_check(pf_ratio = pf_ratio,
               sf_ratio = sf_ratio, pao2 = pao2,
               spo2 = spo2,
               fio2 = fio2,
               imv = imv,
               other_respiratory_support = other_respiratory_support)

  # checks for mode
  # recall that is.numeric will return TRUE for reals and integers
  stopifnot(is.numeric(fio2))
  stopifnot(is.numeric(spo2))
  stopifnot(is.numeric(pao2))
  stopifnot(is.numeric(pf_ratio))
  stopifnot(is.numeric(sf_ratio))
  stopifnot(is.numeric(imv))
  stopifnot(is.numeric(other_respiratory_support))

  ##############################################################################
  # Tests to report on
  tests <- list()

  new_test <- function(test = "", warn_if = "", skip, pass = !fail, warn = NULL, fail = !pass) {
    thistest <- list(list(warn_if = warn_if))
    names(thistest) <- test
    if (skip) {
      thistest[[1]][["pass"]]    <- integer(0)
      thistest[[1]][["warning"]] <- integer(0)
      thistest[[1]][["fail"]]    <- integer(0)
    } else {
      thistest[[1]][["pass"]] <- which(pass)
      thistest[[1]][["fail"]] <- which(!pass)
      if (is.null(warn)) {
        thistest[[1]][["warning"]] <- integer(0)
      } else {
        thistest[[1]][["warning"]] <- which(warn)
      }
    }
    thistest[[1]][["skip"]] <- skip

    assign("tests",
           value = c(get("tests", envir = parent.frame()), thistest),
           envir = parent.frame())
  }

  new_test(
    test = "imv %in% c(0, 1)",
    skip = all(is.na(imv)),
    pass = is.na(imv) | (imv %in% c(0, 1))
  )

  new_test(
    test = "other_respiratory_support %in% c(0, 1)",
    skip = all(is.na(other_respiratory_support)),
    pass = is.na(other_respiratory_support) | (other_respiratory_support %in% c(0, 1))
  )

  new_test(
    test = "if imv == 1 then other_respiratory_support == 1",
    skip = all(is.na(other_respiratory_support)) | all(is.na(imv)),
    fail = (imv == 1) & (is.na(other_respiratory_support) | other_respiratory_support == 0)
  )

  new_test(
    test = "0.21 <= fio2 <= 1.00",
    skip = all(is.na(fio2)),
    pass = is.na(fio2) | (fio2 >= 0.21 & fio2 <= 1.00)
  )

  new_test(
    test    = "0 <= spo2 <= 100",
    warn_if = "0 < spo2 < 1",
    skip    = all(is.na(spo2)),
    pass    = is.na(spo2) | (spo2 >= 0.00 & spo2 <= 100),
    warn    = (spo2 > 0.00 & spo2 < 1.00)
  )

  new_test(
    test = "0 <= sf_ratio <= 100/0.21",
    skip = all(is.na(sf_ratio)),
    pass = is.na(sf_ratio) | (sf_ratio >= 0.00 & sf_ratio <= 100/0.21)
  )

  new_test(
    test    = "0 <= pao2", # technically there is no upper limit for pao2, but ther are unexpected values
    warn_if = "pao2 > 100",
    skip    = all(is.na(pao2)),
    pass    = is.na(pao2) | (pao2 >= 0.00),
    warn    = pao2 > 100
  )

  new_test(
    test    = "0 <= pf_ratio",
    warn_if = "pf_ratio > 100 / 0.21",
    skip    = all(is.na(pf_ratio)),
    pass    = is.na(pf_ratio) | (pf_ratio >= 0.00),
    warn    = pf_ratio > 100 / 0.21
  )

  ## check for consistency between fio2 values and other respiratory support
  new_test(
    test = "(fio2 > 0.21) == other_respiratory_support",
    skip = all(is.na(fio2)) | all(is.na(other_respiratory_support)),
    pass = (as.integer(fio2 > 0.21) == other_respiratory_support)
  )

  ## check for the condition that sf_ratio is only used when spo2 is <= 97
  new_test(
    test    = "spo2 <= 97 | (spo2 > 97 & is.na(sf_ratio))",
    warn_if = "spo2 > 97",
    skip    = all(is.na(sf_ratio)) | all(is.na(spo2)),
    pass    = is.na(sf_ratio) | is.na(spo2) | ((spo2 > 97) & is.na(sf_ratio)) | (spo2 <= 97),
    warn    = spo2 > 97
  )

  ## check if the provided sf_ratio is equal to a calculated sf_ratio
  new_test(
    test = "spo2/fio2 == sf_ratio",
    skip = all(is.na(sf_ratio)) | all(is.na(spo2)) | all(is.na(fio2)),
    pass = is.na(spo2) | is.na(fio2) | is.na(sf_ratio) | ( (spo2 / fio2) > (sf_ratio - sqrt(.Machine$double.eps)) & (spo2 / fio2) < (sf_ratio + sqrt(.Machine$double.eps)))
  )

  ## check if the provided pf_ratio is equal to the calculated pf_ratio
  new_test(
    test = "pao2/fio2 == pf_ratio",
    skip = all(is.na(pf_ratio)) | all(is.na(pao2)) | all(is.na(fio2)),
    pass = is.na(pao2) | is.na(fio2) | is.na(pf_ratio) | ( (pao2 / fio2) > (pf_ratio - sqrt(.Machine$double.eps)) & (pao2 / fio2) < (pf_ratio + sqrt(.Machine$double.eps)))
  )

  ##############################################################################
  # Build a simple report for the results
  tests[["report"]] <-
    data.frame(test    = names(tests),
               warn_if = sapply(tests, function(x) x[["warn_if"]]),
               pass    = sapply(tests, function(x) length(x[["pass"]])),
               warning = sapply(tests, function(x) length(x[["warning"]])),
               fail    = sapply(tests, function(x) length(x[["fail"]])),
               skipped = sapply(tests, function(x) x[["skip"]]),
               row.names = NULL)

  ##############################################################################
  #
  if (any(tests[["report"]][["warning"]] > 0) | any(tests[["report"]][["fail"]] > 0)) {

    if (any(tests[["report"]][["warning"]] > 0)) {
      warning("There is at least one test with warnings.")
    }

    if (any(tests[["report"]][["fail"]] > 0)) {
      warning("There is at least one test with failures.")
    }

  } else if (all(tests[["report"]][["skipped"]])) {
    warning("All tests were skipped.")
  }

  ##############################################################################
  #
  tests[["considered_data"]] <-
    data.frame(fio2, spo2, pao2, sf_ratio, pf_ratio, imv, other_respiratory_support)

  class(tests) <- "phoenix_data_check"
  tests
}

#' @rdname check_data
#' @param x a \code{phoenix_data_check} object
#' @param test the name or index of the test you want
#' @export
show_warnings <- function(x, test) {
  UseMethod("show_warnings")
}

#' @export
show_warnings.phoenix_data_check <- function(x, test) {
  idx <- x[[test]][["warning"]]
  x[["considered_data"]][idx, ]
}

#' @rdname check_data
#' @export
show_failures <- function(x, test) {
  UseMethod("show_fails")
}

#' @export
show_failures.phoenix_data_check <- function(x, test) {
  idx <- x[[test]][["fail"]]
  x[["considered_data"]][idx, ]
}

#' @rdname check_data
#' @param full_report when \code{TRUE} print all tests.  When \code{FALSE} print
#' only non-skipped tests.
#' @export
print.phoenix_data_check <- function(x, full_report = FALSE, ...) {
  stopifnot(isTRUEisFALSE(full_report))
  cat("\nReport of the number of rows passing, failing, or with warning(s)\n\n")

  if (full_report) {
    print(x[["report"]])
  } else {
    print(x[["report"]][["skipped"]][!x[["report"]][["skipped"]], ])
  }


  invisible(x)
}

#' @export
summary.phoenix_data_check <- function(object, ...) {
  tests <- nrow(object[["report"]])
  skips <- sum(object[["report"]][["skipped"]])
  fails <- sum(object[["report"]][["fail"]] > 0)
  warns <- sum(object[["report"]][["warning"]] > 0)
  pass  <- sum((object[["report"]][["pass"]] > 0) &
               (object[["report"]][["fail"]] == 0) &
               (object[["report"]][["warning"]] == 0) &
               !(object[["report"]][["skipped"]]))
  rtn <- list(tests = tests,
              tests_skipped = skips,
              tests_failed  = fails,
              tests_warned  = warns,
              tests_pass    = pass)
  class(rtn) <- "phoenix_data_check_summary"
  rtn
}

#' @export
print.phoenix_data_check_summary <- function(x, ...) {
  labels <- c("tests:", "  skipped:", "  failed:", "  warned:", "  passed:")
  values <- c(x$tests, x$tests_skipped, x$tests_failed, x$tests_warned, x$tests_pass)

  label_width <- max(nchar(labels))
  value_width <- max(nchar(as.character(values)))

  for (i in 1:length(labels)) {
    cat(sprintf("%-*s %*d\n", label_width, labels[i], value_width, values[i]))
  }

  invisible(x)
}


################################################################################
# Non-exported functions
length_check <- function(..., data = parent.frame())
{
  dots <- as.list(match.call(expand.dots = FALSE))[["..."]]
  dots <- lapply(dots, as.expression)
  dots <- lapply(dots, eval, envir = data, enclos = parent.frame())
  lngths <- sapply(dots, length)

  if (!all(lngths %in% c(1L, max(lngths)))) {
    msg <- "All inputs need to either have the same length or have length 1."
    for (i in seq_along(lngths)) {
      msg <- paste(msg, "\n    Length of", names(lngths)[i], "is:", lngths[i])
    }
    stop(msg)
  }

  invisible(TRUE)
}
