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
#' @param verbose when \code{TRUE}, display progress messages
#'
#' @return A scored data frame with one row per encounter identifier. The output
#'   always includes \code{suspected_infection}. For the selected aggregation it
#'   includes four-organ ODSS, four-organ PSS, sepsis and septic shock indicators,
#'   eight-organ ODSS, and eight-organ PSS. For example,
#'   \code{aggregation = "jama2024"} returns
#'   \code{phoenix_organ_dysfunction_score},
#'   \code{phoenix_sepsis_score}, \code{phoenix_sepsis},
#'   \code{phoenix_septic_shock},
#'   \code{phoenix8_organ_dysfunction_score}, and
#'   \code{phoenix8_sepsis_score}.
#'
#' @seealso \code{\link{prepare_inputs_range}},
#' \code{\link{prepare_inputs_discrete}}
#'
#' @references See reference details in \code{\link{phoenix-package}} or by calling
#' \code{citation('phoenix')}.
#'
#' @export
score_prepared_phoenix_data <- function(x, T0 = 0, T1 = 1440, sigma = 2, kappa = 1, aggregation = c("jama2024", "olm", "ccd", "fcd"), verbose = getOption("phoenix_verbose", interactive())) {
  stopifnot(inherits(x, "prepared_phoenix_data"))
  stopifnot(length(sigma) == 1, length(kappa) == 1, is.numeric(sigma), is.numeric(kappa))
  aggregation <- match.arg(aggregation, several.ok = FALSE)

  if (verbose) message("Scoring prepared_phoenix_data...")
  if (verbose) message("  identifying suspsected infections...")
  # suspected infection is set for the id.var over the window of interest
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

  # aggregate suspected infections to a 0/1 for the window of interest
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
  ods <- phxdft_unique(phxdft_select(score_this, attr(x, "id.vars")))
  if (nrow(score_this) > 0L) {
    ods <-
      switch(
        aggregation,
        jama2024 = jama2024(x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
        olm     = olm(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
        ccd     = ccd(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
        fcd     = fcd(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose)
      )
  }

  if (verbose) message("  building outout...")
  iddf <- phxdft_unique(phxdft_select(x, attr(x, "id.vars")))
  rtn <- phxdft_left_join(iddf, si, attr(x, "id.vars"))
  rtn <- phxdft_left_join(rtn, ods, attr(x, "id.vars"))
  suspected_infection <- rtn[["suspected_infection"]]
  suspected_infection[is.na(suspected_infection)] <- 0L
  rtn <- phxdft_set(rtn, j = "suspected_infection", value = suspected_infection)

  score_columns <-
    switch(
      aggregation,
      jama2024 = list(
        ods4 = "phoenix_organ_dysfunction_score",
        shock_ods = "phoenix_septic_shock_organ_dysfunction_score",
        pss4 = "phoenix_sepsis_score",
        sepsis = "phoenix_sepsis",
        shock = "phoenix_septic_shock",
        ods8 = "phoenix8_organ_dysfunction_score",
        pss8 = "phoenix8_sepsis_score"
      ),
      olm = list(
        ods4 = "olm_organ_dysfunction_score",
        shock_ods = "olm_septic_shock_organ_dysfunction_score",
        pss4 = "olm_sepsis_score",
        sepsis = "olm_sepsis",
        shock = "olm_septic_shock",
        ods8 = "olm_8_organ_dysfunction_score",
        pss8 = "olm_8_sepsis_score"
      ),
      ccd = list(
        ods4 = "ccd_organ_dysfunction_score",
        shock_ods = "ccd_septic_shock_organ_dysfunction_score",
        pss4 = "ccd_sepsis_score",
        sepsis = "ccd_sepsis",
        shock = "ccd_septic_shock",
        ods8 = "ccd_8_organ_dysfunction_score",
        pss8 = "ccd_8_sepsis_score"
      ),
      fcd = list(
        ods4 = "fcd_organ_dysfunction_score",
        shock_ods = "fcd_septic_shock_organ_dysfunction_score",
        pss4 = "fcd_sepsis_score",
        sepsis = "fcd_sepsis",
        shock = "fcd_septic_shock",
        ods8 = "fcd_8_organ_dysfunction_score",
        pss8 = "fcd_8_sepsis_score"
      )
    )
  for (col in c(score_columns[["ods4"]], score_columns[["shock_ods"]], score_columns[["ods8"]])) {
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
  pss4 <- rtn[["suspected_infection"]] * rtn[[score_columns[["ods4"]]]]
  pss8 <- rtn[["suspected_infection"]] * rtn[[score_columns[["ods8"]]]]
  septic_shock_score <- rtn[["suspected_infection"]] * rtn[[score_columns[["shock_ods"]]]]
  rtn <- phxdft_set(rtn, j = score_columns[["pss4"]], value = pss4)
  rtn <- phxdft_set(rtn, j = score_columns[["sepsis"]], value = as.integer(pss4 >= sigma))
  rtn <- phxdft_set(rtn, j = score_columns[["shock"]], value = as.integer(septic_shock_score >= sigma))
  rtn <- phxdft_set(rtn, j = score_columns[["pss8"]], value = pss8)
  rtn <- phxdft_set(rtn, j = score_columns[["shock_ods"]], value = NULL)

  attr(rtn, "T0") <- T0
  attr(rtn, "T1") <- T1
  attr(rtn, "aggregation") <- aggregation
  class(rtn) <- c("scored_prepared_phoenix_data", class(rtn))

  if (verbose) message("Scoring complete!")
  rtn
}

jama2024 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # The scoring method used when Phoenix was developed and published in JAMA
  # (2024).
  #
  # Overly simplified, the ODSS is max( resp + card + neuro + coag )
  #
  # TeX: eq:odss, eq:pss, eq:omega4, eq:omega8, eq:sepsis, and eq:septicshock in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  if (verbose) message("    building organ system scores...")
  # find all the needed organ system scores at every moment in time
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
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
      j = "phoenix_organ_dysfunction_score",
      # TeX: eq:odss with eq:omega4.
      value = respscore + cardscore + neuroscore + coagscore
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix_septic_shock_organ_dysfunction_score",
      # TeX: eq:septicshock.
      value = as.integer(cardscore >= kappa) * oss[["phoenix_organ_dysfunction_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix8_organ_dysfunction_score",
      # TeX: eq:odss with eq:omega8.
      value = respscore + cardscore + neuroscore + coagscore +
              immunscore + endoscore + renalscore + hepaticscore
    )

  if (verbose) message("    aggregating....")
  # find the max value of the scores
  oss <-
    #aggregate(
    #  x = phxdft_select(oss, c("phoenix_organ_dysfunction_score", "phoenix_septic_shock_organ_dysfunction_score", "phoenix8_organ_dysfunction_score")),
    #  by = phxdft_select(oss, id.vars),
    #  FUN = max
    #)
    phxdft_aggregate(
      data = oss,
      y    = c("phoenix_organ_dysfunction_score", "phoenix_septic_shock_organ_dysfunction_score", "phoenix8_organ_dysfunction_score"),
      by   = id.vars,
      FUN  = max
    )

  oss

}

olm <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Exploratory Aggregation Schema 1:
  #   Organ-Level Maxima (OLM)
  #
  # Overly simplified, the ODSS is
  #   max(resp) + max(card) + max(neuro) + max(coag)
  #
  # TeX: eq:odss-olm, eq:pss-olm, eq:sepsis-olm, and eq:septicshock-olm in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  if (verbose) message("    building organ system scores...")
  # find all the needed organ system scores at every moment in time
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
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
      j = "olm_organ_dysfunction_score",
      # TeX: eq:odss-olm with eq:omega4.
      value = oss[["respscore"]] +
              oss[["cardscore"]] +
              oss[["neuroscore"]] +
              oss[["coagscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "olm_septic_shock_organ_dysfunction_score",
      # TeX: eq:septicshock-olm.
      value = as.integer(oss[["cardscore"]] >= kappa) * oss[["olm_organ_dysfunction_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "olm_8_organ_dysfunction_score",
      # TeX: eq:odss-olm with eq:omega8.
      value = oss[["respscore"]]  + oss[["cardscore"]] + oss[["neuroscore"]] + oss[["coagscore"]] +
              oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  phxdft_select(
    oss,
    c(id.vars, "olm_organ_dysfunction_score", "olm_septic_shock_organ_dysfunction_score", "olm_8_organ_dysfunction_score")
  )

}

ccd <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Exploratory Aggregation Schema 2:
  #   Organ-Level with Cardiovascular Component Decoupling.
  #
  # Overly simplified, the ODSS is
  #   max(resp) + max(vaso) + max(MAP) + max(lactate) + max(neuro) + max(coag)
  #
  # TeX: eq:odss-ccd, eq:pss-ccd, eq:card-component-set, eq:sepsis-ccd, and eq:septicshock-ccd in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  if (verbose) message("    building organ system scores...")
  # find all the needed organ system scores at every moment in time
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
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
      j = "ccd_organ_dysfunction_score",
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
      j = "ccd_septic_shock_organ_dysfunction_score",
      # TeX: eq:septicshock-ccd.
      value = as.integer((oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]]) >= kappa) * oss[["ccd_organ_dysfunction_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "ccd_8_organ_dysfunction_score",
      # TeX: eq:odss-ccd with eq:omega8 and eq:card-component-set.
      value = oss[["respscore"]]  +
        oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]] +
        oss[["neuroscore"]] + oss[["coagscore"]] +
        oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  phxdft_select(
    oss,
    c(id.vars, "ccd_organ_dysfunction_score", "ccd_septic_shock_organ_dysfunction_score", "ccd_8_organ_dysfunction_score")
  )

}

fcd <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Exploratory Aggregation Schema 3:
  #   Full Component Decoupling
  #
  # Overly simplified, the ODSS is
  #  max(IVM) * (PRF | SFR) + max(ORS) * (PRF | SFR) +  # respiratory
  #  max(vaso) + max(MAP) + max(lactate) + # cardio
  #  min( {2, max(GCS) + 2 * max(pupils) }) + # neuro
  #  min(2, sum(platetes + INR + DDimer + Fibrinogen) )
  #
  # TeX: eq:resp-fcd, eq:resp-fcd-conditions, eq:odss-fcd, eq:omega4-fcd,
  # eq:vasos-fcd, eq:omega8-fcd, eq:sepsis-fcd, and eq:septicshock-fcd in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  # Aggregate
  if (verbose) message("    aggregating....")

  # NOTE: glucose will results in endocrine points if too lower or too high.
  # All other inputs are just too low or too high.  To make things easier, look
  # for any value in the glucose that is over 150 and set to 0.150 and then take
  # the min
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
  rtn <- phxdft_set(rtn, j = "fcd_organ_dysfunction_score", value = p8[["phoenix_sepsis_score"]])
  rtn <- phxdft_set(rtn, j = "fcd_septic_shock_organ_dysfunction_score", value = as.integer(p8[["phoenix_cardiovascular_score"]] >= kappa) * p8[["phoenix_sepsis_score"]])
  rtn <- phxdft_set(rtn, j = "fcd_8_organ_dysfunction_score", value = p8[["phoenix8_sepsis_score"]])

  rtn
}
