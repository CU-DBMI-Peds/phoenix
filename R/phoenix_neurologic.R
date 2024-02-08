#' Phoenix Sepsis Neurological Score
#'
#' Assement of neurologic disfunction based on Glasgow Coma Scale (GCS) and
#' pupil reactiveity.
#'
#' Scoring:
#' \tabular{ll}{
#' Bilaterally fixed pupil \tab 2 points \cr
#' Glasgow Coma Score (total) less or equal 10 \tab 1 point \cr
#' Reactive pupils and GCS > 10 \tab 0 point
#' }
#' Missing value will be mapped to a value of 0 as was done when developing the
#' Phoenix criteria.  Note that this is done on a input by input basis.  That
#' is, if pupil reactivity is missing but GCS (total) = 9, then the score is one
#' point.
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
#' abnormal flexion to pain, \item widthdrawal from pain, \item localized pain,
#' \item obeys commands}
#'
#' @param data a \code{data.frame} or \code{list}
#' @param fixed_pupils name, unquoted, of the column in \code{data} denoting
#' pupil reactivity.  Expect values of 0, 1, or \code{NA} with 1 indicating
#' bilaterally fixed pupils. If omitted, then \code{fixed_pupils} is used as a
#' default.
#' @param gcs name, unquoted, of the column in \code{data} denoting the gcs
#' total score.  Expected values are integers between 3 and 15 inclusively, with
#' permissable \code{NA} values.  If omitted then \code{gcs} is used as a
#' default.
#' @param ... pass through
#'
#' @return an integer vector
#'
#' @examples
#' DF <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
#' DF$target <- 0
#' DF$target[DF$gcs <= 10] <- 1
#' DF$target[DF$pupils == 1] <- 2
#' DF$current <- phoenix_sepsis_neurologic(DF, pupils, gcs)
#' stopifnot(identical(DF$target, DF$current))
#' DF
#' @export
phoenix_sepsis_neurologic <- function(data, fixed_pupils = fixed_pupils, gcs = gcs, ...) {
  fixed_pupils <- deparse(substitute(fixed_pupils))
  gcs <- deparse(substitute(gcs))

  if (!(fixed_pupils %in% names(data))) {
    stop(sprintf("%s is not in names(%s)", fixed_pupils, deparse(substitute(data))))
  }

  if (!(gcs %in% names(data))) {
    stop(sprintf("%s is not in names(%s)", gcs, deparse(substitute(data))))
  }

  if (!is.numeric(data[[fixed_pupils]])) {
    stop(sprintf("is.numeric(%s[[%s]]) is not true", deparse(substitute(data)), fixed_pupils))
  }

  if (!is.numeric(data[[gcs]])) {
    stop(sprintf("is.numeric(%s[[%s]]) is not true", deparse(substitute(data)), gcs))
  }

  fixed_pupils <- as.integer(data[[fixed_pupils]])
  fixed_pupils[is.na(fixed_pupils)] <- 0L
  stopifnot(all(fixed_pupils %in% c(0L, 1L)))

  gcs <- as.integer(data[[gcs]])
  gcs[is.na(gcs)] <- 15L
  stopifnot(all(gcs %in% as.integer(3:15)))

  pmin(fixed_pupils * 2L + as.integer(gcs <= 10), 2)
}
