#' Phoenix Immunologic Score
#'
#' Apply the Phoenix immunologic scoring based on ANC and ALC.  This is only
#' part of Phoenix-8 and not Phoenix.
#'
#' @section Phoenix Immunologic Scoring:
#' 1 point if ANC < 0.500 or ALC < 1.000 (units are 1000 cells per cubic millimeter).
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
#' @references See reference details in \code{\link{phoenix-package}} or by calling
#' \code{citation('phoenix')}.
#'
#' @examples
#'
#' # using the example sepsis data set
#' # Expected units for ALC and ANC are 1000 cells per cubic millimeter
#'
#' immu_example <- sepsis[c("pid", "anc", "alc")]
#' immu_example$score <- phoenix_immunologic(anc, alc, sepsis)
#' immu_example
#'
#' # example data set with all possilbe immunologic scores
#' # Expected units for anc and alc are 1000 cells per cubic millimeter
#'
#' DF <- expand.grid(anc = c(NA, 0.200, 0.500, 0.600),
#'                   alc = c(NA, 0.500, 1.000, 2.000))
#' phoenix_immunologic(anc = anc, alc = alc, data = DF)
#'
#' @export
phoenix_immunologic <- function(anc = NA_real_, alc = NA_real_, data = parent.frame(), ...) {

  anc <- eval(expr = substitute(anc), envir = data, enclos = parent.frame())
  alc <- eval(expr = substitute(alc), envir = data, enclos = parent.frame())

  length_check(anc = anc, alc = alc)

  # set "healthy" value for missing data
  # IMPORTANT: Recall the expected input units are 1000 cells / mm^3
  anc <- replace(anc, which(is.na(anc)), 555)
  alc <- replace(alc, which(is.na(alc)), 1111)

  as.integer((anc < 0.500) | (alc < 1.000)) 

}
