#' Phoenix Cardiovascular Score
#'
#' Generate the cardiovascular organ system dysfunction score as part of the
#' diagnostic Phoenix Sepsis Criteria.
#'
#' There were six systemic vasoactive medications considered when the Phoenix
#' criteria was developed: dobutamine, dopamine, epinephrine, milrinone,
#' norepinephrine, and vasopressin.
#'
#' During development, the values used for \code{mean_arterial_pressure} were taken preferentially
#' from arterial measurement, then cuff measures, and provided values before
#' approximating mean arterial pressure from blood pressure values via DBP + 1/3 (SBP - DBP),
#' where DBP is the diastolic blood pressure and SBP is the systolic blood
#' pressure.
#'
#' @section Phoenix Cardiovascular Scoring:
#' The Phoenix Cardiovascular score ranges from 0 to 6 points; 0, 1, or 2 points
#' for each of systemic vasoactive medications, lactate, and MAP.
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
#'    Age in [0, 1) months  \tab \tab \cr
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
#'    Age in [144, 216) months \tab\tab \cr
#'      \tab [52, Inf) mmHg \tab 0 points \cr
#'      \tab [38, 52)  mmHg \tab 1 point  \cr
#'      \tab [0, 38)   mmHg \tab 2 points \cr
#'  }
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0, 1, 2, 3, 4, 5, or 6.
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
#' # using the example sepsis data set
#' phoenix_cardiovascular(
#'    vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
#'    lactate = lactate,
#'    age = age,
#'    mean_arterial_pressure = dbp + (sbp - dbp)/3,
#'    data = sepsis
#' )
#'
#' # example data set to get all the possible scores
#' DF <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               lactate = c(NA, 3.2, 5, 7.8, 11, 14), # units of mmol/L
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
#'               mean_arterial_pressure = c(NA, 16:52)) # mmHg
#' DF$card <- phoenix_cardiovascular(vasos, lactate, age, mean_arterial_pressure, DF)
#' head(DF)
#'
#' # what if lactate is unknown for all records? - set the value either in the
#' # data object or the argument value to NA
#' DF2 <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
#'               mean_arterial_pressure = c(NA, 16:52)) # mmHg
#' DF2$card <- phoenix_cardiovascular(vasos, lactate = NA, age, mean_arterial_pressure, DF2)
#'
#' DF3 <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               lactate = NA, # mmol/L
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
#'               mean_arterial_pressure = c(NA, 16:52)) # mmHg
#' DF3$card <- phoenix_cardiovascular(vasos, lactate, age, mean_arterial_pressure, DF3)
#'
#' identical(DF2$card, DF3$card)
#'
#' @export
phoenix_cardiovascular <- function(vasoactives = NA_integer_, lactate = NA_real_, age = NA_real_, mean_arterial_pressure = NA_real_, data = parent.frame(), ..., map = NULL) {
  if (is.environment(data) && identical(parent.env(data), emptyenv())) {
    stop(
      "`data` is an environment with parent `emptyenv()`, so expressions ",
      "cannot resolve base functions/operators. Use `baseenv()` as the parent, ",
      "for example `list2env(x, parent = baseenv())`."
    )
  }

  if (inherits(data, "data.frame") && nrow(data) == 0L) {
    return(integer(0L))
  }

  cl <- match.call(expand.dots = FALSE)
  has_map <- "map" %in% names(cl)
  has_mean_arterial_pressure <- "mean_arterial_pressure" %in% names(cl)

  if (has_map && has_mean_arterial_pressure) {
    stop("Use only one of `mean_arterial_pressure` or its deprecated alias `map`.", call. = FALSE)
  }

  if (has_map) {
    warning("`map` is deprecated; use `mean_arterial_pressure` instead.", call. = FALSE)
    mean_arterial_pressure_expr <- substitute(map)
  } else {
    mean_arterial_pressure_expr <- substitute(mean_arterial_pressure)
  }

  vas <- eval(expr = substitute(vasoactives), envir = data, enclos = parent.frame())
  lct <- eval(expr = substitute(lactate), envir = data, enclos = parent.frame())
  age <- eval(expr = substitute(age), envir = data, enclos = parent.frame())
  mean_arterial_pressure <- eval(expr = mean_arterial_pressure_expr, envir = data, enclos = parent.frame())

  lngths <- c(length(vas), length(lct), length(age), length(mean_arterial_pressure))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of vasoactives is %s;",
                 "Length of lactate is %s;",
                 "Length of age is %s;",
                 "Length of mean_arterial_pressure is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  # set "healthy" value for missing data
  vas <- as.integer(replace(vas, which(is.na(vas)), 0))
  lct <- replace(lct, which(is.na(lct)), 0)

  # if age is missing then the MAP can not be assessed.  So, set the age value
  # more than 18 years _and_ mean arterial pressure to a high value too such that zero points
  # will be scored
  missing_age_map <- which(is.na(age) | is.na(mean_arterial_pressure))
  age <- replace(age, missing_age_map, 222)
  mean_arterial_pressure <- replace(mean_arterial_pressure, missing_age_map, 100)

  # TeX: eq:card combines eq:vasos, eq:map, and eq:lactate.
  vas_score <- vasoactive_score(vas)
  lct_score <- lactate_score(lct)
  map_score <- map_score(mean_arterial_pressure, age)

  vas_score + lct_score + map_score
}

# non-exported methods that are used in
# phoenix_cardiovascular() and score_prepared_phoenix_data()
vasoactive_score <- function(x) {
  # TeX: eq:vasos.
  rtn <- as.integer(x > 1) + as.integer(x > 0)
  rtn[is.na(rtn)] <- 0L
  rtn
}

lactate_score <- function(x) {
  # TeX: eq:lactate.
  rtn <- as.integer(x >= 11) + as.integer(x >= 5)
  rtn[is.na(rtn)] <- 0L
  rtn
}

map_score <- function(map, age) {
  # TeX: eq:theta1, eq:theta2, and eq:map.
  rtn <- (
    (age >=   0 & age <    1) * ((map < 17) + (map < 31)) +
    (age >=   1 & age <   12) * ((map < 25) + (map < 39)) +
    (age >=  12 & age <   24) * ((map < 31) + (map < 44)) +
    (age >=  24 & age <   60) * ((map < 32) + (map < 45)) +
    (age >=  60 & age <  144) * ((map < 36) + (map < 49)) +
    (age >= 144 & age <  216) * ((map < 38) + (map < 52))
  )
  rtn[is.na(rtn)] <- 0L
  rtn
}
