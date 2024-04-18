#' Phoenix Coagulation Score
#'
#' Applies the Phoenix coagulation organ dysfunction scoring to a set of inputs.
#'
#' @section Phoenix Coagulation Scoring:
#' 1 point each for platelets < 100 K/micro liter, INR > 1.3, D-dimer > 2 mg/L
#' FEU, and fibrinogen < 100 mg/dL, with a max total
#' score of 2.
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
#' @references See reference details in \code{\link{phoenix-package}} or by calling
#' \code{citation('phoenix')}.
#'
#' @examples
#'
#' # using the example data set
#' phoenix_coagulation(
#'   platelets = platelets,
#'   inr = inr,
#'   d_dimer = d_dimer,
#'   fibrinogen = fibrinogen,
#'   data = sepsis
#' )
#'
#' # build a data.frame with values for all possible combationations of values
#' # leading to all possible coagulation scores.
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
phoenix_coagulation <- function(platelets = NA_real_, inr = NA_real_, d_dimer = NA_real_, fibrinogen = NA_real_, data = parent.frame(), ...) {

  plt <- eval(expr = substitute(platelets), envir = data, enclos = parent.frame())
  inr <- eval(expr = substitute(inr), envir = data, enclos = parent.frame())
  ddm <- eval(expr = substitute(d_dimer), envir = data, enclos = parent.frame())
  fib <- eval(expr = substitute(fibrinogen), envir = data, enclos = parent.frame())

  lngths <- c(length(plt), length(inr), length(ddm), length(fib))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of platelets is %s;",
                 "Length of inr is %s;",
                 "Length of d_dimer is %s;",
                 "Length of fibrinogen is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  # set "healthy" value for missing data
  plt <- replace(plt, which(is.na(plt)), Inf)
  inr <- replace(inr, which(is.na(inr)), 0)
  ddm <- replace(ddm, which(is.na(ddm)), 0)
  fib <- replace(fib, which(is.na(fib)), Inf)

  rtn <- as.integer(plt < 100) + as.integer(inr > 1.3) + as.integer(ddm > 2) + as.integer(fib < 100)
  pmin(rtn, 2L)
}
