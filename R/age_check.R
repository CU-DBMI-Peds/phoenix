#' Age Check
#'
#' Check and report on the distribution of age used in the Phoenix scoring.
#'
#' Expected input is in months and in the range of (0, 216], that is,
#' non-birth hospitalization up to, and including 216 months (18 years).
#'
#' @return a \code{data.frame} with row names reporting age intervals, a column
#' for counts and a column for warnings.  \code{warning}s will be thrown if
#' needed.
#'
#' @param x numeric vector
#' @param ... pass through
#'
#' @examples
#' # warning if all ages are <= 18 - suggests age in years instead of the
#' # expected months
#' age_check(c(1:18))
#'
#' # warnings for negative, zero, and ages above 216 months
#' age_check(x = c(-10, 0, runif(100, 0, 216), 222))
#'
#' # return just a data.frame if everything is reasonable
#' age_check(sepsis$age)
#'
#' @export
age_check <- function(x, ...) {
  UseMethod("age_check")
}

#' @export
age_check.numeric <- function(x, ...) {
  rtn <-
    c(
      "NAs" = sum(is.na(x)),
      "(-Inf, 0)" = sum(x < 0),
      "zeros" = sum(sapply(lapply(x, all.equal, current = 0), isTRUE)),
      "(  0,   1)" = sum(x >    0 & x <    1),
      "[  1,  12)" = sum(x >=   1 & x <   12),
      "[ 12,  24)" = sum(x >=  12 & x <   24),
      "[ 24,  60)" = sum(x >=  24 & x <   60),
      "[ 60, 144)" = sum(x >=  60 & x <  144),
      "[144, 216]" = sum(x >= 144 & x <= 216),
      "(216, Inf)" = sum(x > 216)
      )

  out <- data.frame(Count = rtn, "Warnings" = "")

  warn <- character(0)
  if (all(x <= 18, na.rm = TRUE)) {
    warn <- c(warn, "All ages <= 18. Are you sure the values are months and not years?")
    out$Warnings[7:9] <- "All values <= 18"
  }
  if (rtn[2] > 0) {
    warn <- c(warn, "At least one negative age")
    out$Warnings[2] <- "Nagative Value(s)"
  }
  if (rtn[3] > 0) {
    warn <- c(warn, "At least one age of zero reported")
    out$Warnings[3] <- "Value(s) of zero"
  }
  if (rtn[10] > 0) {
    warn <- c(warn, "At least one age exceeding 216 months (18 years) reported")
    out$Warnings[10] <- "Value(s) exceeding 216"
  }

  if (length(warn) > 0L) {
    for (i in seq_along(warn)) {
      warning(warn[i])
    }
  }

  out
}

