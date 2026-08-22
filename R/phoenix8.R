#' The Phoenix 8 Sepsis Score
#'
#' The extended Phoenix criteria using a total eight organ systems.  This is
#' intended mostly for research as an extension of the Phoenix Sepsis Criteria
#' which is based on four organ systems.
#'
#' The Phoenix Sepsis Criteria is based on the scores from
#' respiratory, cardiovascular, coagulation, and neurologic systems.  Phoenix 8 uses
#' these four plus endocrine, immunologic, renal, and hepatic.  Details on the
#' scoring for each of the eight component organ systems are found in the
#' respective manual files.
#'
#' Like \code{\link{phoenix}}, the direct \code{phoenix8()} wrapper uses the
#' original respiratory P/F-or-S/F threshold logic by default. Set
#' \code{pao2.spo2.delta} to use the P/F versus S/F source-time selector in
#' \code{\link{phoenix_respiratory}}.
#'
#' @inheritParams phoenix_respiratory
#' @param pf_ratio numeric vector for the PaO2/FiO2 ratio; PaO2 = arterial oxygen pressure; FiO2 = fraction of inspired oxygen;  PaO2 is measured in mmHg and FiO2 is from 0.21 (room air) to 1.00.
#' @param sf_ratio numeric vector for the SpO2/FiO2 ratio; SpO2 = oxygen saturation, measured in a percent; ratio for 92\% oxygen saturation on room air is 92/0.21 = 438.0952.
#' @param invasive_mechanical_ventilation invasive mechanical ventilation; numeric or integer vector, (0 = not intubated; 1 = intubated)
#' @param imv soft-deprecated alias for \code{invasive_mechanical_ventilation}
#' @param other_respiratory_support other respiratory support; numeric or integer vector, (0 = no support; 1 = support)
#' @param vasoactives an integer vector, the number of systemic vasoactive medications being administered to the patient.  Six vasoactive medications are considered: dobutamine, dopamine, epinephrine, milrinone, norepinephrine, vasopressin.
#' @param lactate numeric vector with the lactate value in mmol/L
#' @param age numeric vector age in months; valid range is [0, 216)
#' @param mean_arterial_pressure numeric vector, mean arterial pressure in mmHg
#' @param map soft-deprecated alias for \code{mean_arterial_pressure}
#' @param platelets numeric vector for platelets counts in units of 1,000/uL (thousand per microliter)
#' @param inr numeric vector for the international normalised ratio blood test
#' @param d_dimer numeric vector for D-Dimer, units of mg/L FEU
#' @param fibrinogen numeric vector units of mg/dL
#' @param gcs integer vector; total Glasgow Coma Score
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
#'
#' phoenix8_scores <-
#'   phoenix8(
#'     # Respiratory
#'       pf_ratio = pao2 / fio2,
#'       sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
#'       invasive_mechanical_ventilation = vent,
#'       other_respiratory_support = as.integer(fio2 > 0.21),
#'     # Cardiovascular
#'       vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
#'       lactate = lactate,
#'       age = age, # Also used in the renal assessment.
#'       mean_arterial_pressure = dbp + (sbp - dbp)/3,
#'     # Coagulation
#'       platelets = platelets,
#'       inr = inr,
#'       d_dimer = d_dimer,
#'       fibrinogen = fibrinogen,
#'     # Neurologic
#'       gcs = gcs_total,
#'       fixed_pupils = as.integer(pupil == "both-fixed"),
#'     # Endocrine
#'       glucose = glucose,
#'     # Immunologic
#'       anc = anc,
#'       alc = alc,
#'     # Renal
#'       creatinine = creatinine,
#'       # no need to specify age again
#'     # Hepatic
#'       bilirubin = bilirubin,
#'       alt = alt,
#'     data = sepsis
#'   )
#'
#' str(phoenix8_scores)
#'
#' @export
phoenix8 <- function(
                    pf_ratio, sf_ratio, invasive_mechanical_ventilation, other_respiratory_support,
                    vasoactives, lactate, mean_arterial_pressure, #age
                    platelets, inr, d_dimer, fibrinogen,
                    gcs, fixed_pupils,
                    glucose,
                    anc, alc,
                    creatinine,  #age
                    bilirubin, alt,
                    age,
                    data = parent.frame(), pao2.spo2.delta = NULL,
                    ..., imv = NULL, map = NULL) {

  cl <- as.list(match.call())
  if ("imv" %in% names(cl) && "invasive_mechanical_ventilation" %in% names(cl)) {
    stop("Use only one of `invasive_mechanical_ventilation` or its deprecated alias `imv`.", call. = FALSE)
  }
  if ("imv" %in% names(cl)) {
    warning("`imv` is deprecated; use `invasive_mechanical_ventilation` instead.", call. = FALSE)
    cl[["invasive_mechanical_ventilation"]] <- cl[["imv"]]
    cl[["imv"]] <- NULL
  }
  if ("map" %in% names(cl) && "mean_arterial_pressure" %in% names(cl)) {
    stop("Use only one of `mean_arterial_pressure` or its deprecated alias `map`.", call. = FALSE)
  }
  if ("map" %in% names(cl)) {
    warning("`map` is deprecated; use `mean_arterial_pressure` instead.", call. = FALSE)
    cl[["mean_arterial_pressure"]] <- cl[["map"]]
    cl[["map"]] <- NULL
  }
  # Direct phoenix()/phoenix8() calls preserve the original PFR-or-SFR logic by
  # default. Prepared-data scoring uses its own default for eq:pfr-sfr-selector.
  cl[["pao2.spo2.delta"]] <- pao2.spo2.delta
  cl$data <- NULL

  cl[[1]] <- get("phoenix", mode = "function")
  rtn <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- get("phoenix_endocrine", mode = "function")
  rtn$phoenix_endocrine_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- get("phoenix_immunologic", mode = "function")
  rtn$phoenix_immunologic_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- get("phoenix_renal", mode = "function")
  rtn$phoenix_renal_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  cl[[1]] <- get("phoenix_hepatic", mode = "function")
  rtn$phoenix_hepatic_score <- eval(as.call(cl), envir = data, enclos = parent.frame())

  # TeX: row-level sum over eq:omega8 used in eq:odss.
  rtn$phoenix8_sepsis_score <-
    rtn[["phoenix_sepsis_score"]] +
    rtn[["phoenix_endocrine_score"]] +
    rtn[["phoenix_immunologic_score"]] +
    rtn[["phoenix_renal_score"]] +
    rtn[["phoenix_hepatic_score"]]
  rtn
}
