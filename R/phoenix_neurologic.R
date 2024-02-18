#' Phoenix Sepsis Neurological Score
#'
#' Assement of neurologic disfunction based on Glasgow Coma Scale (GCS) and
#' pupil reactiveity. This score is part of the diagnostic Phoenix Sepsis
#' criteria and Phoenix 8 Sepsis criteria.
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
#' @inheritParams phoenix8
#'
#' @return an integer vector with values 0, 1, or 2.
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
#'     Spesis criteria based on the four organ systems noted above and
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
#' DF <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
#' DF$target <- 0
#' DF$target[DF$gcs <= 10] <- 1
#' DF$target[DF$pupils == 1] <- 2
#' DF$current <- phoenix_neurologic(gcs, pupils, DF)
#' stopifnot(identical(DF$target, DF$current))
#' DF
#' @export
phoenix_neurologic <- function(gcs, fixed_pupils, data = parent.frame(), ...) {
  gcs <- eval(expr = substitute(gcs), envir = data)
  fpl <- eval(expr = substitute(fixed_pupils), envir = data)

  fpl <- as.integer(fpl)
  fpl[is.na(fpl)] <- 0L
  stopifnot(all(fpl %in% c(0L, 1L)))

  gcs <- as.integer(gcs)
  gcs[is.na(gcs)] <- 15L
  stopifnot(all(gcs %in% as.integer(3:15)))

  pmin(fpl * 2L + as.integer(gcs <= 10), 2)
}
