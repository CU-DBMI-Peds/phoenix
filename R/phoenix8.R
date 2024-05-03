#' The Phoenix 8 Sepsis Score
#'
#' The extended Phoenix criteria using a total eight organ systems.  This is
#' intended mostly for research as an extension of the Phoenix Sepsis Criteria
#' which is based on four organ systems.
#'
#' The Phoenix Sepsis Criteria is based on the score form
#' respiratory, cardiovascular, coagulation, and neurologic.  Phoenix 8 uses
#' these four an endocrine, immunologic, renal, and hepatic.  Details on the
#' scoring for each of the eight component organ systems are found in the
#' respective manual files.
#'
#' @param pf_ratio numeric vector for the PaO2/FiO2 ratio; PaO2 = arterial oxygen pressure; FiO2 = fraction of inspired oxygen;  PaO2 is measured in mmHg and FiO2 is from 0.21 (room air) to 1.00.
#' @param sf_ratio numeric vector for the SpO2/FiO2 ratio; SpO2 = oxygen saturation, measured in a percent; ratio for 92\% oxygen saturation on room air is 92/0.21 = 438.0952.
#' @param imv invasive mechanical ventilation; numeric or integer vector, (0 = not intubated; 1 = intubated)
#' @param other_respiratory_support other respiratory support; numeric or integer vector, (0 = no support; 1 = support)
#' @param vasoactives an integer vector, the number of systemic vasoactive medications being administered to the patient.  Six vasoactive medications are considered: dobutamine, dopamine, epinephrine, milrinone, norepinephrine, vasopressin.
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
#' @param anc absolute neutrophil count; a numeric vector; units of 1,000 cells per cubic millimeter
#' @param alc absolute lymphocyte count; a numeric vector; units of 1,000 cells per cubic millimeter
#' @param creatinine numeric vector; units of mg/dL
#' @param bilirubin numeric vector; units of mg/dL
#' @param alt alanine aminotransferase; a numeric vector; units of IU/L
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
#'   \item \code{phoenix_septic_shock} 0 = no septic shock; 1 = septic shock (sepsis with cardiovascular dysfunction)
#'   \item \code{phoenix_endocrine_score}
#'   \item \code{phoenix_immunologic_score}
#'   \item \code{phoenix_renal_score}
#'   \item \code{phoenix_hepatic_score}
#'   \item \code{phoenix8_sepsis_score}
#' }
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
#' # Using the example sepsis data set, read more details in the vignette
#' phoenix8_scores <-
#'   phoenix8(
#'     # respiratory
#'       pf_ratio = pao2 / fio2,
#'       sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
#'       imv = vent,
#'       other_respiratory_support = as.integer(fio2 > 0.21),
#'     # cardiovascular
#'       vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
#'       lactate = lactate,
#'       age = age, # Also used in the renal assessment.
#'       map = dbp + (sbp - dbp)/3,
#'     # coagulation
#'       platelets = platelets,
#'       inr = inr,
#'       d_dimer = d_dimer,
#'       fibrinogen = fibrinogen,
#'     # neurologic
#'       gcs = gcs_total,
#'       fixed_pupils = as.integer(pupil == "both-fixed"),
#'     # endocrine
#'       glucose = glucose,
#'     # immunologic
#'       anc = anc,
#'       alc = alc,
#'     # renal
#'       creatinine = creatinine,
#'       # no need to specify age again
#'     # hepatic
#'       bilirubin = bilirubin,
#'       alt = alt,
#'     data = sepsis
#'   )
#'
#' str(phoenix8_scores)
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
  rtn <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- quote(phoenix_endocrine)
  rtn$phoenix_endocrine_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- quote(phoenix_immunologic)
  rtn$phoenix_immunologic_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- quote(phoenix_renal)
  rtn$phoenix_renal_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- quote(phoenix_hepatic)
  rtn$phoenix_hepatic_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  rtn$phoenix8_sepsis_score <-
    rtn[["phoenix_sepsis_score"]] +
    rtn[["phoenix_endocrine_score"]] +
    rtn[["phoenix_immunologic_score"]] +
    rtn[["phoenix_renal_score"]] +
    rtn[["phoenix_hepatic_score"]]
  rtn
}
