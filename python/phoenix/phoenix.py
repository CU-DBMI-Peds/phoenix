import numpy as np
import pandas as pd

def phoenix_respiratory(pf_ratio, sf_ratio, imv, other_respiratory_support):
    pfr = np.nan_to_num(pf_ratio, nan = 500)
    sfr = np.nan_to_num(sf_ratio, nan = 500)
    imv = np.nan_to_num(imv,      nan = 0)
    ors = np.nan_to_num(other_respiratory_support, nan = 0)

    ors = ((imv == 1) | (other_respiratory_support == 1)).astype(int)

    rtn = imv.astype(int) * (
            ((pfr < 100) | (sfr < 148)).astype(int) +\
            ((pfr < 200) | (sfr < 220)).astype(int)
          ) + (
          ors.astype(int) * (((pfr < 400) | (sfr < 292)).astype(int))
          )

    return(np.array(rtn))

def phoenix_cardiovascular(vasoactives, lactate, age, map):
    vas = np.nan_to_num(vasoactives, nan = 0)
    lct = np.nan_to_num(lactate, nan = 0)

    # for age and map, if one is missing set both values so a score of 0 is
    # returned.  use np.nan_to_num to copy the data before using [idx] to set al
    # the missing values
    idx = np.isnan(age) | np.isnan(map)
    age = np.nan_to_num(age, nan = 222)
    map = np.nan_to_num(map, nan = 100)
    age[idx] = 222
    map[idx] = 100

    vas_score = (vas > 1).astype(int) + (vas > 0).astype(int)
    lct_score = (lct >= 11).astype(int) + (lct >= 5).astype(int)
    map_score = (
      ((age >=   0) & (age <    1)).astype(int) * ((map < 17).astype(int) + (map < 31).astype(int)) +
      ((age >=   1) & (age <   12)).astype(int) * ((map < 25).astype(int) + (map < 39).astype(int)) +
      ((age >=  12) & (age <   24)).astype(int) * ((map < 31).astype(int) + (map < 44).astype(int)) +
      ((age >=  24) & (age <   60)).astype(int) * ((map < 32).astype(int) + (map < 45).astype(int)) +
      ((age >=  60) & (age <  144)).astype(int) * ((map < 36).astype(int) + (map < 49).astype(int)) +
      ((age >= 144) & (age <= 216)).astype(int) * ((map < 38).astype(int) + (map < 52).astype(int))
    )

    return(np.array(vas_score + lct_score + map_score))

def phoenix_coagulation(platelets, inr, d_dimer, fibrinogen):
    plt = np.nan_to_num(platelets, nan = 1000)
    inr = np.nan_to_num(inr, nan = 0)
    ddm = np.nan_to_num(d_dimer, nan = 0)
    fib = np.nan_to_num(fibrinogen, nan = 1000)
    rtn = (plt < 100).astype(int) +\
          (inr > 1.3).astype(int) +\
          (ddm > 2).astype(int) +\
          (fib < 100).astype(int)
    rtn[(rtn > 2)] = 2
    return(np.array(rtn))

def phoenix_neurologic(gcs, fixed_pupils):
    gcs = np.nan_to_num(gcs, nan = 15)
    fpl = np.nan_to_num(fixed_pupils, nan = 0)
    rtn = (fpl * 2).astype(int) + (gcs <= 10).astype(int)
    rtn[(rtn > 2)] = 2

    return(np.array(rtn))

def phoenix_endocrine(glucose):
    glc = np.nan_to_num(glucose, nan = 100)
    return( np.array(((glc < 50) | (glc > 150)).astype(int)))

def phoenix_immunologic(anc, alc):
    anc = np.nan_to_num(anc, nan = 555)
    alc = np.nan_to_num(alc, nan = 1111)
    return(np.array(((anc < 500) | (alc < 1000)).astype(int)))

def phoenix_renal(creatinine, age):
    # set both creatinine and age to 0 if either is missing
    idx = np.isnan(creatinine) | np.isnan(age)
    crt = np.nan_to_num(creatinine, nan = 0)
    age = np.nan_to_num(age, nan = 0)
    crt[idx] = 0
    age[idx] = 0
    rtn = (
            ((age >=   0) & (age <    1)).astype(int) * (crt >= 0.8).astype(int) +
            ((age >=   1) & (age <   12)).astype(int) * (crt >= 0.3).astype(int) +
            ((age >=  12) & (age <   24)).astype(int) * (crt >= 0.4).astype(int) +
            ((age >=  24) & (age <   60)).astype(int) * (crt >= 0.6).astype(int) +
            ((age >=  60) & (age <  144)).astype(int) * (crt >= 0.7).astype(int) +
            ((age >= 144) & (age <= 216)).astype(int) * (crt >= 1.0).astype(int)
          )
    return(np.array(rtn))

def phoenix_hepatic(bilirubin, alt):
    bil = np.nan_to_num(bilirubin, nan = 0)
    alt = np.nan_to_num(alt, nan = 0)
    return( np.array(((bil >= 4) | (alt > 102)).astype(int)))

def phoenix(pf_ratio, sf_ratio, imv, other_respiratory_support, vasoactives, lactate, map, platelets, inr, d_dimer, fibrinogen, gcs, fixed_pupils, age):
    resp = phoenix_respiratory(pf_ratio, sf_ratio, imv, other_respiratory_support)
    card = phoenix_cardiovascular(vasoactives, lactate, age, map)
    coag = phoenix_coagulation(platelets, inr, d_dimer, fibrinogen)
    neur = phoenix_neurologic(gcs, fixed_pupils)
    total = resp + card + coag + neur
    sepsis = (total > 1).astype(int)
    septic_shock = ((total > 1) & (card > 0)).astype(int)
    rtn = pd.DataFrame(data = np.column_stack((resp, card, coag, neur, total, sepsis, septic_shock)))
    rtn.columns = ["phoenix_respiratory_score", "phoenix_cardiovascular_score", "phoenix_coagulation_score", "phoenix_neurologic_score", "phoenix_sepsis_score", "phoenix_sepsis", "phoenix_septic_shock"]
    return(rtn)

def phoenix8(pf_ratio, sf_ratio, imv, other_respiratory_support, vasoactives, lactate, map, platelets, inr, d_dimer, fibrinogen, gcs, fixed_pupils, glucose, anc, alc, creatinine, bilirubin, alt, age):
    resp = phoenix_respiratory(pf_ratio, sf_ratio, imv, other_respiratory_support)
    card = phoenix_cardiovascular(vasoactives, lactate, age, map)
    coag = phoenix_coagulation(platelets, inr, d_dimer, fibrinogen)
    neur = phoenix_neurologic(gcs, fixed_pupils)
    total = resp + card + coag + neur
    sepsis = (total > 1).astype(int)
    septic_shock = ((total > 1) & (card > 0)).astype(int)
    endo = phoenix_endocrine(glucose)
    immu = phoenix_immunologic(anc, alc)
    renal = phoenix_renal(creatinine, age)
    hepatic = phoenix_hepatic(bilirubin, alt)
    total8 = total + endo + immu + renal + hepatic
    rtn = pd.DataFrame(data = np.column_stack((resp, card, coag, neur, total, sepsis, septic_shock, endo, immu, renal, hepatic, total8)))
    rtn.columns = ["phoenix_respiratory_score", "phoenix_cardiovascular_score", "phoenix_coagulation_score", "phoenix_neurologic_score", "phoenix_sepsis_score", "phoenix_sepsis", "phoenix_septic_shock", "phoenix_endocrine_score", "phoenix_immunologic_score", "phoenix_renal_score", "phoenix_hepatic_score", "phoenix8_score"]
    return(rtn)


################################################################################
#                                 End of file                                  #
################################################################################
