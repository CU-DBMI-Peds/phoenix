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
#' @param pf_ratio numeric vector
#' @param sf_ratio numeric vector
#' @param imv invasive mechanical ventilation; numeric or integer vector, (0 = not
#' intubated; 1 = intubated)
#' @param other_respiratory_support other respiratory support; numeric or integer vector, (0
#' = no support; 1 = support)
#' @param data a \code{list}, \code{data.frame}, or object that can be coerced
#' to a \code{data.frame}, containing the input vectors
#' @param ... pass through
#'
#' @return a integer vector with values 0, 1, 2, or 3.
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
#'
#' DF <- expand.grid(
#'   pfr = c(NA, 500, 400, 350, 200, 187, 100, 56),
#'   sfr = c(NA, 300, 292, 254, 220, 177, 148, 76),
#'   vent = c(NA, 0, 1),
#'   o2  = c(NA, 0, 1))
#' phoenix_respiratory(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2, data = DF)
#'
#' @export
phoenix_respiratory <- function(pf_ratio, sf_ratio, imv, other_respiratory_support, data = parent.frame(), ...) {

  pfr <- eval(expr = substitute(pf_ratio), envir = data)
  sfr <- eval(expr = substitute(sf_ratio), envir = data)
  imv <- eval(expr = substitute(imv),      envir = data)
  ors <- eval(expr = substitute(other_respiratory_support), envir = data)

  if ( (length(pfr) != length(sfr)) | (length(pfr) != length(imv)) | (length(pfr) != length(ors)) ) {
    stop("length of all input variables are not equal")
  }

  # set "healthy" value for missing data
  pfr <- replace(pfr, which(is.na(pfr)), 500)
  sfr <- replace(sfr, which(is.na(sfr)), 500)
  imv <- as.integer(replace(imv, which(is.na(imv)), 0))
  stopifnot(all(imv %in% c(0L, 1L)))
  ors <- as.integer(replace(ors, which(is.na(ors)), 0))
  stopifnot(all(ors %in% c(0L, 1L)))
  ors <- pmax(imv, ors)

  phoenixRespiratory(pfr, sfr, imv, ors)[, 1]

}
