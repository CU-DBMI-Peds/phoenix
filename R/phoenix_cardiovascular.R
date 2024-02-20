#' Phoenix Cardiovascular Score
#'
#' Generate the cardiovascular organ system dysfunciton score as part of the
#' diagnostic Phoenix Sepsis Criteria.
#'
#' There where six systemic vasoactive medications considered when the Phoenix
#' criteria was developed: dobutamine, dopamine, epinephrine, milrinone,
#' norepinephrine, and vasopressin.
#'
#' During development, the values used for \code{map} were taken preferentially
#' from arterial measuremens, then cuff measures, and provided values before
#' approxating the map from blood pressure values via DBP + 1/3 (SBP - DBP),
#' where DBP is the diastolic blood pressure and SBP is the systolic blood
#' pressure.
#'
#' @section Scoring:
#' The Phoenix Cardiovascular score ranges from 0 to 6 points; 0, 1, or 2 points
#' for each of systolic vasoactive medications, lactate, and MAP.
#'
#' \emph{Systemic Vasoactive Medications}
#' \tabular{ll}{
#'   0 medications \tab 0 points \cr
#'   1 medication  \tab 1 point  \cr
#'   2 or more medications \tab 2 points
#' }
#'
#'  \emph{Lactate}
#'  \tabular{ll}{
#'     [0, 5) \tab 0 points \cr
#'     [5, 11) \tab 1 point  \cr
#'     [11, Inf) \tab 2 points
#'  }
#'
#'  \emph{MAP}
#'  \tabular{lll}{
#'    Age < 1month \tab \tab \cr
#'      \tab [31, Inf) mmHg \tab 0 points \cr
#'      \tab [17, 31)  mmHg \tab 1 point  \cr
#'      \tab [0, 17)   mmHg \tab 2 points \cr
#'    Age in [1, 12) months \tab \tab \cr
#'      \tab [39, Inf) mmHg \tab 0 points \cr
#'      \tab [25, 39)  mmHg \tab 1 point  \cr
#'      \tab [0, 25)   mmHg \tab 2 points \cr
#'    Age in [12, 24) months \tab\tab \cr
#'      \tab [44, Inf) mmHg \tab 0 points \cr
#'      \tab [31, 44)  mmHg \tab 1 point  \cr
#'      \tab [0, 31)   mmHg \tab 2 points \cr
#'    Age in [24, 60) months \tab\tab \cr
#'      \tab [45, Inf) mmHg \tab 0 points \cr
#'      \tab [32, 45)  mmHg \tab 1 point  \cr
#'      \tab [0, 32)   mmHg \tab 2 points \cr
#'    Age in [60, 144) months \tab\tab \cr
#'      \tab [49, Inf) mmHg \tab 0 points \cr
#'      \tab [36, 49)  mmHg \tab 1 point  \cr
#'      \tab [0, 36)   mmHg \tab 2 points \cr
#'    Age in [144, Inf) months \tab\tab \cr
#'      \tab [52, Inf) mmHg \tab 0 points \cr
#'      \tab [38, 52)  mmHg \tab 1 point  \cr
#'      \tab [0, 38)   mmHg \tab 2 points \cr
#'  }
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0, 1, 2, 3, 4, 5, or 6.
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
#' DF <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               lactate = c(NA, 3.2, 5, 7.8, 11, 14),
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145),
#'               map = c(NA, 16:52))
#' DF$card <- phoenix_cardiovascular(vasos, lactate, age, map, DF)
#' head(DF)
#'
#' # what if lactate is unknown for all records? - set the value either in the
#' # data object or the arguement value to NA
#' DF2 <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145),
#'               map = c(NA, 16:52))
#' DF2$card <- phoenix_cardiovascular(vasos, lactate = NA, age, map, DF2)
#'
#' DF3 <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               lactate = NA,
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145),
#'               map = c(NA, 16:52))
#' DF3$card <- phoenix_cardiovascular(vasos, lactate, age, map, DF3)
#'
#' identical(DF2$card, DF3$card)
#'
#'
#' @export
phoenix_cardiovascular <- function(vasoactives, lactate, age, map, data = parent.frame(), ...) {
  vas <- eval(expr = substitute(vasoactives), envir = data)
  lct <- eval(expr = substitute(lactate), envir = data)
  age <- eval(expr = substitute(age), envir = data)
  map <- eval(expr = substitute(map), envir = data)

  n <- max(c(length(vas), length(lct), length(age), length(map)))

  if (n > 1) {
    if (length(vas) == 1) {
      vas <- rep(vas, n)
    } else if (length(vas) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of vasoactives is %s, needs to be either 1 or %s."
                   , length(vas), n))
    }
    if (length(lct) == 1) {
      lct <- rep(lct, n)
    } else if (length(lct) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of lactate is %s, needs to be either 1 or %s."
                   , length(lct), n))
    }
    if (length(age) == 1) {
      age <- rep(age, n)
    } else if (length(age) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of age is %s, needs to be either 1 or %s."
                   , length(age), n))
    }
    if (length(map) == 1) {
      map <- rep(map, n)
    } else if (length(map) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of map is %s, needs to be either 1 or %s."
                   , length(map), n))
    }
  }

  # set "healthy" value for missing data
  vas <- as.integer(replace(vas, which(is.na(vas)), 0))
  lct <- replace(lct, which(is.na(lct)), 0)

  # if age is missing then the MAP can not be assessed.  So, set the age value
  # more than 18 years _and_ the map to a high value too such that zero points
  # will be scored
  missing_age_map <- which(is.na(age) | is.na(map))
  age <- replace(age, missing_age_map, 222)
  map <- replace(map, missing_age_map, 100)

  vas_score <- (vas > 1) + (vas > 0)
  lct_score <- (lct >= 11) + (lct >= 5)
  map_score <-
     (
      (             age <   1) * ((map < 17) + (map < 31)) +
      (age >=   1 & age <  12) * ((map < 25) + (map < 39)) +
      (age >=  12 & age <  24) * ((map < 31) + (map < 44)) +
      (age >=  24 & age <  60) * ((map < 32) + (map < 45)) +
      (age >=  60 & age < 144) * ((map < 36) + (map < 49)) +
      (age >= 144            ) * ((map < 38) + (map < 52))
    )

  vas_score + lct_score + map_score
}
