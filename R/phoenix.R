#' The Phoenix Sepsis Score
#'
#' The diagnostic Phoenix Sepsis Criteria based on four organ dysfunction
#' scores, respiratory, cardiovascular, coagulation, and neurologic.  A score of
#' 2 or more indicates sepsis.
#'
#' The details of each of the four component scores are found in their
#' respective help files.
#'
#' The direct \code{phoenix()} wrapper uses the original respiratory P/F-or-S/F
#' threshold logic by default. Set \code{pao2.spo2.delta} to use the P/F versus
#' S/F source-time selector in \code{\link{phoenix_respiratory}}.
#'
#' For scheduled or row-level EHR scoring, callers may either provide a final
#' \code{mean_arterial_pressure} value or pass raw arterial/cuff MAP and SBP/DBP
#' candidates through \code{...}; those cardiovascular arguments are forwarded
#' to \code{\link{phoenix_cardiovascular}}. See that help file for the candidate
#' names and the \code{map.sdbp.delta} and \code{map.delta} freshness controls.
#'
#' @inheritParams phoenix8
#' @inheritParams phoenix_respiratory
#'
#' @return A \code{data.frame} with seven columns:
#' \enumerate{
#'   \item \code{phoenix_respiratory_score}
#'   \item \code{phoenix_cardiovascular_score}
#'   \item \code{phoenix_coagulation_score}
#'   \item \code{phoenix_neurologic_score}
#'   \item \code{phoenix_sepsis_score}
#'   \item \code{phoenix_sepsis}  An integer vector, 0 = not septic, 1 = septic (score greater or equal to 2)
#'   \item \code{phoenix_septic_shock} An integer vector, 0 = not septic shock, 1 = septic shock (score greater or equal 2 and cardiovascular dysfunction)
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
#' phoenix_scores <-
#'   phoenix(
#'     # Respiratory
#'       pf_ratio = pao2 / fio2,
#'       sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
#'       invasive_mechanical_ventilation = vent,
#'       other_respiratory_support = as.integer(fio2 > 0.21),
#'     # Cardiovascular
#'       vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
#'       lactate = lactate,
#'       age = age,
#'       mean_arterial_pressure = dbp + (sbp - dbp)/3,
#'     # Coagulation
#'       platelets = platelets,
#'       inr = inr,
#'       d_dimer = d_dimer,
#'       fibrinogen = fibrinogen,
#'     # Neurologic
#'       gcs = gcs_total,
#'       fixed_pupils = as.integer(pupil == "both-fixed"),
#'     data = sepsis
#'   )
#'
#' str(phoenix_scores)
#'
#' @export
phoenix <- function(pf_ratio, sf_ratio, invasive_mechanical_ventilation, other_respiratory_support,
                    vasoactives, lactate, mean_arterial_pressure = NA_real_, # age at the end to be consistent with phoenix8
                    platelets, inr, d_dimer, fibrinogen,
                    gcs, fixed_pupils,
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
  cl[["data"]] <- NULL

  cl[[1]] <- get("phoenix_respiratory", mode = "function")
  resp <- eval(as.call(cl), envir = data, enclos = parent.frame())
  cl[[1]] <- get("phoenix_cardiovascular", mode = "function")
  card <- eval(as.call(cl), envir = data, enclos = parent.frame())
  cl[[1]] <- get("phoenix_coagulation", mode = "function")
  coag <- eval(as.call(cl), envir = data, enclos = parent.frame())
  cl[[1]] <- get("phoenix_neurologic", mode = "function")
  neur <- eval(as.call(cl), envir = data, enclos = parent.frame())

  # TeX: row-level sum over eq:omega4 used in eq:odss.
  # The sepsis and septic shock columns are legacy ungated indicators; PSS-gated
  # definitions with suspected infection are in score_prepared_phoenix_data().
  rtn <-
    data.frame(
      phoenix_respiratory_score    = resp,
      phoenix_cardiovascular_score = card,
      phoenix_coagulation_score    = coag,
      phoenix_neurologic_score     = neur,
      phoenix_sepsis_score         = card + resp + coag + neur,
      phoenix_sepsis               = as.integer(card + resp + coag + neur > 1),
      phoenix_septic_shock         = as.integer((card > 0) & (card + resp + coag + neur > 1))
    )

  rtn
}
