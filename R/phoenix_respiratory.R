#' Phoenix Respiratory Score
#'
#' Apply the Phoenix Respiratory Scoring rubric to a data set.  The respiratory
#' score is part of the diagnostic Phoenix Sepsis criteria and the diagnostic
#' Phoenix 8 Sepsis criteria.
#'
#' \code{pf_ratio} is the ratio of partial pressure of oxygen in arterial blood
#' (PaO2) to the fraction of inspiratory oxygen concentration (FiO2).
#'
#' \code{sf_ratio} is a non-invasive surrogate for \code{pf_ratio} using pulse
#' oximetry (SpO2) instead of invasive PaO2.
#'
#' Important Note: when the Phoenix Sepsis criteria was developed there is
#' a requirement that SpO2 < 97 in order for the \code{sf_ratio} to be valid.
#' That assumption is not checked in this code and it is left to the end user to
#' account for this when building the \code{sf_ratio} vector.
#'
#' \code{imv} Invasive mechanical ventilation - integer vector where 0 = not
#' intubated and 1 = intubated.
#'
#' \code{other_respiratory_support} other respiratory support such as receiving oxygen,
#' high-flow, non-invasive positive pressure, or imv.
#'
#' @section Phoenix Respiratory Scoring:
#' \tabular{llll}{
#' 0 points \tab 1 point \tab 2 points \tab 3 points \cr
#' pf_ratio >= 400 and sf_ratio >= 292 \tab
#' (pf_ratio < 400 or sf_ratio < 292) and any respiratory support \tab
#' (pf_ratio < 200 or sf_ratio < 220) and imv \tab
#' (pf_ratio < 100 or sf_ratio < 148) and imv \cr
#' }
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0, 1, 2, or 3.
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
#'
#' @examples
#'
#' # Using the provided example data set:
#' phoenix_respiratory(
#'   pf_ratio = pao2 / fio2,
#'   sf_ratio = spo2 / fio2,
#'   imv      = vent,
#'   other_respiratory_support = as.integer(fio2 > 0.21),
#'   data = sepsis
#' )
#'
#' # A set of values that will get all possible respiratory scores:
#' DF <- expand.grid(
#'   pfr = c(NA, 500, 400, 350, 200, 187, 100, 56),
#'   sfr = c(NA, 300, 292, 254, 220, 177, 148, 76),
#'   vent = c(NA, 0, 1),
#'   o2  = c(NA, 0, 1)
#' )
#'
#' phoenix_respiratory(
#'   pf_ratio = pfr,
#'   sf_ratio = sfr,
#'   imv = vent,
#'   other_respiratory_support = o2,
#'   data = DF
#' )
#'
#'
#' @export
phoenix_respiratory <- function(pf_ratio = NA_real_, sf_ratio = NA_real_, imv = NA_integer_, other_respiratory_support = NA_integer_, data = parent.frame(), ...) {

  pfr <- eval(expr = substitute(pf_ratio), envir = data)
  sfr <- eval(expr = substitute(sf_ratio), envir = data)
  imv <- eval(expr = substitute(imv),      envir = data)
  ors <- eval(expr = substitute(other_respiratory_support), envir = data)

  lngths <- c(length(pfr), length(sfr), length(imv), length(ors))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of pf_ratio is %s;",
                 "Length of sf_ratio is %s;",
                 "Length of imv is %s;",
                 "Length of other_respiratory_support is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  # set "healthy" value for missing data
  pfr <- replace(pfr, which(is.na(pfr)), 500)
  sfr <- replace(sfr, which(is.na(sfr)), 500)
  imv <- as.integer(replace(imv, which(is.na(imv)), 0))
  stopifnot(all(imv %in% c(0L, 1L)))
  ors <- as.integer(replace(ors, which(is.na(ors)), 0))
  stopifnot(all(ors %in% c(0L, 1L)))
  ors <- pmax(imv, ors)

  imv * ( ((pfr < 100) | (sfr < 148)) + ((pfr < 200) | (sfr < 220)) ) +
  ors * ((pfr < 400) | (sfr < 292))

}
