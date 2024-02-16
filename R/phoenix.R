#' The Phoenix Sepsis Score
#'
#' @inheritParams phoenix_respiratory
#' @inheritParams phoenix_cardiovascular
#' @inheritParams phoenix_coagulation
#' @inheritParams phoenix_neurologic
#'
#' @return a integer vector with values 0, through 13
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
phoenix <- function(vasoactives, lactate, age, map,
                    pf_ratio, sf_ratio, imv, other_respiratory_support,
                    platelets, inr, d_dimer, fibrinogen,
                    gcs, fixed_pupils,
                    data, ...) {

  cl <- as.list(match.call())

  cl[[1]] <- quote(phoenix_cardiovascular)
  card <- eval(cl)
  cl[[1]] <- quote(phoenix_respiratory)
  resp <- eval(cl)
  cl[[1]] <- quote(phoenix_coagulation)
  coag <- eval(cl)
  cl[[1]] <- quote(phoenix_neurologic)
  neur <- eval(cl)

  data.frame(phoenix_cardiovascular_score = card,
             phoenix_respiratory_score = resp,
             phoenix_coagulation_score = coag,
             phoenix_neurologic_score = neur,
             phoenix_total_score = card + resp + coag + neur)
}
