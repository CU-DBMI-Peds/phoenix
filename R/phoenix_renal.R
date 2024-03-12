#' Phoenix Renal Score
#'
#' Apply the Phoenix renal organ dysfunction score based on age adjusted
#' creatinine levels.
#'
#' @section Phoenix Renal Scoring:
#'
#'  \tabular{lll}{
#'    Age in [0, 1) months \tab \tab \cr
#'      \tab creatinine [0, 0.8) mg/dL \tab 0 points \cr
#'      \tab creatinine [0.8, Inf) mg/dL \tab 1 point  \cr
#'    Age in [1, 12) months \tab \tab \cr
#'      \tab creatinine in [0, 0.3) mg/dL \tab 0 points \cr
#'      \tab creatinine in [0.3, Inf)  mg/dL \tab 1 point  \cr
#'    Age in [12, 24) months \tab\tab \cr
#'      \tab creatinine in [0, 0.4) mg/dL \tab 0 points \cr
#'      \tab creatinine in [0.4, Inf)  mg/dL \tab 1 point  \cr
#'    Age in [24, 60) months \tab\tab \cr
#'      \tab creatinine in [0, 0.6) mg/dL \tab 0 points \cr
#'      \tab creatinine in [0.6, Inf)  mg/dL \tab 1 point  \cr
#'    Age in [60, 144) months \tab\tab \cr
#'      \tab creatinine in [0, 0.7) mg/dL \tab 0 points \cr
#'      \tab creatinine in [0.7, Inf)  mg/dL \tab 1 point  \cr
#'    Age in [144, 216] months \tab\tab \cr
#'      \tab creatinine in [0, 1.0) mg/dL \tab 0 points \cr
#'      \tab creatinine in [1.0, Inf)  mg/dL \tab 1 point  \cr
#'  }
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0, 1, or 2
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
#' renal_example <- sepsis[c("creatinine", "age")]
#' renal_example$score <- phoenix_renal(creatinine, age, sepsis)
#' renal_example
#'
#' # build an example data set with all possible neurologic scores
#' DF <- expand.grid(age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145),
#'                   creatinine = c(NA, seq(0.0, 1.1, by = 0.1)))
#' DF$card <- phoenix_renal(age = age, creatinine = creatinine, data = DF)
#'
#' head(DF)
#'
#' @export
phoenix_renal <- function(creatinine = NA_real_, age = NA_real_, data = parent.frame(), ...) {

  crt <- eval(expr = substitute(creatinine), envir = data)
  age <- eval(expr = substitute(age), envir = data)

  lngths <- c(length(crt), length(age))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of creatinine is %s;",
                 "Length of age is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  # set "healthy" value for missing data
  missing_idx <- which(is.na(age) | is.na(crt))
  age <- replace(age, missing_idx, 0)
  crt <- replace(crt, missing_idx, 0)

  (age >=   0 & age <    1) * (crt >= 0.8) +
  (age >=   1 & age <   12) * (crt >= 0.3) +
  (age >=  12 & age <   24) * (crt >= 0.4) +
  (age >=  24 & age <   60) * (crt >= 0.6) +
  (age >=  60 & age <  144) * (crt >= 0.7) +
  (age >= 144 & age <= 216) * (crt >= 1.0)

}
