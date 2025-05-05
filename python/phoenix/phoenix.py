import numpy as np
import pandas as pd

def map(sbp, dbp):
    """
    Mean Arterial Pressure

    Estimated mean arterial pressure is (2/3)*DBP + (1/3)*SBP

    Parameters:
        sbp : systolic blood pressure (mmHg)
        dbp : diastolic blood pressure (mmHg)

    Returns:
        a np.array
    """
    return(np.array(2/3 * dbp + 1/3 * sbp))

def phoenix_respiratory(pf_ratio = np.nan, sf_ratio = np.nan, imv = np.nan, other_respiratory_support = np.nan):
    """
    Phoenix Respiratory Scoring

    Parameters:
        pf_ratio : numeric vector for the PaO2/FiO2 ratio; PaO2 = arterial
                   oxygen pressure; FiO2 = fraction of inspired oxygen;  PaO2 is
                   measured in mmHg and FiO2 is from 0.21 (room air) to 1.00.

        sf_ratio : numeric vector for the SpO2/FiO2 ratio; SpO2 = oxygen
                   saturation, measured in a percent; ratio for 92% oxygen
                   saturation on room air is 92/0.21 = 438.0952.

        imv : invasive mechanical ventilation; numeric or integer vector, (0 =
              not intubated; 1 = intubated)

        other_respiratory_support : other respiratory support; numeric or
                                    integer vector, (0 = no support; 1 =
                                    support)
  
    Returns:
        A np.array of integer values
    """
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

def phoenix_cardiovascular(vasoactives = np.nan, lactate = np.nan, age = np.nan, map = np.nan):
    """
    Phoenix Cardiovascular Scoring

    Parameters:
        vasoactives : an integer vector, the number of systemic vasoactive
                      medications being administered to the patient.  Six
                      vasocative medications are considered: dobutamine,
                      dopamine, epinepherine, milrinone, norepinephrine,
                      vasopressin.

        lactate : numeric vector with the lactate value in mmol/L

        age : numeric vector age in months

        map : numeric vector, mean arterial pressure in mmHg

    Returns:
        A np.array of integer values
    """
    vas = np.nan_to_num(vasoactives, nan = 0)
    lct = np.nan_to_num(lactate, nan = 0)

    # for age and map, if one is missing set both values so a score of 0 is
    # returned.  use np.nan_to_num to copy the data before using [idx] to set al
    # the missing values
    age = np.nan_to_num(age, nan = 222)
    map = np.nan_to_num(map, nan = 100)

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

def phoenix_coagulation(platelets = np.nan, inr = np.nan, d_dimer = np.nan, fibrinogen = np.nan):
    """
    Phoenix Coagulation Scoring

    Parameters:
        platelets : numeric vector for platelets counts in units of 1,000/uL
                    (thousand per microliter)

        inr : numeric vector for the international normalised ratio blood test

        d_dimer : numeric vector for D-Dimer, units of mg/L FEU

        fibrinogen : numeric vector units of mg/dL

    Returns:
        A np.array of integer values
    """
    plt = np.nan_to_num(platelets, nan = 1000)
    inr = np.nan_to_num(inr, nan = 0)
    ddm = np.nan_to_num(d_dimer, nan = 0)
    fib = np.nan_to_num(fibrinogen, nan = 1000)
    rtn = (plt < 100).astype(int) +\
          (inr > 1.3).astype(int) +\
          (ddm > 2).astype(int) +\
          (fib < 100).astype(int)

    rtn = np.minimum(2, rtn)

    return(np.array(rtn))

def phoenix_neurologic(gcs = np.nan, fixed_pupils = np.nan):
    """
    Phoenix Neurologic Scoring

    Parameters:
        gcs : integer vector; total Glasgow Comma Score

        fixed_pupils : integer vector; 1 = bilaterally fixed pupil, 0 =
                       otherwise

    Returns:
        A np.array of integer values
    """
    gcs = np.nan_to_num(gcs, nan = 15)
    fpl = np.nan_to_num(fixed_pupils, nan = 0)
    rtn = (fpl * 2).astype(int) + (gcs <= 10).astype(int)

    rtn = np.minimum(2, rtn)

    return(np.array(rtn))

def phoenix_endocrine(glucose = np.nan):
    """
    Phoenix Endocrine Scoring

    Parameters:
        glucose : numeric vector; blood glucose measured in mg/dL

    Returns:
        A np.array of integer values
    """
    glc = np.nan_to_num(glucose, nan = 100)
    return( np.array(((glc < 50) | (glc > 150)).astype(int)))

def phoenix_immunologic(anc = np.nan, alc = np.nan):
    """
    Phoenix Immunolgic Scoring

    Parameters:
        anc : absolute neutrophil count; a numeric vector; units of 1,000 cells
              per cubic millimeter

        alc : absolute lymphocyte count; a numeric vector; units of 1,000 cells
              per cubic millimeter

    Returns:
        A np.array of integer values
    """
    anc = np.nan_to_num(anc, nan = 555)
    alc = np.nan_to_num(alc, nan = 1111)
    return(np.array(((anc < 0.500) | (alc < 1.000)).astype(int)))

def phoenix_renal(creatinine = np.nan, age = np.nan):
    """
    Phoenix Renal Scoring

    Parameters:
        creatinine : numeric vector; units of mg/dL

        age : numeric vector age in months

    Returns:
        A np.array of integer values
    """
    crt = np.nan_to_num(creatinine, nan = 0)
    age = np.nan_to_num(age, nan = 0)
    rtn = (
            ((age >=   0) & (age <    1)).astype(int) * (crt >= 0.8).astype(int) +
            ((age >=   1) & (age <   12)).astype(int) * (crt >= 0.3).astype(int) +
            ((age >=  12) & (age <   24)).astype(int) * (crt >= 0.4).astype(int) +
            ((age >=  24) & (age <   60)).astype(int) * (crt >= 0.6).astype(int) +
            ((age >=  60) & (age <  144)).astype(int) * (crt >= 0.7).astype(int) +
            ((age >= 144) & (age <= 216)).astype(int) * (crt >= 1.0).astype(int)
          )
    return(np.array(rtn))

def phoenix_hepatic(bilirubin = np.nan, alt = np.nan):
    """
    Phoenix Hepatic Scoring

    Parameters:
        bilirubin : numeric vector; units of mg/dL

        alt : alanine aminotransferase; a numeric vector; units of IU/L

    Returns:
        A np.array of integer values
    """
    bil = np.nan_to_num(bilirubin, nan = 0)
    alt = np.nan_to_num(alt, nan = 0)
    return( np.array(((bil >= 4) | (alt > 102)).astype(int)))

def phoenix(pf_ratio = np.nan, sf_ratio = np.nan, imv = np.nan, other_respiratory_support = np.nan, vasoactives = np.nan, lactate = np.nan, map = np.nan, platelets = np.nan, inr = np.nan, d_dimer = np.nan, fibrinogen = np.nan, gcs = np.nan, fixed_pupils = np.nan, age = np.nan):
    """
    Phoenix Sepsis Scoring

    Parameters:
        pf_ratio : numeric vector for the PaO2/FiO2 ratio; PaO2 = arterial
                   oxygen pressure; FiO2 = fraction of inspired oxygen;  PaO2 is
                   measured in mmHg and FiO2 is from 0.21 (room air) to 1.00.

        sf_ratio : numeric vector for the SpO2/FiO2 ratio; SpO2 = oxygen
                   saturation, measured in a percent; ratio for 92% oxygen
                   saturation on room air is 92/0.21 = 438.0952.

        imv : invasive mechanical ventilation; numeric or integer vector, (0 =
              not intubated; 1 = intubated)

        other_respiratory_support : other respiratory support; numeric or
                                    integer vector, (0 = no support; 1 =
                                    support)

        vasoactives : an integer vector, the number of systemic vasoactive
                      medications being administered to the patient.  Six
                      vasocative medications are considered: dobutamine,
                      dopamine, epinepherine, milrinone, norepinephrine,
                      vasopressin.

        lactate : numeric vector with the lactate value in mmol/L

        age : numeric vector age in months

        map : numeric vector, mean arterial pressure in mmHg

        platelets : numeric vector for platelets counts in units of 1,000/uL
                    (thousand per microliter)

        inr : numeric vector for the international normalised ratio blood test

        d_dimer : numeric vector for D-Dimer, units of mg/L FEU

        fibrinogen : numeric vector units of mg/dL

        gcs : integer vector; total Glasgow Comma Score

        fixed_pupils : integer vector; 1 = bilaterally fixed pupil, 0 =
                       otherwise

    Returns:
        A pandas DataFrame with columns for each of the respiratory,
        cardiovascular, coagulation, and neurologic
        scores, the Phoenix score (sum of respiratory, cardiovascular,
        coagulation, and neurologic), indicator for sepsis
        (Phoenix score of at least two points), and indicator for septic shock
        (spesis with at least one cardiovascular point).
    """
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

def phoenix8(pf_ratio = np.nan, sf_ratio = np.nan, imv = np.nan, other_respiratory_support = np.nan, vasoactives = np.nan, lactate = np.nan, map = np.nan, platelets = np.nan, inr = np.nan, d_dimer = np.nan, fibrinogen = np.nan, gcs = np.nan, fixed_pupils = np.nan, glucose = np.nan, anc = np.nan, alc = np.nan, creatinine = np.nan, bilirubin = np.nan, alt = np.nan, age = np.nan):
    """
    Phoenix-8 Scoring

    Parameters:
        pf_ratio : numeric vector for the PaO2/FiO2 ratio; PaO2 = arterial
                   oxygen pressure; FiO2 = fraction of inspired oxygen;  PaO2 is
                   measured in mmHg and FiO2 is from 0.21 (room air) to 1.00.

        sf_ratio : numeric vector for the SpO2/FiO2 ratio; SpO2 = oxygen
                   saturation, measured in a percent; ratio for 92% oxygen
                   saturation on room air is 92/0.21 = 438.0952.

        imv : invasive mechanical ventilation; numeric or integer vector, (0 =
              not intubated; 1 = intubated)

        other_respiratory_support : other respiratory support; numeric or
                                    integer vector, (0 = no support; 1 =
                                    support)

        vasoactives : an integer vector, the number of systemic vasoactive
                      medications being administered to the patient.  Six
                      vasocative medications are considered: dobutamine,
                      dopamine, epinepherine, milrinone, norepinephrine,
                      vasopressin.

        lactate : numeric vector with the lactate value in mmol/L

        age : numeric vector age in months

        map : numeric vector, mean arterial pressure in mmHg

        platelets : numeric vector for platelets counts in units of 1,000/uL
                    (thousand per microliter)

        inr : numeric vector for the international normalised ratio blood test

        d_dimer : numeric vector for D-Dimer, units of mg/L FEU

        fibrinogen : numeric vector units of mg/dL

        gcs : integer vector; total Glasgow Comma Score

        fixed_pupils : integer vector; 1 = bilaterally fixed pupil, 0 =
                       otherwise

        glucose : numeric vector; blood glucose measured in mg/dL

        anc : absolute neutrophil count; a numeric vector; units of 1,000 cells
              per cubic millimeter

        alc : absolute lymphocyte count; a numeric vector; units of 1,000 cells
              per cubic millimeter

        creatinine : numeric vector; units of mg/dL

        bilirubin : numeric vector; units of mg/dL

        alt : alanine aminotransferase; a numeric vector; units of IU/L

    Returns:
        A pandas DataFrame with columns for each of the eight organ dysfunction
        scores, the Phoenix score (sum of respiratory, cardiovascular,
        coagulation, and neurologic), the Phoenix-8 score, indicator for sepsis
        (Phoenix score of at least two points), and indicator for septic shock
        (spesis with at least one cardiovascular point).
    """
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
