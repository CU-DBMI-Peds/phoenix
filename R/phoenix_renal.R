#' Phoenix Renal Score
#'
#' @inheritParams phoenix8
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
#'
#'
#' @export
phoenix_renal <- function(creatinine, age, data, ...) {
  crt <- eval(expr = substitute(creatinine), envir = data)
  age <- eval(expr = substitute(age), envir = data)

  if ( (length(crt) != length(age)) ) {
    stop("length of all input variables are not equal")
  }

  # set "healthy" value for missing data
  missing_idx <- which(is.na(age) | is.na(crt))
  age <- replace(age, missing_idx, 0)
  crt <- replace(crt, missing_idx, 0)

  (             age <   1) * (crt >= 0.8) +
  (age >=   1 & age <  12) * (crt >= 0.3) +
  (age >=  12 & age <  24) * (crt >= 0.4) +
  (age >=  24 & age <  60) * (crt >= 0.6) +
  (age >=  60 & age < 144) * (crt >= 0.7) +
  (age >= 144            ) * (crt >= 1.0)

}
