#' The Phoenix Sepsis Score
#'
#' @inheritParams phoenix8
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
#' DF <-
#'   expand.grid(
#'     # coagulation varaiables
#'     plts = c(20, 100, 150),
#'     inr  = c(0.2, 1.3, 1.8),
#'     ddmr = c(1.7, 2.0, 2.8),
#'     fib  = c(88, 100, 120),
#'
#'     # cardiovascular variabls
#'     vasos = c(0:3),
#'     lactate = c(3.2, 7.8, 14),
#'     age = c(0.4, 3, 18, 45, 61, 164),
#'     map = c(16, 33, 55),
#'
#'     # neurologic variables
#'     gcs = c(8, 12),
#'     pupils = c(0, 1),
#'
#'     # respiratory variables
#'     pfr = c(500, 350, 187, 56),
#'     sfr = c(300, 254, 177, 76),
#'     vent = c(0, 1),
#'     o2  = c(0, 1)
#'     )
#'
#' PSS <-
#'   phoenix(
#'     vasoactives = vasos,
#'     lactate = lactate,
#'     age = age,
#'     map = map,
#'     pf_ratio = pfr,
#'     sf_ratio = sfr,
#'     imv = vent,
#'     other_respiratory_support = o2,
#'     platelets = plts,
#'     inr = inr,
#'     d_dimer = ddmr,
#'     fibrinogen = fib,
#'     gcs = gcs,
#'     fixed_pupils = pupils,
#'     data = DF
#'   )
#'
#' head(PSS)
#'
#' @export
phoenix <- function(vasoactives, lactate, age, map,
                    pf_ratio, sf_ratio, imv, other_respiratory_support,
                    platelets, inr, d_dimer, fibrinogen,
                    gcs, fixed_pupils,
                    data, ...) {

  cl <- as.list(match.call())

  cl[[1]] <- quote(phoenix_cardiovascular)
  card <- eval(as.call(cl))
  cl[[1]] <- quote(phoenix_respiratory)
  resp <- eval(as.call(cl))
  cl[[1]] <- quote(phoenix_coagulation)
  coag <- eval(as.call(cl))
  cl[[1]] <- quote(phoenix_neurologic)
  neur <- eval(as.call(cl))

  data.frame(phoenix_cardiovascular_score = card,
             phoenix_respiratory_score = resp,
             phoenix_coagulation_score = coag,
             phoenix_neurologic_score = neur,
             phoenix_total_score = card + resp + coag + neur)
}
