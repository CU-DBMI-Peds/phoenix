#' Score Prepared Phoenix Data
#'
#' Apply the published and experimental aggregation schema and scoring to
#' prepared Phoneix Data.
#'
#' TODO: Make a nice table and and pros
#'
#' published  Published, time-aligned Phoenix aggregation
#' olm        Exploratory aggregation scheme 1: organ-level maxima
#' ccd       Exploratory aggregation scheme 2: organ-level maxima with
#'            cardiovascular component decoupling
#' fcd       Total decoupling
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
#' @param sigma numeric (integer) value, sepsis = sepsis_score >= sigma.
#' @param kappa numeric (integer) value, minimum cardiovascular score required
#' to flag septic shock.
#' @param aggregation The aggregation approach to apply to the data.  Default is
#'   "jama2024" the scoring method used to develop the Phoenix Sepsis Criteria.
#'   See Details.
#' @param verbose when \code{TRUE}, display progress messages
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
  # now, the data of interest that needs to be scored is only for those with a
  # suspected infection and within the window [T0, T1)
  score_this <-
    phxdft_inner_join(
      x = phxdft_subset(x, i = which((x[[attr(x, "eclock")]] >= T0) & (x[[attr(x, "eclock")]] < T1))),
      y = phxdft_subset(si, i = which(si[["suspected_infection"]] > 0), cols = attr(x, "id.vars")),
      by = attr(x, "id.vars")
    )

  if (verbose) message("  applying scoring...")
  # apply the scoring method to the oss and si
  pss <-
    switch(
      aggregation,
      jama2024 = jama2024(x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      olm     = olm(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      ccd     = ccd(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      fcd     = fcd(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose)
    )

  if (verbose) message("  building outout...")
  iddf <- phxdft_unique(phxdft_select(x, attr(x, "id.vars")))
  rtn <- phxdft_left_join(iddf, si, attr(x, "id.vars"))
  rtn <- phxdft_left_join(rtn, pss, attr(x, "id.vars"))

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
  # Overly simplified, the score is max( resp + card + neuro + coag )
  #
  # TeX: eq:pss, eq:omega4, eq:omega8, eq:sepsis, and eq:septicshock in
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
      j = "phoenix_sepsis_score",
      # TeX: eq:pss with eq:omega4.
      value = respscore + cardscore + neuroscore + coagscore
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix_septic_shock_score",
      # TeX: eq:septicshock.
      value = as.integer(cardscore >= kappa) * oss[["phoenix_sepsis_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix8_sepsis_score",
      # TeX: eq:pss with eq:omega8.
      value = respscore + cardscore + neuroscore + coagscore +
              immunscore + endoscore + renalscore + hepaticscore
    )

  if (verbose) message("    aggregating....")
  # find the max value of the scores
  oss <-
    #aggregate(
    #  x = phxdft_select(oss, c("phoenix_sepsis_score", "phoenix_septic_shock_score", "phoenix8_sepsis_score")),
    #  by = phxdft_select(oss, id.vars),
    #  FUN = max
    #)
    phxdft_aggregate(
      data = oss,
      y    = c("phoenix_sepsis_score", "phoenix_septic_shock_score", "phoenix8_sepsis_score"),
      by   = id.vars,
      FUN  = max
    )

  if (verbose) message("    building indicators....")
  # build the sepsis and septic shock indicators
  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix_sepsis",
      # TeX: eq:sepsis.
      value = as.integer(oss[["phoenix_sepsis_score"]] >= sigma)
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix_septic_shock",
      # TeX: eq:septicshock.
      value = as.integer(oss[["phoenix_septic_shock_score"]] >= sigma)
    )

  # omit the septic_shock_score
  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix_septic_shock_score",
      value = NULL
    )

  oss

}

olm <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Exploratory Aggregation Schema 1:
  #   Organ-Level Maxima (OLM)
  #
  # Overly simplified, the score is
  #   max(resp) + max(card) + max(neuro) + max(coag)
  #
  # TeX: eq:pss-olm, eq:sepsis-olm, and eq:septicshock-olm in
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
      j = "olm_sepsis_score",
      # TeX: eq:pss-olm with eq:omega4.
      value = oss[["respscore"]] +
              oss[["cardscore"]] +
              oss[["neuroscore"]] +
              oss[["coagscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "olm_septic_shock_score",
      # TeX: eq:septicshock-olm.
      value = as.integer(oss[["cardscore"]] >= kappa) * oss[["olm_sepsis_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "olm_8_sepsis_score",
      # TeX: eq:pss-olm with eq:omega8.
      value = oss[["respscore"]]  + oss[["cardscore"]] + oss[["neuroscore"]] + oss[["coagscore"]] +
              oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "olm_sepsis",
      # TeX: eq:sepsis-olm.
      value = as.integer(oss[["olm_sepsis_score"]] >= sigma)
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "olm_septic_shock",
      # TeX: eq:septicshock-olm.
      value = as.integer(oss[["olm_septic_shock_score"]] >= sigma)
    )

  # omit the septic_shock_score
  oss <-
    phxdft_set(
      x = oss,
      j = "olm_septic_shock_score",
      value = NULL
    )

  phxdft_select(
    oss,
    c(id.vars, "olm_sepsis_score", "olm_sepsis", "olm_septic_shock", "olm_8_sepsis_score")
  )

}

ccd <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Exploratory Aggregation Schema 2:
  #   Organ-Level with Cardiovascular Component Decoupling.
  #
  # Overly simplified, the score is
  #   max(resp) + max(vaso) + max(MAP) + max(lactate) + max(neuro) + max(coag)
  #
  # TeX: eq:pss-ccd, eq:card-component-set, eq:sepsis-ccd, and eq:septicshock-ccd in
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
      j = "ccd_sepsis_score",
      # TeX: eq:pss-ccd with eq:omega4 and eq:card-component-set.
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
      j = "ccd_septic_shock_score",
      # TeX: eq:septicshock-ccd.
      value = as.integer((oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]]) >= kappa) * oss[["ccd_sepsis_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "ccd_8_sepsis_score",
      # TeX: eq:pss-ccd with eq:omega8 and eq:card-component-set.
      value = oss[["respscore"]]  +
        oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]] +
        oss[["neuroscore"]] + oss[["coagscore"]] +
        oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "ccd_sepsis",
      # TeX: eq:sepsis-ccd.
      value = as.integer(oss[["ccd_sepsis_score"]] >= sigma)
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "ccd_septic_shock",
      # TeX: eq:septicshock-ccd.
      value = as.integer(oss[["ccd_septic_shock_score"]] >= sigma)
    )

  # omit the septic_shock_score
  oss <-
    phxdft_set(
      x = oss,
      j = "ccd_septic_shock_score",
      value = NULL
    )

  phxdft_select(
    oss,
    c(id.vars, "ccd_sepsis_score", "ccd_sepsis", "ccd_septic_shock", "ccd_8_sepsis_score")
  )

}

fcd <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Exploratory Aggregation Schema 3:
  #   Full Component Decoupling
  #
  # Overly simplified, the score is
  #  max(IVM) * (PRF | SFR) + max(ORS) * (PRF | SFR) +  # respiratory
  #  max(vaso) + max(MAP) + max(lactate) + # cardio
  #  min( {2, max(GCS) + 2 * max(pupils) }) + # neuro
  #  min(2, sum(platetes + INR + DDimer + Fibrinogen) )
  #
  # TeX: eq:resp-fcd, eq:resp-fcd-conditions, eq:pss-fcd, eq:omega4-fcd,
  # eq:omega8-fcd, eq:sepsis-fcd, and eq:septicshock-fcd in
  # vignettes/articles/operational-definition-phoenix-sepsis-criteria.tex

  # Aggregate
  if (verbose) message("    aggregating....")

  # NOTE: glucose will results in endocrine points if too lower or too high.
  # All other inputs are just too low or too high.  To make things easier, look
  # for any value in the glucose that is over 150 and set to 0.150 and then take
  # the min
  x[["GLUCOSE"]][ x[["GLUCOSE"]] > 150 ] <- 0.150

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
      FUN = min
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
      FUN = max
    )

  DF <- phxdft_left_join(mins, maxs, by = id.vars)

  if (verbose) message("    scoring....")
  p8 <-
    # TeX: eq:pss-fcd applies phoenix8() after component-level min/max aggregation.
    phoenix8(
    # Respiratory
    pf_ratio = PFR,
    sf_ratio = SFR,
    invasive_mechanical_ventilation = IMV,
    other_respiratory_support = ORS,
    # Cardiovascular
    vasoactive = DOBUTAMINE + DOPAMINE + EPINEPHRINE +
                 MILRINONE + NOREPINEPHRINE + VASOPRESSIN,
    lactate = LACTATE,
    mean_arterial_pressure = MAP,
    # Coagulation
    platelets  = PLATELETS,
    inr        = INR,
    d_dimer    = DDIMER,
    fibrinogen = FIBRINOGEN,
    # Neurological
    gcs = GCS,
    fixed_pupils = FIXEDPUPILS,
    # Endocrine
    glucose = GLUCOSE,
    # Immunologic
    anc = ANC,
    alc = ALC,
    # Renal
    creatinine = CREATININE,
    # Hepatic
    bilirubin = BILIRUBIN,
    alt = ALT,
    # age (used in cardiovascular and renal)
    age = AGE,
    data = DF
  )

  rtn <- phxdft_select(DF, cols = id.vars)
  # TeX: eq:pss-fcd, eq:sepsis-fcd, and eq:septicshock-fcd.
  rtn <- phxdft_set(rtn, j = "fcd_sepsis_score", value = p8[["phoenix_sepsis_score"]])
  rtn <- phxdft_set(rtn, j = "fcd_sepsis", value = as.integer(p8[["phoenix_sepsis_score"]] >= sigma))
  rtn <- phxdft_set(rtn, j = "fcs_septic_shock", value = rtn[["fcd_sepsis"]] * as.integer(p8[["phoenix_cardiovascular_score"]] >= kappa))
  rtn <- phxdft_set(rtn, j = "fcd_8_sepsis_score", value = p8[["phoenix8_sepsis_score"]])

  rtn
}
