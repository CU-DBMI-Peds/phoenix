#' Phoenix Coagulation Score
#'
#' @param platelets numeric vector for platelets counts in units of 1,000/uL
#' @param inr numeric vector for the internation normlised ratio blood test
#' @param d_dimer numeric vector for D-Dimer, units of mg/L FEU
#' @param fibrinogen numeric vector units of mg/dL
#' @param data a \code{list}, \code{data.frame}, or object that can be coerced
#' to a \code{data.frame}, containing the input vectors
#' @param ... pass through
#'
#' @return a integer vector with values 0, 1, or 2
#'
#' As with all other Phoenix oragan system scores, missing values in the data
#' set will map to a score of zero - this is consistent with the development of
#' the criteria.
#'
#' @seealso
#' \itemize{
#'   \item \code{\link{phoenix}} for generating the diagnostic Phoenix
#'     Sepsis score based on the four organ systems:
#'     \itemize{
#'       \code{\link{phoenix_cardiovascular}},
#'       \code{\link{phoenix_coagulation}},
#'       \code{\link{phoenix_neurologic}},
#'       \code{\link{phoenix_respiratory}},
#'     }
#'   \item \code{\link{phoenix8}} for generating the diagnostic Phoenix 8
#'     Spesis criteria based on the four organ systems noted above and
#'     \itemize{
#'       \code{\link{phoenix_endocrine}},
#'       \code{\link{phoenix_immunologic}},
#'       \code{\link{phoenix_renal}},
#'       \code{\link{phoenix_hepatic}},
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
phoenix_coagulation <- function(platelets, inr, d_dimer, fibrinogen, data, ...) {
  plt <- eval(expr = substitute(platelets), envir = data)
  inr <- eval(expr = substitute(inr), envir = data)
  ddm <- eval(expr = substitute(d_dimer), envir = data)
  fib <- eval(expr = substitute(fibrinogen), envir = data)

  if ( (length(plt) != length(inr)) | (length(plt) != length(ddm)) | (length(plt) != length(fib)) ) {
    stop("length of all input variables are not equal")
  }

  # set "healthy" value for missing data
  plt <- replace(plt, which(is.na(plt)), Inf)
  inr <- replace(inr, which(is.na(inr)), 0)
  ddm <- replace(ddm, which(is.na(ddm)), 0)
  fib <- replace(fib, which(is.na(fib)), Inf)

  rtn <- (plt < 100) + (inr > 1.3) + (ddm > 2) + (fib < 100)
  pmin(rtn, 2)
}
