#' Phoenix Cardiovascular Score
#'
#' Generate the cardiovascular organ system dysfunction score as part of the
#' diagnostic Phoenix Sepsis Criteria.
#'
#' There were six systemic vasoactive medications considered when the Phoenix
#' criteria was developed: dobutamine, dopamine, epinephrine, milrinone,
#' norepinephrine, and vasopressin.
#'
#' During development, the values used for \code{mean_arterial_pressure} were taken preferentially
#' from arterial measurement, then cuff measures, and provided values before
#' approximating mean arterial pressure from blood pressure values via DBP + 1/3 (SBP - DBP),
#' where DBP is the diastolic blood pressure and SBP is the systolic blood
#' pressure.
#'
#' Direct calls can either provide a final \code{mean_arterial_pressure} value
#' or provide raw arterial/cuff MAP and SBP/DBP candidates with source times.
#' When raw candidates are supplied, \code{phoenix_cardiovascular()} applies the
#' same MAP freshness and source-priority logic used by
#' \code{\link{prepare_phoenix_data}}.
#'
#' @section Phoenix Cardiovascular Scoring:
#' The Phoenix Cardiovascular score ranges from 0 to 6 points; 0, 1, or 2 points
#' for each of systemic vasoactive medications, lactate, and MAP.
#'
#' \emph{Systemic Vasoactive Medications}
#' \tabular{ll}{
#'   0 medications \tab 0 points \cr
#'   1 medication  \tab 1 point  \cr
#'   2 or more medications \tab 2 points
#' }
#'
#'  \emph{Lactate}
#'  \tabular{ll}{
#'     [0, 5) \tab 0 points \cr
#'     [5, 11) \tab 1 point  \cr
#'     [11, Inf) \tab 2 points
#'  }
#'
#'  \emph{MAP}
#'  \tabular{lll}{
#'    Age in [0, 1) months  \tab \tab \cr
#'      \tab [31, Inf) mmHg \tab 0 points \cr
#'      \tab [17, 31)  mmHg \tab 1 point  \cr
#'      \tab [0, 17)   mmHg \tab 2 points \cr
#'    Age in [1, 12) months \tab \tab \cr
#'      \tab [39, Inf) mmHg \tab 0 points \cr
#'      \tab [25, 39)  mmHg \tab 1 point  \cr
#'      \tab [0, 25)   mmHg \tab 2 points \cr
#'    Age in [12, 24) months \tab\tab \cr
#'      \tab [44, Inf) mmHg \tab 0 points \cr
#'      \tab [31, 44)  mmHg \tab 1 point  \cr
#'      \tab [0, 31)   mmHg \tab 2 points \cr
#'    Age in [24, 60) months \tab\tab \cr
#'      \tab [45, Inf) mmHg \tab 0 points \cr
#'      \tab [32, 45)  mmHg \tab 1 point  \cr
#'      \tab [0, 32)   mmHg \tab 2 points \cr
#'    Age in [60, 144) months \tab\tab \cr
#'      \tab [49, Inf) mmHg \tab 0 points \cr
#'      \tab [36, 49)  mmHg \tab 1 point  \cr
#'      \tab [0, 36)   mmHg \tab 2 points \cr
#'    Age in [144, 216) months \tab\tab \cr
#'      \tab [52, Inf) mmHg \tab 0 points \cr
#'      \tab [38, 52)  mmHg \tab 1 point  \cr
#'      \tab [0, 38)   mmHg \tab 2 points \cr
#'  }
#'
#' @inheritParams phoenix8
#' @param mean_arterial_pressure_arterial,mean_arterial_pressure_cuff Optional
#'   direct arterial and cuff MAP candidates, in mmHg.
#' @param sbp_arterial,dbp_arterial,sbp_cuff,dbp_cuff Optional arterial and cuff
#'   systolic/diastolic blood pressure candidates, in mmHg, used to estimate MAP.
#' @param mean_arterial_pressure_arterial_eclock,mean_arterial_pressure_cuff_eclock
#'   Optional source encounter-clock values for direct arterial and cuff MAP
#'   candidates.
#' @param sbp_arterial_eclock,dbp_arterial_eclock,sbp_cuff_eclock,dbp_cuff_eclock
#'   Optional source encounter-clock values for SBP/DBP candidates.
#' @param eclock Optional row encounter-clock values. Required when raw MAP/BP
#'   candidates are supplied.
#' @param map.sdbp.delta The maximum allowed difference, in minutes, between the
#'   source times for systolic and diastolic blood pressures used to estimate
#'   MAP. The default, \code{Inf}, allows any SBP/DBP pair.
#' @param map.delta The MAP candidate freshness value, in minutes. Candidate MAP
#'   sources with effective staleness within \code{map.delta} are treated as
#'   having similar freshness, and the MAP source hierarchy breaks the tie. The
#'   default, \code{Inf}, preserves the original source-priority behavior.
#'
#' @return a integer vector with values 0, 1, 2, 3, 4, 5, or 6.
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
#' phoenix_cardiovascular(
#'    vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
#'    lactate = lactate,
#'    age = age,
#'    mean_arterial_pressure = dbp + (sbp - dbp)/3,
#'    data = sepsis
#' )
#'
#' # example data set to get all the possible scores
#' DF <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               lactate = c(NA, 3.2, 5, 7.8, 11, 14), # units of mmol/L
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
#'               mean_arterial_pressure = c(NA, 16:52)) # mmHg
#' DF[["card"]] <- phoenix_cardiovascular(vasos, lactate, age, mean_arterial_pressure, DF)
#' head(DF)
#'
#' # what if lactate is unknown for all records? - set the value either in the
#' # data object or the argument value to NA
#' DF2 <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
#'               mean_arterial_pressure = c(NA, 16:52)) # mmHg
#' DF2[["card"]] <- phoenix_cardiovascular(vasos, lactate = NA, age, mean_arterial_pressure, DF2)
#'
#' DF3 <-
#'   expand.grid(vasos = c(NA, 0:6),
#'               lactate = NA, # mmol/L
#'               age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
#'               mean_arterial_pressure = c(NA, 16:52)) # mmHg
#' DF3[["card"]] <- phoenix_cardiovascular(vasos, lactate, age, mean_arterial_pressure, DF3)
#'
#' identical(DF2[["card"]], DF3[["card"]])
#'
#' @export
phoenix_cardiovascular <-
  function(
    vasoactives = NA_integer_,
    lactate = NA_real_,
    age = NA_real_,
    mean_arterial_pressure = NA_real_,
    data = parent.frame(),
    mean_arterial_pressure_arterial = NULL,
    mean_arterial_pressure_arterial_eclock = NULL,
    sbp_arterial = NULL,
    sbp_arterial_eclock = NULL,
    dbp_arterial = NULL,
    dbp_arterial_eclock = NULL,
    mean_arterial_pressure_cuff = NULL,
    mean_arterial_pressure_cuff_eclock = NULL,
    sbp_cuff = NULL,
    sbp_cuff_eclock = NULL,
    dbp_cuff = NULL,
    dbp_cuff_eclock = NULL,
    eclock = NULL,
    map.sdbp.delta = Inf,
    map.delta = Inf,
    ...,
    map = NULL
  ) {
  if (is.environment(data) && identical(parent.env(data), emptyenv())) {
    stop(
      "`data` is an environment with parent `emptyenv()`, so expressions ",
      "cannot resolve base functions/operators. Use `baseenv()` as the parent, ",
      "for example `list2env(x, parent = baseenv())`."
    )
  }

  if (inherits(data, "data.frame") && nrow(data) == 0L) {
    return(integer(0L))
  }

  cl <- match.call(expand.dots = FALSE)
  has_map <- "map" %in% names(cl)
  has_mean_arterial_pressure <- "mean_arterial_pressure" %in% names(cl)

  if (has_map && has_mean_arterial_pressure) {
    stop("Use only one of `mean_arterial_pressure` or its deprecated alias `map`.", call. = FALSE)
  }

  if (has_map) {
    warning("`map` is deprecated; use `mean_arterial_pressure` instead.", call. = FALSE)
    mean_arterial_pressure_expr <- substitute(map)
  } else {
    mean_arterial_pressure_expr <- substitute(mean_arterial_pressure)
  }

  map_candidate_exprs <-
    list(
      mean_arterial_pressure_arterial =
        substitute(mean_arterial_pressure_arterial),
      mean_arterial_pressure_arterial_eclock =
        substitute(mean_arterial_pressure_arterial_eclock),
      sbp_arterial = substitute(sbp_arterial),
      sbp_arterial_eclock = substitute(sbp_arterial_eclock),
      dbp_arterial = substitute(dbp_arterial),
      dbp_arterial_eclock = substitute(dbp_arterial_eclock),
      mean_arterial_pressure_cuff =
        substitute(mean_arterial_pressure_cuff),
      mean_arterial_pressure_cuff_eclock =
        substitute(mean_arterial_pressure_cuff_eclock),
      sbp_cuff = substitute(sbp_cuff),
      sbp_cuff_eclock = substitute(sbp_cuff_eclock),
      dbp_cuff = substitute(dbp_cuff),
      dbp_cuff_eclock = substitute(dbp_cuff_eclock),
      eclock = substitute(eclock)
    )
  map_candidate_values <-
    lapply(
      map_candidate_exprs,
      eval,
      envir = data,
      enclos = parent.frame()
    )
  use_map_candidates <-
    any(
      !vapply(
        map_candidate_values[names(map_candidate_values) != "eclock"],
        is.null,
        logical(1L)
      )
    )

  if (use_map_candidates && has_mean_arterial_pressure) {
    stop(
      "Use either `mean_arterial_pressure` or raw MAP/BP candidates, not both.",
      call. = FALSE
    )
  }

  vas <- eval(expr = substitute(vasoactives), envir = data, enclos = parent.frame())
  lct <- eval(expr = substitute(lactate), envir = data, enclos = parent.frame())
  age <- eval(expr = substitute(age), envir = data, enclos = parent.frame())

  if (use_map_candidates) {
    if (is.null(map_candidate_values[["eclock"]])) {
      stop(
        "`eclock` is required when raw MAP/BP candidates are supplied.",
        call. = FALSE
      )
    }
    mean_arterial_pressure <-
      select_map_candidate(
        mean_arterial_pressure_arterial =
          map_candidate_values[["mean_arterial_pressure_arterial"]],
        mean_arterial_pressure_arterial_eclock =
          map_candidate_values[["mean_arterial_pressure_arterial_eclock"]],
        sbp_arterial = map_candidate_values[["sbp_arterial"]],
        sbp_arterial_eclock = map_candidate_values[["sbp_arterial_eclock"]],
        dbp_arterial = map_candidate_values[["dbp_arterial"]],
        dbp_arterial_eclock = map_candidate_values[["dbp_arterial_eclock"]],
        mean_arterial_pressure_cuff =
          map_candidate_values[["mean_arterial_pressure_cuff"]],
        mean_arterial_pressure_cuff_eclock =
          map_candidate_values[["mean_arterial_pressure_cuff_eclock"]],
        sbp_cuff = map_candidate_values[["sbp_cuff"]],
        sbp_cuff_eclock = map_candidate_values[["sbp_cuff_eclock"]],
        dbp_cuff = map_candidate_values[["dbp_cuff"]],
        dbp_cuff_eclock = map_candidate_values[["dbp_cuff_eclock"]],
        eclock = map_candidate_values[["eclock"]],
        map.sdbp.delta = map.sdbp.delta,
        map.delta = map.delta
      )[["MAP"]]
  } else {
    mean_arterial_pressure <-
      eval(
        expr = mean_arterial_pressure_expr,
        envir = data,
        enclos = parent.frame()
      )
  }

  lngths <- c(length(vas), length(lct), length(age), length(mean_arterial_pressure))
  n <- max(lngths)

  if (!all(lngths %in% c(1L, n))) {
    fmt <- paste("All inputs need to either have the same length or have length 1.",
                 "Length of vasoactives is %s;",
                 "Length of lactate is %s;",
                 "Length of age is %s;",
                 "Length of mean_arterial_pressure is %s.")
    msg <- do.call(sprintf, c(as.list(lngths), fmt = fmt))
    stop(msg)
  }

  # set "healthy" value for missing data
  vas <- as.integer(replace(vas, which(is.na(vas)), 0))
  lct <- replace(lct, which(is.na(lct)), 0)

  # If age is missing then the MAP cannot be assessed. Set age outside the
  # valid [0, 216) month interval and MAP to a high value so MAP contributes
  # zero points.
  missing_age_map <- which(is.na(age) | is.na(mean_arterial_pressure))
  age <- replace(age, missing_age_map, 222)
  mean_arterial_pressure <- replace(mean_arterial_pressure, missing_age_map, 100)

  # TeX: eq:card combines eq:vasos, eq:map, and eq:lactate.
  vas_score <- vasoactive_score(vas)
  lct_score <- lactate_score(lct)
  map_score <- map_score(mean_arterial_pressure, age)

  vas_score + lct_score + map_score
}

# non-exported methods that are used in
# phoenix_cardiovascular() and score_prepared_phoenix_data()
vasoactive_score <- function(x) {
  # TeX: eq:vasos.
  rtn <- as.integer(x > 1) + as.integer(x > 0)
  rtn[is.na(rtn)] <- 0L
  rtn
}

lactate_score <- function(x) {
  # TeX: eq:lactate.
  rtn <- as.integer(x >= 11) + as.integer(x >= 5)
  rtn[is.na(rtn)] <- 0L
  rtn
}

map_score <- function(map, age) {
  # TeX: eq:theta1, eq:theta2, and eq:map.
  rtn <- (
    (age >=   0 & age <    1) * ((map < 17) + (map < 31)) +
    (age >=   1 & age <   12) * ((map < 25) + (map < 39)) +
    (age >=  12 & age <   24) * ((map < 31) + (map < 44)) +
    (age >=  24 & age <   60) * ((map < 32) + (map < 45)) +
    (age >=  60 & age <  144) * ((map < 36) + (map < 49)) +
    (age >= 144 & age <  216) * ((map < 38) + (map < 52))
  )
  rtn[is.na(rtn)] <- 0L
  rtn
}

latest_source_eclock <- function(...) {
  x <- pmax(..., na.rm = TRUE)
  x[is.infinite(x)] <- NA_real_
  x
}

standardize_map_candidate <- function(x, n) {
  if (is.null(x)) {
    rep(NA_real_, n)
  } else if (length(x) == 1L) {
    rep(x, n)
  } else {
    x
  }
}

select_map_candidate <-
  function(
    mean_arterial_pressure_arterial = NULL,
    mean_arterial_pressure_arterial_eclock = NULL,
    sbp_arterial = NULL,
    sbp_arterial_eclock = NULL,
    dbp_arterial = NULL,
    dbp_arterial_eclock = NULL,
    mean_arterial_pressure_cuff = NULL,
    mean_arterial_pressure_cuff_eclock = NULL,
    sbp_cuff = NULL,
    sbp_cuff_eclock = NULL,
    dbp_cuff = NULL,
    dbp_cuff_eclock = NULL,
    eclock,
    map.sdbp.delta = Inf,
    map.delta = Inf
  ) {
    # TeX cross-reference:
    #   * candidate construction: eq:map-current-candidates
    #   * effective staleness:    eq:map-current-candidate-staleness
    #   * source priority:        eq:map-current-priority
    #
    # `map.sdbp.delta` implements \delta_{\mathrm{sdbp}}. It controls whether
    # SBP and DBP source times are close enough to estimate MAP. `map.delta`
    # implements \delta_{\mathrm{MAP}}. It controls how much newer a lower
    # priority source must be before it outranks the MAP source hierarchy.
    stopifnot(
      is.numeric(map.sdbp.delta),
      length(map.sdbp.delta) == 1,
      map.sdbp.delta >= 0
    )
    stopifnot(
      is.numeric(map.delta),
      length(map.delta) == 1,
      map.delta >= 0
    )

    lengths <-
      c(
        length(eclock),
        length(mean_arterial_pressure_arterial),
        length(mean_arterial_pressure_arterial_eclock),
        length(sbp_arterial),
        length(sbp_arterial_eclock),
        length(dbp_arterial),
        length(dbp_arterial_eclock),
        length(mean_arterial_pressure_cuff),
        length(mean_arterial_pressure_cuff_eclock),
        length(sbp_cuff),
        length(sbp_cuff_eclock),
        length(dbp_cuff),
        length(dbp_cuff_eclock)
      )
    lengths <- lengths[lengths > 0L]
    n <- max(lengths)
    stopifnot(all(lengths %in% c(1L, n)))

    MAPA <- standardize_map_candidate(mean_arterial_pressure_arterial, n)
    MAPA_eclock <-
      standardize_map_candidate(mean_arterial_pressure_arterial_eclock, n)
    SBPA <- standardize_map_candidate(sbp_arterial, n)
    SBPA_eclock <- standardize_map_candidate(sbp_arterial_eclock, n)
    DBPA <- standardize_map_candidate(dbp_arterial, n)
    DBPA_eclock <- standardize_map_candidate(dbp_arterial_eclock, n)
    MAPC <- standardize_map_candidate(mean_arterial_pressure_cuff, n)
    MAPC_eclock <-
      standardize_map_candidate(mean_arterial_pressure_cuff_eclock, n)
    SBPC <- standardize_map_candidate(sbp_cuff, n)
    SBPC_eclock <- standardize_map_candidate(sbp_cuff_eclock, n)
    DBPC <- standardize_map_candidate(dbp_cuff, n)
    DBPC_eclock <- standardize_map_candidate(dbp_cuff_eclock, n)
    eclock <- standardize_map_candidate(eclock, n)

    arterial_pair_ok <-
      !is.na(SBPA) &
      !is.na(DBPA) &
      abs(SBPA_eclock - DBPA_eclock) <= map.sdbp.delta
    cuff_pair_ok <-
      !is.na(SBPC) &
      !is.na(DBPC) &
      abs(SBPC_eclock - DBPC_eclock) <= map.sdbp.delta

    m1 <- MAPA
    m2 <- ifelse(arterial_pair_ok, mean_arterial_pressure(SBPA, DBPA), NA_real_)
    m3 <- MAPC
    m4 <- ifelse(cuff_pair_ok, mean_arterial_pressure(SBPC, DBPC), NA_real_)

    eta1 <- eclock - MAPA_eclock
    eta2 <- eclock - pmax(SBPA_eclock, DBPA_eclock)
    eta3 <- eclock - MAPC_eclock
    eta4 <- eclock - pmax(SBPC_eclock, DBPC_eclock)
    eta1[is.na(m1) | is.na(eta1)] <- Inf
    eta2[is.na(m2) | is.na(eta2)] <- Inf
    eta3[is.na(m3) | is.na(eta3)] <- Inf
    eta4[is.na(m4) | is.na(eta4)] <- Inf

    use1 <-
      eta1 < Inf &
      eta1 <= pmin(eta2, eta3, eta4) + map.delta
    use2 <-
      !use1 &
      eta2 < Inf &
      eta2 < eta1 + map.delta &
      eta2 <= pmin(eta3, eta4) + map.delta
    use3 <-
      !use1 &
      !use2 &
      eta3 < Inf &
      eta3 < pmin(eta1, eta2) + map.delta &
      eta3 <= eta4 + map.delta
    use4 <-
      !use1 &
      !use2 &
      !use3 &
      eta4 < Inf &
      eta4 < pmin(eta1, eta2, eta3) + map.delta

    map <- rep(NA_real_, n)
    map[use1] <- m1[use1]
    map[use2] <- m2[use2]
    map[use3] <- m3[use3]
    map[use4] <- m4[use4]

    map_eclock <- rep(NA_real_, n)
    map_eclock[use1] <- MAPA_eclock[use1]
    map_eclock[use2] <-
      latest_source_eclock(SBPA_eclock[use2], DBPA_eclock[use2])
    map_eclock[use3] <- MAPC_eclock[use3]
    map_eclock[use4] <-
      latest_source_eclock(SBPC_eclock[use4], DBPC_eclock[use4])

    map_source <- rep(NA_character_, n)
    map_source[use1] <- "MAPA"
    map_source[use2] <- "SBPA_DBPA"
    map_source[use3] <- "MAPC"
    map_source[use4] <- "SBPC_DBPC"

    list(
      MAP = map,
      MAP_eclock = map_eclock,
      MAP_source = map_source
    )
  }
