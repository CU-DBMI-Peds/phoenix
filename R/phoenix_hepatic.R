#' Phoenix Hepatic Score
#'
#' @param bilirubin numeric vector for total bilirubin in mg/dL
#' @param alt numeric vector in units of IU/L
#' @param data a \code{list}, \code{data.frame}, or object that can be coerced
#' to a \code{data.frame}, containing the input vectors
#' @param ... pass through
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
#'
#' @export
phoenix_hepatic <- function(bilirubin, alt, data, ...) {
  bil <- eval(expr = substitute(bilirubin), envir = data)
  alt <- eval(expr = substitute(alt), envir = data)

  if ( (length(bil) != length(alt)) ) {
    stop("length of all input variables are not equal")
  }

  # set "healthy" value for missing data
  bil <- replace(bil, which(is.na(bil)), 0)
  alt <- replace(alt, which(is.na(alt)), 0)

  as.integer( (bil >= 4) | (alt > 102) )
}
