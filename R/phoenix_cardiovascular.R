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
#' DF <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               lactate = c(NA, 3.2, 5, 7.8, 11, 14),
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145),
#'               map = c(NA, 16:52))
#' DF$card <- phoenix_cardiovascular(vasos, lactate, age, map, DF)
#' head(DF)
#'
#' @export
phoenix_cardiovascular <- function(vasoactives, lactate, age, map, data, ...) {
  vas <- eval(expr = substitute(vasoactives), envir = data)
  lct <- eval(expr = substitute(lactate), envir = data)
  age <- eval(expr = substitute(age), envir = data)
  map <- eval(expr = substitute(map), envir = data)

  if ( (length(vas) != length(lct)) | (length(vas) != length(age)) | (length(vas) != length(map)) ) {
    stop("length of all input variables are not equal")
  }

  # set "healthy" value for missing data
  vas <- as.integer(replace(vas, which(is.na(vas)), 0))
  lct <- replace(lct, which(is.na(lct)), 0)

  # if age is missing then the MAP can not be assessed.  So, set the age value
  # to 18 _and_ the map to a high value too such that zero points will be scored
  missing_age_map <- which(is.na(age) | is.na(map))
  age <- replace(age, missing_age_map, 18)
  map <- replace(map, missing_age_map, 100)

  vas_score <- (vas >= 2L) + (vas >= 1L)
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
