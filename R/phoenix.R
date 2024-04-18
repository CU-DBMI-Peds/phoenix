#' The Phoenix Sepsis Score
#'
#' The diagnostic Phoenix Sepsis Criteria based on four organ dysfunction
#' scores, respiratory, cardiovascular, coagulation, and neurologic.  A score of
#' 2 or more indicates sepsis.
#'
#' The details of each of the four component scores are found in there
#' respective help files.
#'
#' @inheritParams phoenix8
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
#' phoenix_scores <-
#'   phoenix(
#'     # respiratory
#'       pf_ratio = pao2 / fio2,
#'       sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
#'       imv = vent,
#'       other_respiratory_support = as.integer(fio2 > 0.21),
#'     # cardiovascular
#'       vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
#'       lactate = lactate,
#'       age = age,
#'       map = dbp + (sbp - dbp)/3,
#'     # coagulation
#'       platelets = platelets,
#'       inr = inr,
#'       d_dimer = d_dimer,
#'       fibrinogen = fibrinogen,
#'     # neurologic
#'       gcs = gcs_total,
#'       fixed_pupils = as.integer(pupil == "both-fixed"),
#'     data = sepsis
#'   )
#'
#' str(phoenix_scores)
#'
#' @export
phoenix <- function(pf_ratio, sf_ratio, imv, other_respiratory_support,
                    vasoactives, lactate, map, # age at the end to be consistent with phoenix8
                    platelets, inr, d_dimer, fibrinogen,
                    gcs, fixed_pupils,
                    age,
                    data = parent.frame(), ...) {

  cl <- as.list(match.call())
  cl[["data"]] <- NULL

  cl[[1]] <- quote(phoenix_respiratory)
  resp <- eval(as.call(cl), envir = data, enclos = parent.frame())
  cl[[1]] <- quote(phoenix_cardiovascular)
  card <- eval(as.call(cl), envir = data, enclos = parent.frame())
  cl[[1]] <- quote(phoenix_coagulation)
  coag <- eval(as.call(cl), envir = data, enclos = parent.frame())
  cl[[1]] <- quote(phoenix_neurologic)
  neur <- eval(as.call(cl), envir = data, enclos = parent.frame())

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
