#' The Phoenix 8 Sepsis Score
#'
#' The extended Phoenix criteria using a total eight organ systems.  This is
#' intended mostly for reasearch as an extension of the Phoenix Spesis Criteria
#' which is based on four organ systems.
#'
#' The Phoenix Sepsis Criteria is based on the score form
#' respiratory, cardiovascular, coagulation, and neurologic.  Phoenix 8 uses
#' these four an endocrine, immunologic, renal, and hepatic.  Details on the
#' scorign for each of the eight component organ systems are found in the
#' respective manual files.
#'
#' @param pf_ratio numeric vector
#' @param sf_ratio numeric vector
#' @param imv invasive mechanical ventilation; numeric or integer vector, (0 = not intubated; 1 = intubated)
#' @param other_respiratory_support other respiratory support; numeric or integer vector, (0 = no support; 1 = support)
#' @param vasoactives an integer vector, the number of systemic vasoactive medications being administered to the patient
#' @param lactate numeric vector with the lactate value in mmol/L
#' @param age numeric vector age in months
#' @param map numeric vector, mean arterial pressure in mmHg
#' @param platelets numeric vector for platelets counts in units of 1,000/uL (thousand per microliter)
#' @param inr numeric vector for the international normalised ratio blood test
#' @param d_dimer numeric vector for D-Dimer, units of mg/L FEU
#' @param fibrinogen numeric vector units of mg/dL
#' @param gcs integer vector; total Glasgow Comma Score
#' @param fixed_pupils integer vector; 1 = bilaterally fixed pupil, 0 = otherwise
#' @param glucose numeric vector; blood glucose measured in mg/dL
#' @param anc numeric vector; units of 1,000 cells per cubic millimeter
#' @param alc numeric vector; units of 1,000 cells per cubic millimeter
#' @param creatinine numeric vector; units of mg/dL
#' @param bilirubin numeric vector; units of mg/dL
#' @param alt numeric vector; units of IU/L
#' @param data a \code{list}, \code{data.frame}, or \code{environment} containing the input vectors
#' @param ... pass through
#'
#' @return a \code{data.frame} with 12 integer columns.
#' \enumerate{
#'   \item \code{phoenix_respiratory_score}
#'   \item \code{phoenix_cardiovascular_score}
#'   \item \code{phoenix_coagulation_score}
#'   \item \code{phoenix_neurologic_score}
#'   \item \code{phoenix_sepsis_score}
#'   \item \code{phoenix_sepsis} 0 = not septic; 1 = septic (phoenix_sepsis_score greater or equal 2)
#'   \item \code{phoenix_septic_shock} 0 = no spetic shock; 1 = spetic shock (sepsis with cardiovascular dysfunction)
#'   \item \code{phoenix_endocrine_score}
#'   \item \code{phoenix_immunologic_score}
#'   \item \code{phoenix_renal_score}
#'   \item \code{phoenix_hepatic_score}
#'   \item \code{phoenix8_sepsis_score}
#' }
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
#'     pf_ratio = pfr,
#'     sf_ratio = sfr,
#'     imv = vent,
#'     other_respiratory_support = o2,
#'     vasoactives = vasos,
#'     lactate = lactate,
#'     age = age,
#'     map = map,
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
phoenix8 <- function(
                    pf_ratio, sf_ratio, imv, other_respiratory_support,
                    vasoactives, lactate, map, #age
                    platelets, inr, d_dimer, fibrinogen,
                    gcs, fixed_pupils,
                    glucose,
                    anc, alc,
                    creatinine,  #age
                    bilirubin, alt,
                    age,
                    data = parent.frame(), ...) {

  cl <- as.list(match.call())
  cl$data <- NULL

  cl[[1]] <- quote(phoenix)
  rtn <- eval(as.call(cl), envir = data)

  cl[[1]] <- quote(phoenix_endocrine)
  rtn$phoenix_endocrine_score <- eval(as.call(cl), envir = data)

  cl[[1]] <- quote(phoenix_immunologic)
  rtn$phoenix_immunologic_score <- eval(as.call(cl), envir = data)

  cl[[1]] <- quote(phoenix_renal)
  rtn$phoenix_renal_score <- eval(as.call(cl), envir = data)

  cl[[1]] <- quote(phoenix_hepatic)
  rtn$phoenix_hepatic_score <- eval(as.call(cl), envir = data)

  rtn$phoenix8_sepsis_score <-
    rtn[["phoenix_sepsis_score"]] +
    rtn[["phoenix_endocrine_score"]] +
    rtn[["phoenix_immunologic_score"]] +
    rtn[["phoenix_renal_score"]] +
    rtn[["phoenix_hepatic_score"]]
  rtn
}
