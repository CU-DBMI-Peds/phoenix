#' Phoenix Immunologic Score
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0 or 1
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
#' # using the example sepsis data set
#' immu_example <- sepsis[c("pid", "anc", "alc")]
#' immu_example$score <- phoenix_immunologic(anc, alc, sepsis)
#' immu_example
#'
#' # using the example sepsis data set
#' hep_example <- sepsis[c("pid", "bilirubin", "alt")]
#' hep_example$score <- phoenix_hepatic(bilirubin, alt, sepsis)
#' hep_example
#'
#' # example data set with all possilbe hepatic scores
#' DF <- expand.grid(anc = c(NA, 200, 500, 600), alc = c(NA, 500, 1000, 2000))
#' phoenix_immunologic(anc = anc, alc = alc, data = DF)
#'
#' @export
phoenix_immunologic <- function(anc, alc, data = parent.frame(), ...) {

  if (missing(anc)) {
    anc <- NA_real_
  } else {
    anc <- eval(expr = substitute(anc), envir = data)
  }

  if (missing(alc)) {
    alc <- NA_real_
  } else {
    alc <- eval(expr = substitute(alc), envir = data)
  }

  n <- max(c(length(anc), length(alc)))

  if (n > 1) {
    if (length(anc) == 1) {
      anc <- rep(anc, n)
    } else if (length(anc) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of anc is %s, needs to be either 1 or %s."
                   , length(anc), n))
    }
    if (length(alc) == 1) {
      alc <- rep(alc, n)
    } else if (length(alc) != n) {
      stop(sprintf("All inputs need to have same length or length 1.\nLength of alc is %s, needs to be either 1 or %s."
                   , length(alc), n))
    }
  }

  # set "healthy" value for missing data
  anc <- replace(anc, which(is.na(anc)), 555)
  alc <- replace(alc, which(is.na(alc)), 1111)

  as.integer((anc < 500) | (alc < 1000))
}
