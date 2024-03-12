#' Phoenix Sepsis Neurological Score
#'
#' Assessment of neurologic dysfunction based on Glasgow Coma Scale (GCS) and
#' pupil reactivity. This score is part of the diagnostic Phoenix Sepsis
#' criteria and Phoenix 8 Sepsis criteria.
#'
#' Missing values will map to a value of 0 as was done when developing the
#' Phoenix criteria.  Note that this is done on a input by input basis.  That
#' is, if pupil reactivity is missing but GCS (total) is 9, then the neurologic
#' dysfunction score is 1.
#'
#' GCS total is the sum of a score based on eyes, motor control, and verbal
#' responsiveness.
#'
#' Eye response:
#' \enumerate{ \item no eye opening, \item eye opening to pain, \item eye
#' opening to sound, \item eyes open spontaneously.}
#'
#' Verbal response:
#' \enumerate{ \item no verbal response, \item incomprehensible sounds, \item
#' inappropriate words, \item confused, \item orientated }
#'
#' Motor response:
#' \enumerate{ \item no motor response, \item abnormal extension to pain, \item
#' abnormal flexion to pain, \item withdrawal from pain, \item localized pain,
#' \item obeys commands}
#'
#' @section Phoenix Neurological Scoring:
#' \tabular{ll}{
#' Bilaterally fixed pupil \tab 2 points \cr
#' Glasgow Coma Score (total) less or equal 10 \tab 1 point \cr
#' Reactive pupils and GCS > 10 \tab 0 point
#' }
#'
#' @inheritParams phoenix8
#'
#' @return an integer vector with values 0, 1, or 2.
#' As with all Phoenix organ dysfunction scores, missing input values map to
#' scores of zero.
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
#' # using the example sepsis data set
#' phoenix_neurologic(
#'   gcs = gcs_total,
#'   fixed_pupils = as.integer(pupil == "both-fixed"),
#'   data = sepsis
#' )
#'
#' # build an example data set with all possible neurologic scores
#' DF <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
#' DF$target <- 0L
#' DF$target[DF$gcs <= 10] <- 1L
#' DF$target[DF$pupils == 1] <- 2L
#' DF$current <- phoenix_neurologic(gcs, pupils, DF)
#' stopifnot(identical(DF$target, DF$current))
#' DF
#'
#' @export
phoenix_neurologic <- function(gcs = NA_integer_, fixed_pupils = NA_real_, data = parent.frame(), ...) {

  gcs <- eval(expr = substitute(gcs), envir = data)
  fpl <- eval(expr = substitute(fixed_pupils), envir = data)

  lngths <- c(length(gcs), length(fpl))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of gcs is %s;",
                 "Length of fixed_pupils is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  fpl <- as.integer(fpl)
  fpl[is.na(fpl)] <- 0L
  stopifnot(all(fpl %in% c(0L, 1L)))

  gcs <- as.integer(gcs)
  gcs[is.na(gcs)] <- 15L
  stopifnot(all(gcs %in% as.integer(3:15)))

  pmin(fpl * 2L + as.integer(gcs <= 10), 2L)
}
