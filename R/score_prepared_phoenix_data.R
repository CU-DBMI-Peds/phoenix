#' Score Prepared Phoenix Data
#'
#' Apply the published and experimental aggregation schemes to prepared Phoenix
#' data.
#'
#' Organ dysfunction summary scores (ODSS) are computed for all encounters regardless of
#' suspected infection status. Phoenix Sepsis Scores (PSS) are then computed as
#' the product of the window-level suspected infection indicator and ODSS. Thus,
#' encounters without suspected infection can have positive ODSS columns and zero
#' PSS columns.
#'
#' Aggregation schemes:
#' \describe{
#'   \item{jama2024}{Published, time-aligned Phoenix aggregation.}
#'   \item{olm}{Organ-level maxima.}
#'   \item{ccd}{Organ-level maxima with cardiovascular component decoupling.}
#'   \item{fcd}{Full component decoupling.}
#' }
#'
#'
#'
#'
#'
#' @param x an object returned from \code{\link{prepare_phoenix_data}}
#' @param T0 The start of observation window for assessing if the patient has
#'   sepsis or septic shock.
#' @param T1 The end of the observation window for assessing if the patient has
#'   sepsis or septic shock.
#' @param sigma numeric (integer) value, sepsis = PSS >= sigma.
#' @param kappa numeric (integer) value, minimum cardiovascular score required
#' to flag septic shock.
#' @param aggregation The aggregation approach to apply to the data.  Default is
#'   "jama2024" the scoring method used to develop the Phoenix Sepsis Criteria.
#'   See Details.
#' @inheritParams phoenix_respiratory
#' @param verbose when \code{TRUE}, display progress messages
#'
#' @return A scored data frame with one row per encounter identifier. The output
#'   always includes \code{suspected_infection}. For the selected aggregation it
#'   includes four-organ ODSS, four-organ PSS, sepsis and septic shock indicators,
#'   eight-organ ODSS, and eight-organ PSS. For example,
#'   \code{aggregation = "jama2024"} returns
#'   \code{odss_4},
#'   \code{pss_4}, \code{sepsis},
#'   \code{septic_shock},
#'   \code{odss_8}, and
#'   \code{pss_8}.
#'
#' @seealso \code{\link{prepare_inputs_range}},
#' \code{\link{prepare_inputs_discrete}}
#'
#' @references See reference details in \code{\link{phoenix-package}} or by calling
#' \code{citation('phoenix')}.
#'
#' @export
score_prepared_phoenix_data <- function(x, T0 = 0, T1 = 1440, sigma = 2, kappa = 1, aggregation = c("jama2024", "olm", "ccd", "fcd"), pao2.spo2.delta = NULL, verbose = getOption("phoenix_verbose", interactive())) {
  # This function scores the wide longitudinal data set returned by
  # `prepare_phoenix_data()`.  It returns one row per encounter, not one row per
  # encounter/time point.
  #
  # The important distinction is:
  #   ODSS = organ dysfunction summary score, computed from physiology.
  #   PSS  = Phoenix Sepsis Score, computed as suspected infection * ODSS.
  #
  # This means a patient without suspected infection can still have organ
  # dysfunction.  The ODSS columns preserve that information.  The PSS and
  # sepsis/septic-shock indicators are zero unless suspected infection is
  # present in the scoring window.

  stopifnot(inherits(x, "prepared_phoenix_data"))
  stopifnot(length(sigma) == 1, length(kappa) == 1, is.numeric(sigma), is.numeric(kappa))
  stopifnot(
    is.null(pao2.spo2.delta) ||
      (
        is.numeric(pao2.spo2.delta) &&
        length(pao2.spo2.delta) == 1 &&
        pao2.spo2.delta >= 0
      )
  )
  aggregation <- match.arg(aggregation, several.ok = FALSE)

  if (verbose) message("Scoring prepared_phoenix_data...")
  if (verbose) message("  identifying suspected infections...")
  # Build a row-level suspected infection indicator.  A row is positive only
  # when both required components are present at that time after preparation:
  # antimicrobials and an anti-infectious test.
  # TeX: eq:suspected-infection.
  si <-
    phxdft_set(
      x = phxdft_select(x, c(attr(x, "id.vars"), attr(x, "eclock"))),
      j = "suspected_infection",
      value =
        as.integer(
          !is.na(x[["ANTIMICROBIALS"]])     &
          !is.na(x[["ANTIINFECTIOUSTESTS"]]) &
          (x[["ANTIMICROBIALS"]] == 1)       &
          (x[["ANTIINFECTIOUSTESTS"]] == 1)
        )
    )

  # Collapse row-level suspected infection to one 0/1 value per encounter for
  # the requested time window [T0, T1).  Any positive row in the window makes the
  # encounter positive for suspected infection.
  si <-
    phxdft_subset(
      x = si,
      i = which((si[[attr(x, "eclock")]] >= T0) & (si[[attr(x, "eclock")]] < T1))
    )

  si <-
    phxdft_aggregate(
      data = si,
      y    = "suspected_infection",
      by   = attr(x, "id.vars"),
      FUN  = max
    )

  if (verbose) message("  identifying records to score...")
  # Organ dysfunction summary scores are computed for all records in [T0, T1).
  # Suspected infection gates the Phoenix Sepsis Score, not the ODSS.
  # TeX: eq:odss and eq:pss.
  score_this <-
    phxdft_subset(x, i = which((x[[attr(x, "eclock")]] >= T0) & (x[[attr(x, "eclock")]] < T1)))

  if (verbose) message("  applying scoring...")
  # Each aggregation helper below returns ODSS-type columns only.  The common
  # PSS/sepsis/septic-shock logic is applied after the switch so the suspected
  # infection gating is identical across aggregation schemes.
  ods <- phxdft_unique(phxdft_select(score_this, attr(x, "id.vars")))
  if (nrow(score_this) > 0L) {
    ods <-
      switch(
        aggregation,
        jama2024 = jama2024(x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, pao2.spo2.delta = pao2.spo2.delta, verbose = verbose),
        olm     = olm(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, pao2.spo2.delta = pao2.spo2.delta, verbose = verbose),
        ccd     = ccd(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, pao2.spo2.delta = pao2.spo2.delta, verbose = verbose),
        fcd     = fcd(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose)
      )
  }

  if (verbose) message("  building output...")
  # Start from all encounters in the prepared data, not only encounters with
  # rows inside [T0, T1).  Encounters with no rows in the scoring window are kept
  # and receive zero scores below.
  iddf <- phxdft_unique(phxdft_select(x, attr(x, "id.vars")))
  rtn <- phxdft_left_join(iddf, si, attr(x, "id.vars"))
  rtn <- phxdft_left_join(rtn, ods, attr(x, "id.vars"))

  # No suspected-infection rows in the window means suspected infection is 0.
  # This also handles encounters with no rows at all in the scoring window.
  suspected_infection <- rtn[["suspected_infection"]]
  suspected_infection[is.na(suspected_infection)] <- 0L
  rtn <- phxdft_set(rtn, j = "suspected_infection", value = suspected_infection)

  # The aggregation helpers use different column prefixes, but the final gating
  # logic is the same.  This lookup tells the shared code which columns belong to
  # the selected aggregation.
  score_columns <-
    switch(
      aggregation,
      jama2024 = list(
        ods4 = "odss_4",
        shock_ods = "odss_4_septic_shock",
        pss4 = "pss_4",
        sepsis = "sepsis",
        shock = "septic_shock",
        ods8 = "odss_8",
        pss8 = "pss_8"
      ),
      olm = list(
        ods4 = "odss_4_olm",
        shock_ods = "odss_4_olm_septic_shock",
        pss4 = "pss_4_olm",
        sepsis = "sepsis_olm",
        shock = "septic_shock_olm",
        ods8 = "odss_8_olm",
        pss8 = "pss_8_olm"
      ),
      ccd = list(
        ods4 = "odss_4_ccd",
        shock_ods = "odss_4_ccd_septic_shock",
        pss4 = "pss_4_ccd",
        sepsis = "sepsis_ccd",
        shock = "septic_shock_ccd",
        ods8 = "odss_8_ccd",
        pss8 = "pss_8_ccd"
      ),
      fcd = list(
        ods4 = "odss_4_fcd",
        shock_ods = "odss_4_fcd_septic_shock",
        pss4 = "pss_4_fcd",
        sepsis = "sepsis_fcd",
        shock = "septic_shock_fcd",
        ods8 = "odss_8_fcd",
        pss8 = "pss_8_fcd"
      )
    )
  for (col in c(score_columns[["ods4"]], score_columns[["shock_ods"]], score_columns[["ods8"]])) {
    # Missing ODSS values mean there was no available dysfunction evidence in
    # the requested window.  By definition, that contributes zero points.
    if (!col %in% names(rtn)) {
      rtn <- phxdft_set(rtn, j = col, value = 0L)
    } else {
      values <- rtn[[col]]
      values[is.na(values)] <- 0L
      rtn <- phxdft_set(rtn, j = col, value = values)
    }
  }
  # TeX: PSS is max_T SI times ODSS; sepsis and septic shock indicators are
  # thresholded PSS quantities.
  #
  # `shock_ods` is a temporary ODSS-like value that already includes the
  # cardiovascular dysfunction requirement.  After it is gated by suspected
  # infection and thresholded, the temporary column is removed from the returned
  # data frame.
  pss4 <- rtn[["suspected_infection"]] * rtn[[score_columns[["ods4"]]]]
  pss8 <- rtn[["suspected_infection"]] * rtn[[score_columns[["ods8"]]]]
  septic_shock_score <- rtn[["suspected_infection"]] * rtn[[score_columns[["shock_ods"]]]]
  rtn <- phxdft_set(rtn, j = score_columns[["pss4"]], value = pss4)
  rtn <- phxdft_set(rtn, j = score_columns[["sepsis"]], value = as.integer(pss4 >= sigma))
  rtn <- phxdft_set(rtn, j = score_columns[["shock"]], value = as.integer(septic_shock_score >= sigma))
  rtn <- phxdft_set(rtn, j = score_columns[["pss8"]], value = pss8)
  rtn <- phxdft_set(rtn, j = score_columns[["shock_ods"]], value = NULL)
  rtn <-
    phxdft_select(
      rtn,
      c(
        attr(x, "id.vars"),
        "suspected_infection",
        score_columns[["ods4"]],
        score_columns[["pss4"]],
        score_columns[["sepsis"]],
        score_columns[["shock"]],
        score_columns[["ods8"]],
        score_columns[["pss8"]]
      )
    )

  attr(rtn, "T0") <- T0
  attr(rtn, "T1") <- T1
  attr(rtn, "aggregation") <- aggregation
  class(rtn) <- c("scored_prepared_phoenix_data", class(rtn))

  if (verbose) message("Scoring complete!")
  rtn
}

jama2024 <- function(x, id.vars, eclock, sigma, kappa, pao2.spo2.delta, verbose) {
  # The scoring method used when Phoenix was developed and published in JAMA
  # (2024).
  #
  # At each time point, compute the organ scores first.  Then sum the organ
  # scores at that same time point.  The four-organ ODSS is the largest
  # time-aligned sum observed in the scoring window:
  #
  #   max_t(resp_t + card_t + neuro_t + coag_t)
  #
  # The eight-organ ODSS uses the same time-aligned rule but includes endocrine,
  # immunologic, hepatic, and renal scores as well.  This method does not let
  # organ systems peak at different times and then add those peaks together.
  #
  # TeX: eq:odss, eq:pss, eq:omega4, eq:omega8, eq:sepsis, and eq:septicshock in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  if (verbose) message("    building organ system scores...")
  # Compute all organ system scores at every time point in the scoring window.
  # The `phoenix_*()` functions return row-level organ scores.  They do not apply
  # suspected-infection gating.
  # TeX: eq:pfr-sfr-selector selects between row-level PFR and SFR.
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
      pf_ratio_eclock = x[["PFR_eclock"]],
      sf_ratio_eclock = x[["SFR_eclock"]],
      eclock = x[[eclock]],
      pao2.spo2.delta = pao2.spo2.delta,
      invasive_mechanical_ventilation = x[["IMV"]],
      other_respiratory_support = x[["ORS"]]
    )

  cardscore <-
    phoenix_cardiovascular(
      vasoactives = x[["DOBUTAMINE"]] + x[["DOPAMINE"]] + x[["EPINEPHRINE"]] + x[["MILRINONE"]] + x[["NOREPINEPHRINE"]] + x[["VASOPRESSIN"]],
      lactate = x[["LACTATE"]],
      mean_arterial_pressure = x[["MAP"]],
      age = x[["AGE"]],
    )

  coagscore <-
    phoenix_coagulation(
      platelets = x[["PLATELETS"]],
      inr = x[["INR"]],
      d_dimer = x[["DDIMER"]],
      fibrinogen = x[["FIBRINOGEN"]]
    )

  neuroscore <-
    phoenix_neurologic(
      gcs = x[["GCS"]],
      fixed_pupils = x[["FIXEDPUPILS"]]
    )

  endoscore <-
    phoenix_endocrine(
      glucose = x[["GLUCOSE"]]
    )

  immunscore <-
    phoenix_immunologic(
      anc = x[["ANC"]],
      alc = x[["ALC"]]
    )

  renalscore <-
    phoenix_renal(
      creatinine = x[["CREATININE"]],
      age = x[["AGE"]]
    )

  hepaticscore <-
    phoenix_hepatic(
      bilirubin = x[["BILIRUBIN"]],
      alt = x[["ALT"]]
    )

  oss <- phxdft_select(x, c(id.vars, eclock))
  oss <- phxdft_set(oss, j = "respscore", value = respscore)
  oss <- phxdft_set(oss, j = "cardscore", value = cardscore)
  oss <- phxdft_set(oss, j = "neuroscore", value = neuroscore)
  oss <- phxdft_set(oss, j = "coagscore", value = coagscore)
  oss <- phxdft_set(oss, j = "endoscore", value = endoscore)
  oss <- phxdft_set(oss, j = "immunscore", value = immunscore)
  oss <- phxdft_set(oss, j = "hepaticscore", value = hepaticscore)
  oss <- phxdft_set(oss, j = "renalscore", value = renalscore)

  oss <-
    phxdft_set(
      x = oss,
      j = "odss_4",
      # TeX: eq:odss with eq:omega4.
      value = respscore + cardscore + neuroscore + coagscore
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "odss_4_septic_shock",
      # TeX: eq:septicshock.
      value = as.integer(cardscore >= kappa) * oss[["odss_4"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "odss_8",
      # TeX: eq:odss with eq:omega8.
      value = respscore + cardscore + neuroscore + coagscore +
              immunscore + endoscore + renalscore + hepaticscore
    )

  if (verbose) message("    aggregating....")
  # Collapse from many time points per encounter to one row per encounter by
  # taking the maximum time-aligned ODSS.
  oss <-
    #aggregate(
    #  x = phxdft_select(oss, c("odss_4", "odss_4_septic_shock", "odss_8")),
    #  by = phxdft_select(oss, id.vars),
    #  FUN = max
    #)
    phxdft_aggregate(
      data = oss,
      y    = c("odss_4", "odss_4_septic_shock", "odss_8"),
      by   = id.vars,
      FUN  = max
    )

  oss

}

olm <- function(x, id.vars, eclock, sigma, kappa, pao2.spo2.delta, verbose) {
  # Exploratory Aggregation Schema 1:
  #   Organ-Level Maxima (OLM)
  #
  # OLM scores each organ at each time point, then takes the maximum score for
  # each organ separately.  The ODSS is the sum of those organ-level maxima:
  #
  #   max_t(resp_t) + max_t(card_t) + max_t(neuro_t) + max_t(coag_t)
  #
  # This can be larger than `jama2024` because respiratory dysfunction could
  # peak at one time, cardiovascular dysfunction at another time, and both peaks
  # would be counted.
  #
  # TeX: eq:odss-olm, eq:pss-olm, eq:sepsis-olm, and eq:septicshock-olm in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  if (verbose) message("    building organ system scores...")
  # Compute row-level organ scores before aggregating.  The per-organ maximum is
  # computed after all rows in the scoring window have been scored.
  # TeX: eq:pfr-sfr-selector selects between row-level PFR and SFR.
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
      pf_ratio_eclock = x[["PFR_eclock"]],
      sf_ratio_eclock = x[["SFR_eclock"]],
      eclock = x[[eclock]],
      pao2.spo2.delta = pao2.spo2.delta,
      invasive_mechanical_ventilation = x[["IMV"]],
      other_respiratory_support = x[["ORS"]]
    )

  cardscore <-
    phoenix_cardiovascular(
      vasoactives = x[["DOBUTAMINE"]] + x[["DOPAMINE"]] + x[["EPINEPHRINE"]] + x[["MILRINONE"]] + x[["NOREPINEPHRINE"]] + x[["VASOPRESSIN"]],
      lactate = x[["LACTATE"]],
      mean_arterial_pressure = x[["MAP"]],
      age = x[["AGE"]],
    )

  coagscore <-
    phoenix_coagulation(
      platelets = x[["PLATELETS"]],
      inr = x[["INR"]],
      d_dimer = x[["DDIMER"]],
      fibrinogen = x[["FIBRINOGEN"]]
    )

  neuroscore <-
    phoenix_neurologic(
      gcs = x[["GCS"]],
      fixed_pupils = x[["FIXEDPUPILS"]]
    )

  endoscore <-
    phoenix_endocrine(
      glucose = x[["GLUCOSE"]]
    )

  immunscore <-
    phoenix_immunologic(
      anc = x[["ANC"]],
      alc = x[["ALC"]]
    )

  renalscore <-
    phoenix_renal(
      creatinine = x[["CREATININE"]],
      age = x[["AGE"]]
    )

  hepaticscore <-
    phoenix_hepatic(
      bilirubin = x[["BILIRUBIN"]],
      alt = x[["ALT"]]
    )

  oss <- phxdft_select(x, c(id.vars, eclock))
  oss <- phxdft_set(oss, j = "respscore", value = respscore)
  oss <- phxdft_set(oss, j = "cardscore", value = cardscore)
  oss <- phxdft_set(oss, j = "neuroscore", value = neuroscore)
  oss <- phxdft_set(oss, j = "coagscore", value = coagscore)
  oss <- phxdft_set(oss, j = "endoscore", value = endoscore)
  oss <- phxdft_set(oss, j = "immunscore", value = immunscore)
  oss <- phxdft_set(oss, j = "hepaticscore", value = hepaticscore)
  oss <- phxdft_set(oss, j = "renalscore", value = renalscore)


  if (verbose) message("    aggregating....")
  oss <-
    #aggregate(
    #  x = phxdft_select(oss, c("respscore", "cardscore", "neuroscore", "coagscore", "endoscore", "immunscore", "hepaticscore", "renalscore")),
    #  by = phxdft_select(oss, id.vars),
    #  FUN = max
    #)
    phxdft_aggregate(
      data = oss,
      y    = c("respscore", "cardscore", "neuroscore", "coagscore", "endoscore", "immunscore", "hepaticscore", "renalscore"),
      by   = id.vars,
      FUN  = max
    )

  if (verbose) message("    building indicators....")
  oss <-
    phxdft_set(
      x = oss,
      j = "odss_4_olm",
      # TeX: eq:odss-olm with eq:omega4.
      value = oss[["respscore"]] +
              oss[["cardscore"]] +
              oss[["neuroscore"]] +
              oss[["coagscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "odss_4_olm_septic_shock",
      # TeX: eq:septicshock-olm.
      value = as.integer(oss[["cardscore"]] >= kappa) * oss[["odss_4_olm"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "odss_8_olm",
      # TeX: eq:odss-olm with eq:omega8.
      value = oss[["respscore"]]  + oss[["cardscore"]] + oss[["neuroscore"]] + oss[["coagscore"]] +
              oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  phxdft_select(
    oss,
    c(id.vars, "odss_4_olm", "odss_4_olm_septic_shock", "odss_8_olm")
  )

}

ccd <- function(x, id.vars, eclock, sigma, kappa, pao2.spo2.delta, verbose) {
  # Exploratory Aggregation Schema 2:
  #   Organ-Level with Cardiovascular Component Decoupling.
  #
  # CCD is like OLM, except the cardiovascular score is split into its three
  # components before taking maxima:
  #
  #   max_t(resp_t) + max_t(vaso_t) + max_t(MAP_t) + max_t(lactate_t) +
  #   max_t(neuro_t) + max_t(coag_t)
  #
  # This lets vasoactive medication use, MAP dysfunction, and lactate
  # dysfunction peak at different times.  The other organ systems are still
  # aggregated as whole organ scores.
  #
  # TeX: eq:odss-ccd, eq:pss-ccd, eq:card-component-set, eq:sepsis-ccd, and eq:septicshock-ccd in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  if (verbose) message("    building organ system scores...")
  # Compute the row-level pieces that CCD will maximize separately.  Vasoactive
  # medication use, lactate, and MAP are intentionally scored as separate
  # cardiovascular components here.
  # TeX: eq:pfr-sfr-selector selects between row-level PFR and SFR.
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
      pf_ratio_eclock = x[["PFR_eclock"]],
      sf_ratio_eclock = x[["SFR_eclock"]],
      eclock = x[[eclock]],
      pao2.spo2.delta = pao2.spo2.delta,
      invasive_mechanical_ventilation = x[["IMV"]],
      other_respiratory_support = x[["ORS"]]
    )

  vasoscore <- vasoactive_score(x[["DOBUTAMINE"]] + x[["DOPAMINE"]] + x[["EPINEPHRINE"]] + x[["MILRINONE"]] + x[["NOREPINEPHRINE"]] + x[["VASOPRESSIN"]])
  lactatescore <- lactate_score(x[["LACTATE"]])
  mapscore <- map_score(x[["MAP"]], x[["AGE"]])

  coagscore <-
    phoenix_coagulation(
      platelets = x[["PLATELETS"]],
      inr = x[["INR"]],
      d_dimer = x[["DDIMER"]],
      fibrinogen = x[["FIBRINOGEN"]]
    )

  neuroscore <-
    phoenix_neurologic(
      gcs = x[["GCS"]],
      fixed_pupils = x[["FIXEDPUPILS"]]
    )

  endoscore <-
    phoenix_endocrine(
      glucose = x[["GLUCOSE"]]
    )

  immunscore <-
    phoenix_immunologic(
      anc = x[["ANC"]],
      alc = x[["ALC"]]
    )

  renalscore <-
    phoenix_renal(
      creatinine = x[["CREATININE"]],
      age = x[["AGE"]]
    )

  hepaticscore <-
    phoenix_hepatic(
      bilirubin = x[["BILIRUBIN"]],
      alt = x[["ALT"]]
    )

  oss <- phxdft_select(x, c(id.vars, eclock))
  oss <- phxdft_set(oss, j = "respscore", value = respscore)
  oss <- phxdft_set(oss, j = "vasoscore", value = vasoscore)
  oss <- phxdft_set(oss, j = "mapscore", value = mapscore)
  oss <- phxdft_set(oss, j = "lactatescore", value = lactatescore)
  oss <- phxdft_set(oss, j = "neuroscore", value = neuroscore)
  oss <- phxdft_set(oss, j = "coagscore", value = coagscore)
  oss <- phxdft_set(oss, j = "endoscore", value = endoscore)
  oss <- phxdft_set(oss, j = "immunscore", value = immunscore)
  oss <- phxdft_set(oss, j = "hepaticscore", value = hepaticscore)
  oss <- phxdft_set(oss, j = "renalscore", value = renalscore)


  if (verbose) message("    aggregating....")
  oss <-
    phxdft_aggregate(
      data = oss,
      y    = c("respscore", "vasoscore", "mapscore", "lactatescore", "neuroscore", "coagscore", "endoscore", "immunscore", "hepaticscore", "renalscore"),
      by   = id.vars,
      FUN  = max
    )

  if (verbose) message("    building indicators....")
  oss <-
    phxdft_set(
      x = oss,
      j = "odss_4_ccd",
      # TeX: eq:odss-ccd with eq:omega4 and eq:card-component-set.
      value = oss[["respscore"]] +
              oss[["vasoscore"]] +
              oss[["mapscore"]] +
              oss[["lactatescore"]] +
              oss[["neuroscore"]] +
              oss[["coagscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "odss_4_ccd_septic_shock",
      # TeX: eq:septicshock-ccd.
      value = as.integer((oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]]) >= kappa) * oss[["odss_4_ccd"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "odss_8_ccd",
      # TeX: eq:odss-ccd with eq:omega8 and eq:card-component-set.
      value = oss[["respscore"]]  +
        oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]] +
        oss[["neuroscore"]] + oss[["coagscore"]] +
        oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  phxdft_select(
    oss,
    c(id.vars, "odss_4_ccd", "odss_4_ccd_septic_shock", "odss_8_ccd")
  )

}

fcd <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Exploratory Aggregation Schema 3:
  #   Full Component Decoupling
  #
  # FCD decouples the individual scoring components as much as possible before
  # recomputing Phoenix-8.  In plain language, it asks:
  #
  #   "What is the worst available value for each component anywhere in the
  #    scoring window, and what score would those worst components produce?"
  #
  # Low values are worse for PF ratio, SF ratio, MAP, GCS, platelets,
  # fibrinogen, ALC, ANC, and age-sensitive creatinine scoring.  High values are
  # worse for IMV, other respiratory support, vasoactive medications, lactate,
  # fixed pupils, INR, D-dimer, bilirubin, ALT, and creatinine.  Glucose is
  # special because both low and high values can score endocrine dysfunction;
  # see the glucose handling below.
  #
  # TeX: eq:resp-fcd, eq:resp-fcd-conditions, eq:odss-fcd, eq:omega4-fcd,
  # eq:vasos-fcd, eq:omega8-fcd, eq:sepsis-fcd, and eq:septicshock-fcd in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  # Aggregate each component to one worst value per encounter before calling
  # `phoenix8()`.  This is intentionally different from `jama2024`, which scores
  # each time point first and only then takes the maximum summed score. Because
  # FCD aggregates PFR and SFR separately before scoring, the row-level
  # PaO2-vs-SpO2 selector in eq:pfr-sfr-selector is not applied here.
  if (verbose) message("    aggregating....")

  # Glucose can be abnormal in either direction: low glucose or high glucose can
  # contribute endocrine points.  Most other components have only one "bad"
  # direction.  To use a single `min_available()` aggregation for glucose, encode
  # high glucose values as 0.150 before taking the minimum.  This sentinel is
  # below the low-glucose cut point, so `phoenix_endocrine()` will still score it
  # as abnormal after aggregation.
  x[["GLUCOSE"]][ x[["GLUCOSE"]] > 150 ] <- 0.150
  min_available <- function(z) {
    if (all(is.na(z))) NA_real_ else min(z, na.rm = TRUE)
  }
  max_available <- function(z) {
    if (all(is.na(z))) NA_real_ else max(z, na.rm = TRUE)
  }

  mins <-
    phxdft_aggregate(
      data = x,
      y = c(
        "PFR", "SFR",
        "MAP",
        "GCS",
        "PLATELETS", "FIBRINOGEN",
        "GLUCOSE",
        "ALC", "ANC",
        "AGE"
        ),
      by = id.vars,
      FUN = min_available
    )

  maxs <-
    phxdft_aggregate(
      data = x,
      y = c(
        "IMV", "ORS",
        "DOBUTAMINE", "DOPAMINE", "EPINEPHRINE",
        "MILRINONE", "NOREPINEPHRINE", "VASOPRESSIN",
        "LACTATE",
        "FIXEDPUPILS",
        "INR", "DDIMER",
        "BILIRUBIN", "ALT",
        "CREATININE"
        ),
      by = id.vars,
      FUN = max_available
    )

  DF <- phxdft_left_join(mins, maxs, by = id.vars)

  if (verbose) message("    scoring....")
  p8 <-
    # After component-level aggregation, reuse `phoenix8()` to apply the same
    # component cut points as the published score.  The difference is only when
    # and how inputs are aggregated.
    # TeX: eq:odss-fcd applies phoenix8() after component-level min/max aggregation.
    phoenix8(
      # Respiratory
      pf_ratio = DF[["PFR"]],
      sf_ratio = DF[["SFR"]],
      invasive_mechanical_ventilation = DF[["IMV"]],
      other_respiratory_support = DF[["ORS"]],
      # Cardiovascular
      vasoactives = DF[["DOBUTAMINE"]] + DF[["DOPAMINE"]] + DF[["EPINEPHRINE"]] +
                    DF[["MILRINONE"]] + DF[["NOREPINEPHRINE"]] + DF[["VASOPRESSIN"]],
      lactate = DF[["LACTATE"]],
      mean_arterial_pressure = DF[["MAP"]],
      # Coagulation
      platelets  = DF[["PLATELETS"]],
      inr        = DF[["INR"]],
      d_dimer    = DF[["DDIMER"]],
      fibrinogen = DF[["FIBRINOGEN"]],
      # Neurological
      gcs = DF[["GCS"]],
      fixed_pupils = DF[["FIXEDPUPILS"]],
      # Endocrine
      glucose = DF[["GLUCOSE"]],
      # Immunologic
      anc = DF[["ANC"]],
      alc = DF[["ALC"]],
      # Renal
      creatinine = DF[["CREATININE"]],
      # Hepatic
      bilirubin = DF[["BILIRUBIN"]],
      alt = DF[["ALT"]],
      # age (used in cardiovascular and renal)
      age = DF[["AGE"]]
  )

  rtn <- phxdft_select(DF, cols = id.vars)
  # TeX: eq:odss-fcd and eq:septicshock-fcd.
  # `phoenix8()` returns columns named for the public Phoenix scores.  In this
  # helper those values are ODSS quantities because suspected infection gating is
  # applied only in `score_prepared_phoenix_data()`.
  rtn <- phxdft_set(rtn, j = "odss_4_fcd", value = p8[["phoenix_sepsis_score"]])
  rtn <- phxdft_set(rtn, j = "odss_4_fcd_septic_shock", value = as.integer(p8[["phoenix_cardiovascular_score"]] >= kappa) * p8[["phoenix_sepsis_score"]])
  rtn <- phxdft_set(rtn, j = "odss_8_fcd", value = p8[["phoenix8_sepsis_score"]])

  rtn
}
