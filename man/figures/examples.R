# The two calls and code here are expedcted to be used as the source for screen
# shots and submitted in a research letter




  library(phoenix)

  phoenix_scores <-
    phoenix(
      # respiratory
        pf_ratio = pao2 / fio2,
        sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
        imv = vent,
        other_respiratory_support = as.integer(fio2 > 0.21),
      # cardiovascular
        vasoactives = dobutamine + dopamine + epinephrine +
                      milrinone + norepinephrine + vasopressin,
        lactate = lactate,
        age = age,
        map = dbp + (sbp - dbp)/3,
      # coagulation
        platelets = platelets,
        inr = inr,
        d_dimer = d_dimer,
        fibrinogen = fibrinogen,
      # neurologic
        gcs = gcs_total,
        fixed_pupils = as.integer(pupil == "both-fixed"),
      data = sepsis
    )

  str(phoenix_scores)
  # 'data.frame':	20 obs. of  7 variables:
  #  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
  #  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
  #  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
  #  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
  #  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
  #  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
  #  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...




  phoenix8_scores <-
    phoenix8(
      # respiratory
        pf_ratio = pao2 / fio2,
        sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
        imv = vent,
        other_respiratory_support = as.integer(fio2 > 0.21),
      # cardiovascular
        vasoactives = dobutamine + dopamine + epinephrine +
                      milrinone + norepinephrine + vasopressin,
        lactate = lactate,
        age = age, # Also used in the renal assessment.
        map = dbp + (sbp - dbp)/3,
      # coagulation
        platelets = platelets,
        inr = inr,
        d_dimer = d_dimer,
        fibrinogen = fibrinogen,
      # neurologic
        gcs = gcs_total,
        fixed_pupils = as.integer(pupil == "both-fixed"),
      # endocrine
        glucose = glucose,
      # immunologic
        anc = anc,
        alc = alc,
      # renal
        creatinine = creatinine,
        # no need to specify age again
      # hepatic
        bilirubin = bilirubin,
        alt = alt,
      data = sepsis
    )

  str(phoenix8_scores)
  # 'data.frame':	20 obs. of  12 variables:
  #  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
  #  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
  #  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
  #  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
  #  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
  #  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
  #  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...
  #  $ phoenix_endocrine_score     : int  0 0 0 0 0 0 0 0 1 0 ...
  #  $ phoenix_immunologic_score   : int  0 1 1 1 0 1 0 1 1 1 ...
  #  $ phoenix_renal_score         : int  1 0 0 0 0 1 1 0 1 0 ...
  #  $ phoenix_hepatic_score       : int  0 0 1 1 0 0 1 0 1 0 ...
  #  $ phoenix8_sepsis_score       : int  4 8 8 3 0 9 11 2 12 5 ...





