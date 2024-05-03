#' Mean Arterial Pressure
#'
#' Estimate mean arterial pressure from systolic and diastolic blood pressures.
#'
#' Mean Arterial Pressure is approximated by:
#' (DBP + (SBP - DBP) / 3) = (2/3) DBP + (1/3) SBP
#'
#' @param sbp numeric vector, systolic blood pressure measured in mmHg
#' @param dbp numeric vector, diastolic blood pressure measured in mmHg
#'
#' @return a numeric vector
#'
#' @examples
#'
#' DF <- expand.grid(sbp = 40:130, dbp = 20:100)
#' DF$map <- with(DF, map(sbp, dbp))
#' with(DF, plot(sbp, dbp, col = map))
#' DF$map[DF$sbp < DF$dbp] <- NA
#'
#' z <- matrix(DF$map, nrow = length(unique(DF$sbp)), ncol = length(unique(DF$dbp)))
#'
#' image(
#'   x = unique(DF$sbp),
#'   y = unique(DF$dbp),
#'   z = z,
#'   col = hcl.colors(100, palette = "RdBu"),
#'   xlab = "SBP (mmHg)",
#'   ylab = "DBP (mmHg)",
#'   main = "Estimated Mean Arterial Pressue"
#' )
#' contour(x = unique(DF$sbp), y = unique(DF$dbp), z = z, add = TRUE)
#'
#' @export
map <- function(sbp, dbp) {
  ((2/3) * dbp) + (sbp / 3)
}
