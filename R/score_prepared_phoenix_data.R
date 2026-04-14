#' Score Prepared Phoenix Data
#'
#' @param x an object returned from \code{\link{prepare_phoenix_data}}
#' @param T0 The start of observation window for assessing if the patient has
#'   sepsis or septic shock.
#' @param T1 The end of the observation window for assessing if the patient has
#'   sepsis or septic shock.
#' @param sigma numeric (integer) value, sepsis = sepsis_score >= sigma.
#' @param kappa numeric (integer) value, minimum cardiovascular score required
#' to flag septic shock.
#' @param version The scoring version to apply to the data.  Default is
#'   "jama2024" the scoring method used to develope the Phoenix Sepsis Criteria.
#'   See Details.
#' @param verbose when \code{TRUE}, display progress messages
#'
#' @export
score_prepared_phoenix_data <- function(x, T0 = 0, T1 = 1440, sigma = 2, kappa = 1, version = c("jama2024", "alt1", "alt2"), verbose = getOption("phoenix_verbose", interactive())) {
  stopifnot(inherits(x, "prepared_phoenix_data"))
  stopifnot(length(sigma) == 1, length(kappa) == 1, is.numeric(sigma), is.numeric(kappa))
  version <- match.arg(version, several.ok = FALSE)

  if (verbose) message("Scoring prepared_phoenix_data...")
  if (verbose) message("  identifying suspsected infections...")
  # suspected infection is set for the id.var over the window of interest
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
      version,
      jama2024 = jama2024(x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      alt1     = alt1(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      alt2     = alt2(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      alt3     = alt3(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      alt4     = alt4(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      alt5     = alt5(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      alt6     = alt6(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose),
      alt7     = alt7(    x = score_this, id.vars = attr(x, "id.vars"), eclock = attr(x, "eclock"), sigma = sigma, kappa = kappa, verbose = verbose)
    )

  if (verbose) message("  building outout...")
  iddf <- phxdft_unique(phxdft_select(x, attr(x, "id.vars")))
  rtn <- phxdft_left_join(iddf, si, attr(x, "id.vars"))
  rtn <- phxdft_left_join(rtn, pss, attr(x, "id.vars"))

  attr(rtn, "T0") <- T0
  attr(rtn, "T1") <- T1
  attr(rtn, "version") <- version
  class(rtn) <- c("scored_prepared_phoenix_data", class(rtn))

  if (verbose) message("Scoring complete!")
  rtn
}

jama2024 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Overlly simplified, the score is max( resp + card + neuro + coag )

  if (verbose) message("    building organ system scores...")
  # find all the needed organ system scores at every moment in time
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
      imv = x[["IMV"]],
      other_respiratory_support = x[["ORS"]]
    )

  cardscore <-
    phoenix_cardiovascular(
      vasoactives = x[["DOBUTAMINE"]] + x[["DOPAMINE"]] + x[["EPINEPHRINE"]] + x[["MILRINONE"]] + x[["NOREPINEPHRINE"]] + x[["VASOPRESSIN"]],
      lactate = x[["LACTATE"]],
      map = x[["MAP"]],
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
      value = respscore + cardscore + neuroscore + coagscore
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix_septic_shock_score",
      value = as.integer(cardscore >= kappa) * oss[["phoenix_sepsis_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix8_sepsis_score",
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
      value = as.integer(oss[["phoenix_sepsis_score"]] >= sigma)
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "phoenix_septic_shock",
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

alt1 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Overlly simplified, the score is
  # max(resp) + max(card) + max(neuro) + max(coag)

  if (verbose) message("    building organ system scores...")
  # find all the needed organ system scores at every moment in time
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
      imv = x[["IMV"]],
      other_respiratory_support = x[["ORS"]]
    )

  cardscore <-
    phoenix_cardiovascular(
      vasoactives = x[["DOBUTAMINE"]] + x[["DOPAMINE"]] + x[["EPINEPHRINE"]] + x[["MILRINONE"]] + x[["NOREPINEPHRINE"]] + x[["VASOPRESSIN"]],
      lactate = x[["LACTATE"]],
      map = x[["MAP"]],
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
      j = "alt1_sepsis_score",
      value = oss[["respscore"]] +
              oss[["cardscore"]] +
              oss[["neuroscore"]] +
              oss[["coagscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "alt1_septic_shock_score",
      value = as.integer(oss[["cardscore"]] >= kappa) * oss[["alt1_sepsis_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "alt1_8_sepsis_score",
      value = oss[["respscore"]]  + oss[["cardscore"]] + oss[["neuroscore"]] + oss[["coagscore"]] +
              oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "alt1_sepsis",
      value = as.integer(oss[["alt1_sepsis_score"]] >= sigma)
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "alt1_septic_shock",
      value = as.integer(oss[["alt1_septic_shock_score"]] >= sigma)
    )

  # omit the septic_shock_score
  oss <-
    phxdft_set(
      x = oss,
      j = "alt1_septic_shock_score",
      value = NULL
    )

  phxdft_select(
    oss,
    c(id.vars, "alt1_sepsis_score", "alt1_sepsis", "alt1_septic_shock", "alt1_8_sepsis_score")
  )

}

alt2 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  # Overlly simplified, the score is
  # max(resp) + max(vaso) + max(map) + max(lactate) + max(neuro) + max(coag)

  if (verbose) message("    building organ system scores...")
  # find all the needed organ system scores at every moment in time
  respscore <-
    phoenix_respiratory(
      pf_ratio = x[["PFR"]],
      sf_ratio = x[["SFR"]],
      imv = x[["IMV"]],
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
      j = "alt2_sepsis_score",
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
      j = "alt2_septic_shock_score",
      value = as.integer((oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]]) >= kappa) * oss[["alt2_sepsis_score"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "alt2_8_sepsis_score",
      value = oss[["respscore"]]  +
        oss[["vasoscore"]] + oss[["mapscore"]] + oss[["lactatescore"]] +
        oss[["neuroscore"]] + oss[["coagscore"]] +
        oss[["immunscore"]] + oss[["endoscore"]] + oss[["renalscore"]] + oss[["hepaticscore"]]
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "alt2_sepsis",
      value = as.integer(oss[["alt2_sepsis_score"]] >= sigma)
    )

  oss <-
    phxdft_set(
      x = oss,
      j = "alt2_septic_shock",
      value = as.integer(oss[["alt2_septic_shock_score"]] >= sigma)
    )

  # omit the septic_shock_score
  oss <-
    phxdft_set(
      x = oss,
      j = "alt2_septic_shock_score",
      value = NULL
    )

  phxdft_select(
    oss,
    c(id.vars, "alt2_sepsis_score", "alt2_sepsis", "alt2_septic_shock", "alt2_8_sepsis_score")
  )

}

alt3 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  stop("version alt3 not yet implimented")
}
alt4 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  stop("version alt4 not yet implimented")
}
alt5 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  stop("version alt5 not yet implimented")
}
alt6 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  stop("version alt6 not yet implimented")
}
alt7 <- function(x, id.vars, eclock, sigma, kappa, verbose) {
  stop("version alt7 not yet implimented")
}
