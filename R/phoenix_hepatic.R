#' Phoenix Hepatic Score
#'
#' Apply the Phoenix Hepatic scoring based on total bilirubin and ALT.
#'
#' @section Phoenix Hepatic Scoring:
#' 1 point for total bilirubin greater or equal to 4 mg/dL and/or ALT strictly
#' greater than 102 IU/L.
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
#' hep_example <- sepsis[c("pid", "bilirubin", "alt")]
#' hep_example$score <- phoenix_hepatic(bilirubin, alt, sepsis)
#' hep_example
#'
#' # example data set with all possilbe hepatic scores
#' DF <- expand.grid(bil = c(NA, 3.2, 4.0, 4.3), alt = c(NA, 99, 102, 106))
#' phoenix_hepatic(bilirubin = bil, alt = alt, data = DF)
#' @export
phoenix_hepatic <- function(bilirubin = NA_real_, alt = NA_real_, data = parent.frame(), ...) {

  bil <- eval(expr = substitute(bilirubin), envir = data)
  alt <- eval(expr = substitute(alt), envir = data)

  lngths <- c(length(bil), length(alt))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of bilirubin is %s;",
                 "Length of alt is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  # set "healthy" value for missing data
  bil <- replace(bil, which(is.na(bil)), 0)
  alt <- replace(alt, which(is.na(alt)), 0)

  as.integer( (bil >= 4) | (alt > 102) )
}
