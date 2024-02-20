#' Phoenix Coagulation Score
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0, 1, or 2
#'
#' As with all other Phoenix organ system scores, missing values in the data
#' set will map to a score of zero - this is consistent with the development of
#' the criteria.
#'
#' @seealso
#' \itemize{
#'   \item \code{\link{phoenix}} for generating the diagnostic Phoenix
#'     Sepsis score based on the four organ systems:
#'     \itemize{
#'       \item \code{\link{phoenix_cardiovascular}},
#'       \item \code{\link{phoenix_coagulation}},
#'       \item \code{\link{phoenix_neurologic}},
#'       \item \code{\link{phoenix_respiratory}},
#'     }
#'   \item \code{\link{phoenix8}} for generating the diagnostic Phoenix 8
#'     Sepsis criteria based on the four organ systems noted above and
#'     \itemize{
#'       \item \code{\link{phoenix_endocrine}},
#'       \item \code{\link{phoenix_immunologic}},
#'       \item \code{\link{phoenix_renal}},
#'       \item \code{\link{phoenix_hepatic}},
#'     }
#' }
#'
#' \code{vignette('phoenix')} for more details and examples.
#'
#' @references
#'
#' Sanchez-Pinto LN, Bennett TD, DeWitt PE, et al. Development and Validation of
#' the Phoenix Criteria for Pediatric Sepsis and Septic Shock. JAMA. Published
#' online January 21, 2024. doi:10.1001/jama.2024.0196
#'
#' Schlapbach LJ, Watson RS, Sorce LR, et al. International Consensus Criteria
#' for Pediatric Sepsis and Septic Shock. JAMA. Published online January 21,
#' 2024. doi:10.1001/jama.2024.0179
#'
#' @examples
#'
#' DF <-
#'   expand.grid(plts = c(NA, 20, 100, 150),
#'               inr  = c(NA, 0.2, 1.3, 1.8),
#'               ddmr = c(NA, 1.7, 2.0, 2.8),
#'               fib  = c(NA, 88, 100, 120))
#'
#' DF$coag <- phoenix_coagulation(plts, inr, ddmr, fib, DF)
#' DF
#'
#' @export
phoenix_coagulation <- function(platelets, inr, d_dimer, fibrinogen, data = parent.frame(), ...) {

  if (missing(platelets)) {
    plt <- NA_real_
  } else {
    plt <- eval(expr = substitute(platelets), envir = data)
  }

  if (missing(inr)) {
    inr <- NA_real_
  } else {
    inr <- eval(expr = substitute(inr), envir = data)
  }

  if (missing(d_dimer)) {
    ddm <- NA_real_
  } else {
    ddm <- eval(expr = substitute(d_dimer), envir = data)
  }

  if (missing(fibrinogen)) {
    fib <- NA_real_
  } else {
    fib <- eval(expr = substitute(fibrinogen), envir = data)
  }

  n <- max(c(length(plt), length(inr), length(ddm), length(fib)))

  if (n > 1) {
    if (length(plt) == 1) {
      plt <- rep(plt, n)
    } else if (length(plt) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of platelets is %s, needs to be either 1 or %s."
                   , length(plt), n))
    }
    if (length(inr) == 1) {
      inr <- rep(inr, n)
    } else if (length(inr) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of inr is %s, needs to be either 1 or %s."
                   , length(inr), n))
    }
    if (length(ddm) == 1) {
      ddm <- rep(ddm, n)
    } else if (length(ddm) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of d_dimer is %s, needs to be either 1 or %s."
                   , length(ddm), n))
    }
    if (length(fib) == 1) {
      fib <- rep(fib, n)
    } else if (length(fib) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of fibrinogen is %s, needs to be either 1 or %s."
                   , length(fib), n))
    }
  }

  # set "healthy" value for missing data
  plt <- replace(plt, which(is.na(plt)), Inf)
  inr <- replace(inr, which(is.na(inr)), 0)
  ddm <- replace(ddm, which(is.na(ddm)), 0)
  fib <- replace(fib, which(is.na(fib)), Inf)

  rtn <- (plt < 100) + (inr > 1.3) + (ddm > 2) + (fib < 100)
  pmin(rtn, 2)
}
