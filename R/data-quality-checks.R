#' Phoenix Input Data Quality Checks
#'
#' A suite of functions for identifying potentially invalid data values in the
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
#' @name phoenix_input_data_checks
NULL

#'
#' @export
#phoenix_respiratory_data_checks(pf_ratio = NA_real_, sf_ratio = NA_real_, pao2 = NA_real_, spo2 = NA_real_, fio2 = NA_real_, imv = NA_integer_, other_respiratory_support = NA_integer_, data = parent.frame()) {
#}


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
