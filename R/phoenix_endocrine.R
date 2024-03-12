#' Phoenix Endocrine Score
#'
#' Assess the Phoenix endocrine organ dysfunction score.  This score is not part
#' of the Phoenix score, only part of the Phoenix-8 score.
#'
#' @section Phoenix Endocrine Scoring: The endocrine dysfunction score is based
#' on blood glucose with one point for levels < 50 mg/dL or > 150 mg/dL.
#'
#' @inheritParams phoenix8
#'
#' @return a integer vector with values 0 or 1
#'
#' As with all other Phoenix organ system scores, missing values in the data set
#' will map to a score of zero - this is consistent with the development of the
#' criteria.
#'
#' @seealso \itemize{ \item \code{\link{phoenix}} for generating the diagnostic
#' Phoenix Sepsis score based on the four organ systems: \itemize{ \item
#' \code{\link{phoenix_cardiovascular}}, \item
#' \code{\link{phoenix_coagulation}}, \item \code{\link{phoenix_neurologic}},
#' \item \code{\link{phoenix_respiratory}}, } \item \code{\link{phoenix8}} for
#' generating the diagnostic Phoenix 8 Sepsis criteria based on the four organ
#' systems noted above and \itemize{ \item \code{\link{phoenix_endocrine}},
#' \item \code{\link{phoenix_immunologic}}, \item \code{\link{phoenix_renal}},
#' \item \code{\link{phoenix_hepatic}}, } }
#'
#' \code{vignette('phoenix')} for more details and examples.
#'
#' @references See reference details in \code{\link{phoenix-package}} or by calling
#' \code{citation('phoenix')}.
#'
#' @examples
#'
#' # using the example sepsis data set
#' endo_example <- sepsis[c("pid", "glucose")]
#' endo_example$score <- phoenix_endocrine(glucose, data = sepsis)
#' endo_example
#'
#' # example data set to get all the possible endocrine scores
#' DF <- data.frame(glc = c(NA, 12, 50, 55, 100, 150, 178))
#' phoenix_endocrine(glucose = glc, data = DF)
#'
#' @export
phoenix_endocrine <- function(glucose = NA_real_, data = parent.frame(), ...) {

  glc <- eval(expr = substitute(glucose), envir = data)

  # set "healthy" value for missing data
  glc <- replace(glc, which(is.na(glc)), 100)

  as.integer((glc < 50) | (glc > 150))
}
