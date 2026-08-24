#' Phoenix Respiratory Score
#'
#' Apply the Phoenix Respiratory Scoring rubric to a data set.  The respiratory
#' score is part of the diagnostic Phoenix Sepsis criteria and the diagnostic
#' Phoenix 8 Sepsis criteria.
#'
#' \code{pf_ratio} is the ratio of partial pressure of oxygen in arterial blood
#' (PaO2) to the fraction of inspiratory oxygen concentration (FiO2).
#'
#' \code{sf_ratio} is a non-invasive surrogate for \code{pf_ratio} using pulse
#' oximetry (SpO2) instead of invasive PaO2.
#'
#' \code{pao2.spo2.delta} defines a source-time selector between P/F and S/F
#' ratios. P/F is used when it is the only available ratio or when PaO2 is no
#' older than SpO2 by more than \code{pao2.spo2.delta} minutes. Otherwise S/F is
#' used. With \code{pao2.spo2.delta = Inf}, P/F is selected whenever both ratios
#' are available. If \code{pao2.spo2.delta = NULL}, the historical Phoenix rule
#' scores either an abnormal P/F or abnormal S/F ratio.
#'
#' Important Note: when the Phoenix Sepsis criteria was developed there is
#' a requirement that SpO2 <= 97 in order for the \code{sf_ratio} to be valid.
#' That assumption is not checked in this code and it is left to the end user to
#' account for this when building the \code{sf_ratio} vector.
#'
#' \code{invasive_mechanical_ventilation} Invasive mechanical ventilation -
#' integer vector where 0 = not intubated and 1 = intubated. \code{imv} is
#' supported as a soft-deprecated alias.
#'
#' \code{other_respiratory_support} other respiratory support such as receiving oxygen,
#' high-flow, non-invasive positive pressure, or invasive mechanical ventilation.
#'
#' @section Phoenix Respiratory Scoring:
#' \tabular{llll}{
#' 0 points \tab 1 point \tab 2 points \tab 3 points \cr
#' selected oxygenation ratio above score threshold \tab
#' selected oxygenation ratio below 1-point threshold and any respiratory support \tab
#' selected oxygenation ratio below 2-point threshold and invasive mechanical ventilation \tab
#' selected oxygenation ratio below 3-point threshold and invasive mechanical ventilation \cr
#' }
#'
#' @inheritParams phoenix8
#' @param pf_ratio_eclock,sf_ratio_eclock,eclock Optional encounter-clock
#'   vectors used to compare P/F and S/F source times when
#'   \code{pao2.spo2.delta} is finite.
#' @param pao2.spo2.delta Optional maximum allowed difference, in minutes, by
#'   which the PaO2 source time for P/F ratio may be older than the SpO2 source
#'   time for S/F ratio before S/F is selected. A value of \code{Inf} uses P/F
#'   whenever both ratios are available. A value of \code{NULL} uses the
#'   historical rule where either abnormal P/F or abnormal S/F can contribute.
#'
#' @return a integer vector with values 0, 1, 2, or 3.
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
#'
#' @examples
#'
#' # Using the provided example data set:
#' # Expected units:
#' #   pf_ratio: PaO2 / FiO2
#' #     PaO2: mmHg
#' #     FiO2: decimal between 0.21 (room air) to 1.00 (pure oxygen)
#' #   sf_ratio: SpO2 / FiO2
#' #     SpO2: percentage, 0 to 100
#' #     FiO2: decimal between 0.21 (room air) to 1.00 (pure oxygen)
#' #   invasive_mechanical_ventilation: 1 for yes, 0 for no
#' #   other_respiratory_support: 1 for yes, 0 for no
#'
#' phoenix_respiratory(
#'   pf_ratio = pao2 / fio2,
#'   sf_ratio = spo2 / fio2,
#'   invasive_mechanical_ventilation = vent,
#'   other_respiratory_support = as.integer(fio2 > 0.21),
#'   data = sepsis
#' )
#'
#' # A set of values that will get all possible respiratory scores:
#' DF <- expand.grid(
#'   pfr = c(NA, 500, 400, 350, 200, 187, 100, 56),
#'   sfr = c(NA, 300, 292, 254, 220, 177, 148, 76),
#'   pfr_time = 120,
#'   sfr_time = 90,
#'   score_time = 120,
#'   vent = c(NA, 0, 1),
#'   o2  = c(NA, 0, 1)
#' )
#'
#' phoenix_respiratory(
#'   pf_ratio = pfr,
#'   sf_ratio = sfr,
#'   pf_ratio_eclock = pfr_time,
#'   sf_ratio_eclock = sfr_time,
#'   eclock = score_time,
#'   pao2.spo2.delta = Inf,
#'   invasive_mechanical_ventilation = vent,
#'   other_respiratory_support = o2,
#'   data = DF
#' )
#'
#'
#' @export
phoenix_respiratory <-
  function(
    pf_ratio = NA_real_,
    sf_ratio = NA_real_,
    invasive_mechanical_ventilation = NA_integer_,
    other_respiratory_support = NA_integer_,
    data = parent.frame(),
    pf_ratio_eclock = NULL,
    sf_ratio_eclock = NULL,
    eclock = NULL,
    pao2.spo2.delta = NULL,
    ...,
    imv = NULL
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
  has_imv <- "imv" %in% names(cl)
  has_invasive_mechanical_ventilation <- "invasive_mechanical_ventilation" %in% names(cl)

  if (has_imv && has_invasive_mechanical_ventilation) {
    stop("Use only one of `invasive_mechanical_ventilation` or its deprecated alias `imv`.", call. = FALSE)
  }

  if (has_imv) {
    warning("`imv` is deprecated; use `invasive_mechanical_ventilation` instead.", call. = FALSE)
    invasive_mechanical_ventilation_expr <- substitute(imv)
  } else {
    invasive_mechanical_ventilation_expr <- substitute(invasive_mechanical_ventilation)
  }

  pfr <- eval(expr = substitute(pf_ratio), envir = data, enclos = parent.frame())
  sfr <- eval(expr = substitute(sf_ratio), envir = data, enclos = parent.frame())
  pfr_eclock <- eval(expr = substitute(pf_ratio_eclock), envir = data, enclos = parent.frame())
  sfr_eclock <- eval(expr = substitute(sf_ratio_eclock), envir = data, enclos = parent.frame())
  score_eclock <- eval(expr = substitute(eclock), envir = data, enclos = parent.frame())
  invasive_mechanical_ventilation <- eval(expr = invasive_mechanical_ventilation_expr, envir = data, enclos = parent.frame())
  ors <- eval(expr = substitute(other_respiratory_support), envir = data, enclos = parent.frame())

  selector_has_times <-
    !is.null(pfr_eclock) && !is.null(sfr_eclock) && !is.null(score_eclock)

  if (!is.null(pao2.spo2.delta)) {
    if (is.finite(pao2.spo2.delta) && !selector_has_times) {
      stop(
        "`pf_ratio_eclock`, `sf_ratio_eclock`, and `eclock` are required ",
        "when `pao2.spo2.delta` is finite.",
        call. = FALSE
      )
    }
    stopifnot(
      is.numeric(pao2.spo2.delta),
      length(pao2.spo2.delta) == 1,
      pao2.spo2.delta >= 0
    )
  }

  length_map <-
    c(
      pf_ratio = length(pfr),
      sf_ratio = length(sfr),
      invasive_mechanical_ventilation = length(invasive_mechanical_ventilation),
      other_respiratory_support = length(ors)
    )
  if (!is.null(pao2.spo2.delta) && selector_has_times) {
    length_map <-
      c(
        length_map,
        pf_ratio_eclock = length(pfr_eclock),
        sf_ratio_eclock = length(sfr_eclock),
        eclock = length(score_eclock)
      )
  }
  n <- max(length_map)

  if (!all(length_map %in% c(1L, n))) {
    msg <-
      paste(
        "All inputs need to either have the same length or have length 1.",
        paste0("Length of ", names(length_map), " is ", length_map, collapse = "; "),
        sep = " "
      )
    msg <- paste0(msg, ".")
    stop(msg)
  }

  pfr_missing <- is.na(pfr)
  sfr_missing <- is.na(sfr)

  # set "healthy" value for missing data
  pfr <- replace(pfr, which(is.na(pfr)), 500)
  sfr <- replace(sfr, which(is.na(sfr)), 500)
  invasive_mechanical_ventilation <- as.integer(replace(invasive_mechanical_ventilation, which(is.na(invasive_mechanical_ventilation)), 0))
  stopifnot(all(invasive_mechanical_ventilation %in% c(0L, 1L)))
  ors <- as.integer(replace(ors, which(is.na(ors)), 0))
  stopifnot(all(ors %in% c(0L, 1L)))
  ors <- pmax(invasive_mechanical_ventilation, ors)

  if (is.null(pao2.spo2.delta)) {
    # TeX: published/default rule in eq:resp and eq:resp-conditions.
    b1 <- (pfr < 400) | (sfr < 292)
    b2 <- (pfr < 200) | (sfr < 220)
    b3 <- (pfr < 100) | (sfr < 148)
  } else {
    # TeX: eq:resp-selector, eq:resp-conditions-selector, and
    # eq:pfr-sfr-selector. `use_pfr` is Q(t; m_resp, delta_paO2,SpO2).
    if (selector_has_times) {
      pfr_delta <- score_eclock - pfr_eclock
      sfr_delta <- score_eclock - sfr_eclock
      pfr_delta <- replace(pfr_delta, which(!is.finite(pfr_delta)), Inf)
      sfr_delta <- replace(sfr_delta, which(!is.finite(sfr_delta)), Inf)

      use_pfr <-
        (!pfr_missing & sfr_missing) |
        (
          !pfr_missing & !sfr_missing &
          pfr_delta <= sfr_delta + pao2.spo2.delta
        )
    } else {
      use_pfr <- !pfr_missing
    }

    b1 <- (use_pfr & pfr < 400) | (!use_pfr & sfr < 292)
    b2 <- (use_pfr & pfr < 200) | (!use_pfr & sfr < 220)
    b3 <- (use_pfr & pfr < 100) | (!use_pfr & sfr < 148)
  }

  # TeX: eq:resp and eq:resp-conditions.
  as.integer(invasive_mechanical_ventilation * (b3 + b2) + ors * b1)
}
