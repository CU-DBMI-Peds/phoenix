#' Phoenix Immunologic Score
#'
#' Apply the Phoenix immunologic scoring based on ANC and ALC.  This is only
#' part of Phoenix-8 and not Phoenix.
#'
#' @section Phoenix Immunologic Scoring:
#' 1 point if ANC < 500 or ALC < 1000 cells per cubic millimeter.
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
phoenix_immunologic <- function(anc = NA_real_, alc = NA_real_, data = parent.frame(), ...) {

  anc <- eval(expr = substitute(anc), envir = data)
  alc <- eval(expr = substitute(alc), envir = data)

  lngths <- c(length(anc), length(alc))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of anc is %s;",
                 "Length of alc is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  # set "healthy" value for missing data
  anc <- replace(anc, which(is.na(anc)), 555)
  alc <- replace(alc, which(is.na(alc)), 1111)

  as.integer((anc < 500) | (alc < 1000))
}
