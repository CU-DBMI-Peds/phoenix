

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
