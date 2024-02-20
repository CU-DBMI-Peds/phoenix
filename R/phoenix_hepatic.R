#' Phoenix Hepatic Score
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0 or 1
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
#'       \item \code{\link{phoenix_cardiovascular}},
#'       \item \code{\link{phoenix_coagulation}},
#'       \item \code{\link{phoenix_neurologic}},
#'       \item \code{\link{phoenix_respiratory}},
#'     }
#'   \item \code{\link{phoenix8}} for generating the diagnostic Phoenix 8
#'     Spesis criteria based on the four organ systems noted above and
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
#' DF <- expand.grid(bil = c(NA, 3.2, 4.0, 4.3), alt = c(NA, 99, 102, 106))
#' phoenix_hepatic(bilirubin = bil, alt = alt, data = DF)
#' @export
phoenix_hepatic <- function(bilirubin, alt, data = parent.frame(), ...) {

  if (missing(bilirubin)) {
    bil <- NA_real_
  } else {
    bil <- eval(expr = substitute(bilirubin), envir = data)
  }

  if (missing(alt)) {
    alt <- NA_real_
  } else {
    alt <- eval(expr = substitute(alt), envir = data)
  }

  n <- max(c(length(bil), length(alt)))

  if (n > 1) {
    if (length(bil) == 1) {
      bil <- rep(bil, n)
    } else if (length(bil) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of bilirubin is %s, needs to be either 1 or %s."
                   , length(bil), n))
    }
    if (length(alt) == 1) {
      alt <- rep(alt, n)
    } else if (length(alt) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of alt is %s, needs to be either 1 or %s."
                   , length(alt), n))
    }
  }

  # set "healthy" value for missing data
  bil <- replace(bil, which(is.na(bil)), 0)
  alt <- replace(alt, which(is.na(alt)), 0)

  as.integer( (bil >= 4) | (alt > 102) )
}
