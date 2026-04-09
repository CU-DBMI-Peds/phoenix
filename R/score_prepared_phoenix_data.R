#' Score Prepared Phoenix Data
#'
#' @param x an object returned from \code{\link{prepare_phoenix_data}}
#' @param T0 The start of observation window for assessing if the patient has
#'   sepsis or septic shock.
#' @param T1 The end of the observation window for assessing if the patient has
#'   sepsis or septic shock.
#' @param version The scoring version to apply to the data.  Default is
#'   "jama2024" the scoring method used to develope the Phoenix Sepsis Criteria.
#'   See Details.
#'
#' @export
score_prepared_phoenix_data <- function(x, T0 = 0, T1 = 1440, sigma = 2, kappa = 1, version = c("jama2024", "alt1", "alt2")) {
  stopifnot(inherits(x, "prepared_phoenix_data"))
  version <- match.arg(version, several.ok = FALSE)

  rtn <-
    switch(
      version,
      jama2024 = jama2024(x, T0, T1, sigma = sigma, kappa = kappa),
      alt1     = alt1(x, T0, T1, sigma = sigma, kappa = kappa)
    )
  attr(rtn, "T0") <- T0
  attr(rtn, "T1") <- T1
  attr(rtn, "version") <- version
  class(rtn) <- c("scored_prepared_phoenix_data", class(rtn))
  rtn
}

jama2024 <- function(x, T0, T1, sigma, kappa) {

  # organ system scores
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

  scores <- phxdft_select(x, c(attr(x, "id.vars"), attr(x, "eclock")))

  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix_sepsis_score",
      value = respscore + cardscore + neuroscore + coagscore
    )
  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix_septic_shock_score",
      value = as.integer(cardscore >= kappa) * scores[["phoenix_sepsis_score"]]
    )
  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix8_sepsis_score",
      value = respscore + cardscore + neuroscore + coagscore + 
              immunscore + endoscore + renalscore + hepaticscore
    )

  # suspected infection
  si <-
    phxdft_set(
      x = phxdft_select(x, c(attr(x, "id.vars"), attr(x, "eclock"))),
      j = "SI",
      value =
        as.integer(
          !is.na(x[["ANTIMICROBIALS"]]) & !is.na(x[["ANTIINFECTIOUSTESTS"]]) &
            (x[["ANTIMICROBIALS"]] == 1) & (x[["ANTIINFECTIOUSTESTS"]] == 1)
        )
    )

  # aggregate suspected infections to a 0/1 for the window of interest
  si <-
    phxdft_subset(
      x = si,
      i = which((si[[attr(x, "eclock")]] >= T0) & (si[[attr(x, "eclock")]] < T1))
    )
  si <-
    aggregate(
      x = phxdft_select(si, "SI"),
      by = phxdft_select(si, id.vars),
      FUN = max
    )

  # subset scores to the window of interest, and merge on the SI value
  scores <-
    phxdft_subset(
      x = scores,
      i = which((scores[[attr(x, "eclock")]] >= T0) & (scores[[attr(x, "eclock")]] < T1))
    )

  scores <- phxdft_left_join(scores, si, by = attr(x, 'id.vars'))

  # scores multipled by SI to zero out values for those without a
  # suspected infection
  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix_sepsis_score",
      value = scores[["SI"]] * scores[["phoenix_sepsis_score"]]
    )

  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix_septic_shock_score",
      value = scores[["SI"]] * scores[["phoenix_septic_shock_score"]]
    )

  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix8_sepsis_score",
      value = scores[["SI"]] * scores[["phoenix8_sepsis_score"]]
    )

  # find the max value
  scores <-
    aggregate(
      x = phxdft_select(scores, c("SI", "phoenix_sepsis_score", "phoenix_septic_shock_score", "phoenix8_sepsis_score")),
      by = phxdft_select(scores, id.vars),
      FUN = max
    )

  scores <-
    phxdft_setnames(
      x = scores,
      old = "SI",
      new = "suspected_infection"
    )

  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix_sepsis",
      value = as.integer(scores[["phoenix_sepsis_score"]] >= sigma)
    )

  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix_septic_shock",
      value = as.integer(scores[["phoenix_septic_shock_score"]] >= sigma)
    )

  scores <-
    phxdft_set(
      x = scores,
      j = "phoenix_septic_shock_score",
      value = NULL
    )

  scores

}

alt1 <- function(x, T0, T1) {
  scores <-
    phoenix8(
      pf_ratio = PFR,
      sf_ratio = SFR,
      imv = IMV,
      other_respiratory_support = ORS,
      vasoactives = DOBUTAMINE + DOPAMINE + EPINEPHRINE + MILRINONE + NOREPINEPHRINE + VASOPRESSIN,
      lactate = LACTATE,
      map = MAP,
      platelets = PLATELETS,
      inr = INR,
      d_dimer = DDIMER,
      fibrinogen = FIBRINOGEN,
      gcs = GCS,
      fixed_pupils = FIXEDPUPILS,
      glucose = GLUCOSE,
      anc = ANC,
      alc = ALC,
      creatinine = CREATININE,
      bilirubin = BILIRUBIN,
      alt = ALT,
      age = AGE,
      data = x
    )
  scores <-
    cbind(
      phxdft_select(x, c(attr(x, "id.vars"), attr(x, "eclock"))),
      scores
    )

  keep <- (scores[[attr(x, "eclock")]] >= T0) & (scores[[attr(x, "eclock")]] < T1)
  scores <- phxdft_subset(scores, i = keep)

  scores <-
    aggregate(
      x = 
        phxdft_select(scores, 
          paste0(
            "phoenix_",
            c("respiratory", "cardiovascular", "coagulation", "neurologic", "endocrine", "immunologic", "hepatic", "renal"),
            "_score")
        )
      ,
      by  = phxdft_select(scores, attr(x, "id.vars")),
      FUN = max
    )

  #
  scores <-
    phxdft_set(
      x = scores,
      j = "alt1_sepsis_score",
      value = scores[["phoenix_respiratory_score"]] +
              scores[["phoenix_cardiovascular_score"]] +
              scores[["phoenix_neurologic_score"]] +
              scores[["phoenix_coagulation_score"]]
    )
  scores <-
    phxdft_set(
      x = scores,
      j = "alt1_8_sepsis_score",
      value = 
        scores[["alt1_sepsis_score"]] +
        scores[["phoenix_immunologic_score"]] +
        scores[["phoenix_endocrine_score"]] +
        scores[["phoenix_hepatic_score"]] +
        scores[["phoenix_renal_score"]]
    )
  scores <-
    phxdft_set(
      x = scores,
      j = "alt1_sepsis",
      value = as.integer(scores[["alt1_sepsis_score"]] >= 2)
    )
  scores <-
    phxdft_set(
      x = scores,
      j = "alt1_septic_shock",
      value = as.integer(scores[["phoenix_cardiovascular_score"]] > 0 & scores[["alt1_sepsis_score"]] >= 2)
    )

  phxdft_select(scores, c(id.vars, grep("^alt1", names(scores), value = TRUE)))

}
