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
#' DF <- expand.grid(
#'         sbp = 40:130, # expected units of mmHg
#'         dbp = 20:100  # expected units of mmHg
#'       )
#'
#' DF[["mean_arterial_pressure"]] <- with(DF, mean_arterial_pressure(sbp, dbp))
#' with(DF, plot(sbp, dbp, col = mean_arterial_pressure))
#' DF[["mean_arterial_pressure"]][DF[["sbp"]] < DF[["dbp"]]] <- NA
#'
#' z <- matrix(DF[["mean_arterial_pressure"]], nrow = length(unique(DF[["sbp"]])), ncol = length(unique(DF[["dbp"]])))
#'
#' image(
#'   x = unique(DF[["sbp"]]),
#'   y = unique(DF[["dbp"]]),
#'   z = z,
#'   col = hcl.colors(100, palette = "RdBu"),
#'   xlab = "SBP (mmHg)",
#'   ylab = "DBP (mmHg)",
#'   main = "Estimated Mean Arterial Pressure"
#' )
#' contour(x = unique(DF[["sbp"]]), y = unique(DF[["dbp"]]), z = z, add = TRUE)
#'
#' @export
mean_arterial_pressure <- function(sbp, dbp) {
  ((2/3) * dbp) + (sbp / 3)
}

#' @rdname mean_arterial_pressure
#' @export
map <- function(sbp, dbp) {
  warning("`map()` is deprecated; use `mean_arterial_pressure()` instead.", call. = FALSE)
  mean_arterial_pressure(sbp, dbp)
}
