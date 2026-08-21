# Phoenix Sepsis EHR Implementation Notes

The Phoenix criteria for pediatric sepsis and septic shock were
developed using an international data set of pediatric emergency
department and hospital encounters by predicting encounter mortality
among those with suspected infection using organ dysfunction-based data
from the first 24 hours of the encounter. Please see the original
manuscripts for details. (Sanchez-Pinto et al. 2024; Schlapbach et al.
2024).

The purpose of this document is to provide details about the expected
inputs for the scoring in order to assist EHR implementation. The
phoenix R package and Python module, along with the example SQL code
assumes that the data have been prepared as expected and returns scores
accordingly.

------------------------------------------------------------------------

## Overview

Here is a quick checklist to summarize how the Phoenix package should be
integrated within an EHR. This is to aid understanding and verification;
users still need to review all guidance from this full document.

### Scoring Requirement

- Phoenix score is only valid in the case of suspected infection

### Exclusion Criteria

- Patients still in their original birth hospitalization
- Gestational age less than 37 weeks at encounter start
- Age greater than or equal to 18 years (216 months) at encounter start

### Data cleaning and preparation

- Verify all variables in expected unit; convert as necessary. E.g. age
  in months; lactate in mmol/L, etc.
- As appropriate replace invalid values with NULL; e.g. if age in months
  \> 216 need to consider if should be scoring patient at all.
- No imputation for NULL/invalid values
- Last observation carry forward within appropriate window for each
  variable - max carry forward is from prior 24 hours.
- Variables not present or not known should be passed in as NULL

### Gotchas

- Phoenix package doesn’t calculate mean arterial pressure (MAP);
  Calculate MAP from SBP and DBP if not directly available; if both cuff
  and arterial values present, arterial MAP should be used.
- Carefully review requirements of each input value. For example, only
  calculate SF ratio and pass into Phoenix package when SpO2 \<= 97;
  only calculate and pass in PF ratio when FiO2 value is from the same
  time as or before the time of PaO2 lab.
- Use last known good value to when calling Phoenix functions.

------------------------------------------------------------------------

## General Data Formatting Notes

- `NULL` values are treated as non-score generating criteria. Do not
  populate null/unknown/not applicable values with estimates or outdated
  information.
- Values outside the ranges mentioned below are treated as `NULL`
- Before sending data to the package, please verify the data. Some
  values may provide warnings, others may generate errors. Verify that
  your code can handle warnings and errors.
- Ideally, both input values and time of the measurement are available
  so that last observation carried forward logic can be implemented with
  limits and conditions for age of inputs.

### Special Considerations for EHR Data

Phoenix was developed on a retrospective data set which provided the
luxury of easily looking backwards in the time within an encounter. When
applying the Phoenix criteria to an active encounter there are several
things to consider.

#### Missing values

Missing values at a specific moment in time need to be dealt with in two
steps:

1.  Is there a prior known value? If so, and the prior known value is
    within the lookback window, use the last known value. That is,
    last-observation-carried-forward with a lookback window.

2.  Consider the missing value to indicate a “healthy” value. If using
    the R package or the Python module you need not do anything as the
    functions therein will return zero points in the score for the
    missing value.

Example: Say we know FiO₂ at time T₀ and we know lactate at time T₀ as
well.

| time | FiO₂ | Lactate |
|:----:|:-----|:--------|
|  T₀  | 0.40 | 6.8     |

Later, at times T₂ \> T₁ \> T₀ the lactate value is updated. As such we
might see data like this:

| time | FiO₂ | Lactate |
|:----:|:-----|:--------|
|  T₀  | 0.40 | 6.8     |
|  T₁  |      | 7.3     |
|  T₂  |      | 7.1     |

It is important that when calculating the Phoenix score that the missing
value for FiO₂ at time T₁ is handled correctly: The last known value
within the lookback window needs to be used. That is: the data would
look like:

| time | FiO₂                                               | Lactate |
|:----:|:---------------------------------------------------|:--------|
|  T₀  | 0.40                                               | 6.8     |
|  T₁  | 0.40 (Assuming T₁ - T₀ \< 6 hours; NULL Otherwise) | 7.3     |
|  T₂  | 0.40 (Assuming T₂ - T₀ \< 6 hours; NULL Otherwise) | 7.1     |

If at time T₃ FiO₂ is updated:

| time | FiO₂ | Lactate |
|:--:|:---|:---|
| T₀ | 0.40 | 6.8 |
| T₁ | 0.40 (Assuming T₁ - T₀ \< 6 hours; NULL Otherwise) | 7.3 |
| T₂ | 0.40 (Assuming T₂ - T₀ \< 6 hours; NULL Otherwise) | 7.1 |
| T₃ | 0.80 (good new value) | 7.1 (Assuming T₃ - T₂ \< 6 hours; NULL Otherwise) |

------------------------------------------------------------------------

## Inclusion/Exclusion criteria for the Phoenix criteria development study

Inclusion Criteria

- Child \< 18 years old
- Suspected infection

Exclusion Criteria

- Patients still in their original birth hospitalization
- Gestational age less than 37 weeks at encounter start
- Age greater than or equal to 18 years (216 months) at encounter start

## Suspected Infection

For a patient to have sepsis or septic shock based on the Phoenix
criteria, they must have a suspected infection. A patient is considered
to have a suspected infection if they have:

1.  a test for infection *ordered*, and
2.  at least two doses of systemic antimicrobial medication(s).

Note that the test, e.g., a blood culture, need only be ordered.
Positive/negative test status is not needed.

Systemic antimicrobial medications are any antibiotic, antiviral, or
antifungal medication by any of the following routes:

- ASSUMED SYSTEMIC
- ENTERAL
- HEMODIALYSIS
- INTRA-ARTERIAL
- INTRACARDIAC
- INTRADUODENAL
- INTRAGASTRIC
- INTRAILEAL
- INTRAMUSCULAR
- INTRAVASCULAR
- INTRAVENOUS
- INTRAVENOUS BOLUS
- INTRAVENOUS DRIP
- NASOGASTRIC
- ORAL
- OROPHARYNGEAL
- PARENTERAL
- RECTAL
- SUBCUTANEOUS

Other non-systemic routes such as intraocular, nasal, otic, etc. should
be excluded.

Example SQL code used for mapping medication routes when developing
Phoenix can be found in the project [GitHub
archive](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria/tree/main/harmonization/medication_mappings)
specifically the files:
[med_route_mapping.sql](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria/blob/main/harmonization/medication_mappings/med_route_mapping.sql)
and
[clean_up_routes.sql](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria/blob/main/harmonization/medication_mappings/clean_up_routes.sql).

------------------------------------------------------------------------

## General notes for all subscores

Reasonable values for observations and labs used during development of
the Phoenix Sepsis Score are documented in file
[standard_names_and_units.csv](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria/blob/main/harmonization/standard_names_and_units.csv)
within the project [GitHub
archive](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria).

“Look Back” for each input below indicates the length of time a last
value should be carried forward.

## Respiratory

Respiratory dysfunction scoring is based on PaO₂/FiO₂ (PFR), SpO₂/FiO₂
(SFR), and respiratory support. While the scoring is based on SFR and
PFR, it is preferable to use separate SpO₂, PaO₂, and FiO₂ values so
data checks can be performed before the score is determined.

### Inputs

#### PaO₂: Partial pressure of oxygen in arterial blood

- Units: mmHg
- Expected Values: \[0, Inf)
- Caveats:
- Look Back: 6 hours

#### SpO₂: Peripheral oxygen saturation (pulse ox)

- Units: percentage
- Expected Values: \[0, 100\]
  - Expect integer values 0, 1, 2, …, 100
- Caveats: values greater than 97 should *not* be used for SFR
- Look back: 6 hours

#### FiO₂: Percent inspired oxygen

- Units: not applicable
- Expected Values: \[0.21, 1.00\]
  - expected floating point
  - 0.21 is room air
  - 1.00 is pure oxygen
- Caveats:
- Look back: 6 hours

#### PFR: PaO₂/FiO₂

- Units: mmHg
- Expected Values \[0, Inf)
  - Expect floating point
- Caveats:
  - PFR is only valid if the time of FiO₂ value is the same as, or
    before, the time of PaO₂ value. For example, if FiO₂ was reported at
    11:31 and PaO₂ was reported at 11:45 then the PFR would be valid to
    use. If the FiO₂ is then updated at 11:59, the PaO₂ value from 11:45
    would not be valid to use in the calculation of the PFR

    | time | FiO₂ | PaO₂ | PFR | Note: |
    |---:|---:|---:|---:|---:|
    | 11:31 | 0.30\* |  |  |  |
    | 11:45 | 0.30^(c) | 118\* | 393.33 |  |
    | 11:47 | 0.30^(c) | 118^(c) | 393.33 |  |
    | 11:59 | 0.40\* | 118^(c) |  | No PFR, FiO₂ is newer than PaO₂ |
    | 12:10 | 0.40^(c) | 152\* | 380 |  |
    | 12:15 | 0.40^(c) | 152^(c) | 380 |  |
    | 17:45 | 0.40^(c) | 152^(c) | 380 |  |
    | 18:00 |  | 152^(c) |  | No PFR, FiO₂ carry forward window expired |
    | 18:30 |  |  |  | No PFR, FiO₂ and PaO₂ carry forward windows have expired |

    \* New value  
    ^(c) value carried forward {.table}
- Look back: implied by the look back on PaO₂ and FiO₂ and the condition
  that FiO₂ value is the same age or older than the PaO₂ value.

#### SFR: SpO₂ / FiO₂

- Units: none
- Expected Values: \[0, 97/0.21\]
  - Floating point
  - The upper limit includes the limitation on SpO₂ ≤ 97
- Caveats:
  - SFR is only valid if the time of FiO₂ value is the same as, or
    before, the time of SpO₂ value. For example, if FiO₂ was reported at
    11:31 and SpO₂ was reported at 11:45 then the SFR would be valid to
    use. If the FiO₂ is then updated at 11:59, the SpO₂ value from 11:45
    would not be valid to use in the calculation of the SFR

    | time | FiO₂ | SpO₂ | SFR | Note: |
    |---:|---:|---:|---:|---:|
    | 10:15 | 0.25\* | 92\* | 368 |  |
    | 10:20 | 0.25^(c) | 98\* |  | No SFR, SpO₂ \> 97 |
    | 11:31 | 0.30\* | 98^(c) |  | No SFR, SpO₂ \> 97 and FiO₂ newer than SpO₂ |
    | 11:45 | 0.30^(c) | 87\* | 290 |  |
    | 11:47 | 0.30^(c) | 87^(c) | 290 |  |
    | 11:59 | 0.40\* | 87^(c) |  | No SFR, FiO₂ is newer than SpO₂ |
    | 12:10 | 0.40^(c) | 85\* | 212.5 |  |
    | 12:15 | 0.40^(c) | 85^(c) | 212.5 |  |
    | 17:45 | 0.40^(c) | 85^(c) | 212.5 |  |
    | 18:00 |  | 85^(c) |  | No SFR, FiO₂ carry forward window expired |
    | 18:30 |  |  |  | No SFR, FiO₂ and SpO₂ carry forward windows have expired |

    \* New value  
    ^(c) value carried forward {.table}
- Look back: implied by the look back on SpO₂ and FiO₂ and the condition
  that FiO₂ value is the same age or older than the SpO₂ value.

#### ORS: Other Respiratory Support

- Units: not applicable
- Expected Values:
  - 0: No other respiratory support
  - 1: some form of respiratory support; may or may not include
    supplemental oxygen
- Caveats:
  - If FiO₂ \> 0.21 then that indicates oxygen support and thus ORS
- Look Back: 6 hours
  - If it has been more than six hours since last known data point
    indicating the patient has respiratory support then consider the
    patient to no longer have respiratory support.

#### IMV: Invasive Mechanical ventilation

- Units: not applicable
- Expected Values:
  - 0: patient does not currently have invasive mechanical ventilation
  - 1: patient currently has invasive mechanical ventilation
- Caveats:
  - IMV due to surgery should not be used to assess organ dysfunction
- Look back: 6 hours
  - If it has been more than 6 hours since the last known data point
    indicating the patient has IMV, then consider the patient to no
    longer have IMV

### Scoring

Scoring is based on the lowest available PaO₂/FiO₂ (PFR) and SpO₂/FiO₂
(SFR) with consideration for IMV and ORS.

``` r

# R code: booleans are implicitly coerced to integers
cat(tail(as.character(body(phoenix::phoenix_respiratory)), 1), sep = "\n")
#> imv * (((pfr < 100) | (sfr < 148)) + ((pfr < 200) | (sfr < 220))) + ors * ((pfr < 400) | (sfr < 292))
```

------------------------------------------------------------------------

## Cardiovascular

Cardiovascular dysfunction is based on three types of data:

1.  Systemic Vasoactive medications
2.  Lactate
3.  Age adjusted mean arterial pressure

### Inputs

#### Systemic Vasoactive Medications

There are six systemic vasoactive medications to consider:

1.  dobutamine
2.  dopamine
3.  epinephrine
4.  norepinephrine
5.  milrinone
6.  vasopressin

Vasoactive medications (dobutamine, dopamine, etc.) should only count if
they are continuous and systemic. Ideally, one would identify flowsheet
or medication rows where the dose (rate) is documented at least every
hour for each infusion. In our dataset, epinephrine had some
non-systemic medication administrations that needed to be excluded. Here
are some *non-systemic* examples to exclude:

- epinephrine 0.3 mg/0.3ml inj soln prefilled syringe
- epinephrine hcl (nasal) 0.1 % nasal solution
- epinephrine hcl 2.25 % inh neb soln

Example SQL code used for mapping administration routes when developing
Phoenix can be found in the project [GitHub
archive](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria/tree/main/harmonization/medication_mappings)
specifically the files:
[med_route_mapping.sql](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria/blob/main/harmonization/medication_mappings/med_route_mapping.sql)
and
[clean_up_routes.sql](https://github.com/CU-DBMI-Peds/phoenix_sepsis_criteria/blob/main/harmonization/medication_mappings/clean_up_routes.sql).

The overall metadata for vasoactives:

- Units: none
- Expected Values: integer values 0, 1, 2, 3, 4, 5, 6
  - (maximum vasoactive points is reached with 2)
- Caveats: see above
- Look back: 12 hours

#### Lactate

- Units: mmol/L
- Expected Values: \[0, 50\]
- Caveats:
- Look back: 6 hours

#### Age

- Units: Months
- Expected Values: \[0, 216)
- Caveats:
- Look back:

#### Mean Arterial Pressure (MAP)

There can be many sources of blood pressure. We used the following
hierarchy for which value to use in the scoring.

1.  Arterial MAP (invasive measurement)
2.  Estimated MAP from arterial systolic (SBP) and arterial diastolic
    (DBP) pressures
3.  Cuff MAP
4.  Estimated MAP from cuff SBP and cuff DBP

MAP can be estimated as `(2/3) * DBP + (1/3) * SBP`

Expected metadata:

- MAP:
  - Units: mmHg
  - Expected Values: \[1, 300\]
  - Caveats:
    - If MAP is provided along with SBP and DBP then verify that DBP ≤
      MAP ≤ SBP
  - Look back: 6 hours
- SBP:
  - Units: mmHg
  - Expected Values: \[1, 300\]
  - Caveats:
    - Verify that DBP ≤ SBP, we used a slightly more conservative check
      of (SBP - DBP) ≥ 1
  - Look back: 6 hours
- DBP:
  - Units: mmHg
  - Expected Values: \[1, 200\]
  - Caveats:
    - Verify that DBP ≤ SBP, we used a slightly more conservative check
      of (SBP - DBP) ≥ 1
  - Look back: 6 hours

**Step-By-Step Instructions:** NOTE: these instructions are intended for
prospective or real-time assessments and extends the logic from the
retrospective data analysis used to develop the Phoenix criteria.

1.  Pick the score time. Example: \`\`We are scoring the patient at
    10:15.’’
2.  Look back only as far as the blood-pressure look-back window allows.
    For published Phoenix, this is 6 hours.
3.  Define 4 candidate estimators:
    1.  Define Candidate 1.
        1.  Find the most recent arterial-line MAP within that window.
        2.  If one exists this is Candidate 1; otherwise Candidate 1 is
            missing.
    2.  Define Candidate 2.
        1.  Find the most recent arterial-line SBP and arterial-line DBP
            within that window.
        2.  Only use arterial SBP and DBP to calculate MAP if they were
            recorded close enough together (*within 10 minutes of each
            other*). If they are too far apart in time, do not use them
            together.
        3.  If arterial SBP and DBP can be used together, calculate: MAP
            = one third SBP + two thirds DBP. Call this Candidate 2.
    3.  Define Candidate 3.
        1.  Find the most recent cuff MAP within the window.
        2.  If one exists this is Candidate 3; otherwise Candidate 3 is
            missing.
    4.  Define Candidate 4.
        1.  Find the most recent cuff SBP and cuff DBP within the
            window.
        2.  Only use cuff SBP and DBP to calculate MAP if they were
            recorded close enough together (*within 10 minutes of each
            other*). If they are too far apart in time, do not use them
            together.
        3.  If cuff SBP and DBP can be used together, calculate: MAP =
            one third SBP + two thirds DBP. Call this Candidate 4.
4.  For each candidate, figure out how old it is at the score time.
    1.  Ignore any candidate that does not exist.
    2.  Choose the candidate that is newest.
        1.  Candidate 1 and Candidate 3 have the same age as the
            reported value
        2.  Candidate 2 and 4: these are as old as the youngest
            component. Example: SBP most recent reported value at 10:08;
            DBP last reported value at 10:03. Then the Candidate will be
            considered to have reported time of 10:08.
5.  If two candidates are equally new (*within one minute*), use this
    tie-breaker order:
    1.  Arterial-line MAP measured directly: Candidate 1.
    2.  Arterial-line MAP calculated from arterial SBP and DBP:
        Candidate 2.
    3.  Cuff MAP measured directly: Candidate 3.
    4.  Cuff MAP calculated from cuff SBP and DBP: Candidate 4.
6.  Use the Candidate selected in step 5 to assess the Phoenix score. If
    there are no usable candidates, then MAP is missing and gives 0 MAP
    points.

Simple Rule To Remember: Use the newest usable MAP. If there is a tie,
prefer arterial over cuff, and prefer directly measured MAP over
calculated MAP.

**Example:** The candidate columns have the MAP value and the (value
age: how old is the value, in minutes).

| Time | Arterial MAP | Cuff SBP | Cuff DBP | Candidate 1: (age) | Candidate 4: (age) | Selected Candidate | Note |
|---:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 10:00 |  |  |  |  |  |  |  |
| 10:01 | 55 |  |  | 55 (0) |  | 1 | 1\. |
| 10:02 | 56 |  |  | 56 (0) |  | 1 | 1\. |
| 10:03 | 58 |  |  | 58 (0) |  | 1 | 1\. |
| 10:04 |  | 63 | 47 | 58 (1) | 52.33 (0) | 1 | 2\. |
| 10:05 |  |  |  | 58 (2) | 52.33 (1) | 1 | 2\. |
| 10:06 |  |  |  | 58 (3) | 52.33 (2) | 1 | 2\. |
| 10:07 |  | 64 | 46 | 58 (4) | 52 (0) | 4 | 3\. |
| 10:08 | 57 |  |  | 57 (0) | 52 (1) | 1 | 4\. |
| 10:09 |  |  |  | 57 (1) | 52 (2) | 1 | 4\. |
| 10:10 |  |  |  | 57 (2) | 52 (3) | 1 | 4\. |
| 10:11 |  | 63 |  | 57 (3) | 51.67 (0) | 4 | 5\. |
| 10:12 |  |  |  | 57 (4) | 51.67 (1) | 4 | 5\. |
| 10:13 |  |  |  | 57 (5) | 51.67 (2) | 4 | 5\. |
| 10:14 |  |  |  | 57 (6) | 51.67 (3) | 4 | 5\. |
| 10:15 |  |  |  | 57 (7) | 51.67 (4) | 4 | 5\. |
| 10:16 |  |  |  | 57 (8) | 51.67 (5) | 4 | 5\. |
| 10:17 |  |  |  | 57 (9) | 51.67 (6) | 4 | 5\. |
| 10:18 |  |  |  | 57 (10) | 51.67 (7) | 4 | 5\. |
| 10:19 |  | 62 |  | 57 (11) | —- | 1 | 6\. |

Notes:

1.  The arterial MAP is the selected candidate because it is the only
    candidate and is aged zero minutes, well within in the look back
    window of six hours.
2.  The selected candidate for use in the Phoenix scoring is Candidate
    1, arterial MAP. Although Candidate 4, the MAP approximated by cuff
    SBP and DBP, is younger, it is only younger by one minute. The age
    of measurement difference being only one minute, the two candidates
    are conceptually considered to be the same age and thus the
    Candidate 1, the arterial MAP is used when assessing Phoenix.
3.  Candidate 4 is used here because the approximated MAP from cuff SBP
    and DBP is zero minutes old verse the four minute old arterial MAP.
4.  Candidate 1 is used because it is the youngest and the preferable
    data source.
5.  SBP was updated, DBP was not. The approximate MAP based on cuff
    values can use the older DBP because it is within 10 minutes of the
    current SBP value. The approximate MAP gets the same age as the
    youngest input, here the SBP. This results in the cuff MAP being the
    youngest value by more than one minute and thus is the candidate
    used in the Phoenix assessment.
6.  SBP was updated, DBP was not. Because the SBP and DBP values are
    more than 10 minutes apart the estimated MAP is not to be used. As
    such, Candidate 1, the arterial MAP is used based on data source
    preference and it is within the look back window.

### Scoring

Up to six points can be earned from cardiovascular dysfunction. Up to
two points for vasoactives, up to two points for lactate, and up to two
points for MAP.

``` r

# vas: number of vasoactive meds
# lct: lactate in mmol/L
# age: age in months
# map: mean arterial pressure in mmHg
cat(tail(as.character(body(phoenix::phoenix_cardiovascular)), 4), sep = "\n")
#> vas_score <- (vas > 1) + (vas > 0)
#> lct_score <- (lct >= 11) + (lct >= 5)
#> map_score <- ((age >= 0 & age < 1) * ((map < 17) + (map < 31)) + (age >= 1 & age < 12) * ((map < 25) + (map < 39)) + (age >= 12 & age < 24) * ((map < 31) + (map < 44)) + (age >= 24 & age < 60) * ((map < 32) + (map < 45)) + (age >= 60 & age < 144) * ((map < 36) + (map < 49)) + (age >= 144 & age <= 216) * ((map < 38) + (map < 52)))
#> vas_score + lct_score + map_score
```

------------------------------------------------------------------------

## Coagulation

### Inputs

#### Platelets

- Units: 1000/μL
- Expected Values: \[0, Inf)
- Caveats:
- Look back: 24 hours

#### INR

- Units: none
- Expected Values: \[0, Inf)
- Caveats:
- Look back: 24 hours

#### D-dimer

- Units: mg/L FEU
- Expected Values: \[0, 500\]
- Caveats:
- Look back: 24 hours

#### Fibrinogen

- Units: mg/dL
- Expected Values: \[0, Inf)
- Caveats:
- Look back: 24 hours

### Scoring

While there are four inputs and a patient could get a point for each
one, the final score is capped at two points.

``` r

cat(tail(as.character(body(phoenix::phoenix_coagulation)), 2), sep = "\n")
#> rtn <- as.integer(plt < 100) + as.integer(inr > 1.3) + as.integer(ddm > 2) + as.integer(fib < 100)
#> pmin(rtn, 2)
```

------------------------------------------------------------------------

## Neurologic

### Inputs

#### Glasgow Coma Scale (GCS)

Phoenix is based on the total GCS score.

- GCS (total):
  - Units: none
  - Expected Values: integer values 3, 4, 5, …, 15
  - Caveats:
    - The total GCS is the sum of three component scores: eye, motor,
      and verbal.
    - We assumed that if we had an updated score for any one of the
      three components but not all, then the non-updated components were
      assumed to have not changed. In that case, we updated the time of
      the GCS total and all its components to the most recent update
      time for any of the components.
  - Look back: 12 hours
- GCS (eye):
  - Units: none
  - Expected Values: integer values 1, 2, 3, 4
  - Caveats:
  - Look back: 12 hours
- GCS (motor):
  - Units: none
  - Expected Values: integer values 1, 2, 3, 4, 5, 6
  - Caveats:
  - Look back: 12 hours
- GCS (verbal):
  - Units: none
  - Expected Values: integer values 1, 2, 3, 4, 5
  - Caveats: We did not use the T value for intubation - just use the
    recorded GCS-V, i.e. 1 for 1T
  - Look back: 12 hours

#### Pupils

- Units: none
- Expected Values:
  - 1: bilaterally fixed pupils
  - 0: one or zero fixed pupils
- Caveats:
- Look back: 6 hours

### Scoring

- At most 2 points.
- 1 point for GCS ≤ 10
- 2 points for bilaterally fixed pupils

A patient with a GCS ≤ 10 and bilaterally fixed pupils will have a score
of 2.

``` r

# fpl: 1 if bilaterally fixed pupils; 0 otherwise
cat(tail(as.character(body(phoenix::phoenix_neurologic)), 1), sep = "\n")
#> pmin(fpl * 2 + as.integer(gcs <= 10), 2)
```

------------------------------------------------------------------------

## Additional inputs to Phoenix-8 score

## Endocrine

### Inputs

#### Glucose

- Units: mg/dL
- Expected Values: \[5, 2000\]
  - floating point
- Caveats:
- Look back: 12 hours

### Scoring

Scoring for Phoenix-8 only. 1 point if glucose \< 50 or \> 150

``` r

cat(tail(as.character(body(phoenix::phoenix_endocrine)), 1), sep = "\n")
#> as.integer((glc < 50) | (glc > 150))
```

## Immunologic

### Inputs

#### ANC

- Units: 1000 cells / mm³
- Expected Values: \[0, Inf)
- Caveats:
  - Be careful with the units. The R package, Python module, and example
    SQL code expect units in 1000 cells / mm³. Tables and other
    references might use cells / mm³
- Look back: 24 hours

#### ALC

- Units: 1000 cells / mm³
- Expected Values: \[0, Inf)
- Caveats:
  - Be careful with the units. The R package, Python module, and example
    SQL code expect units in 1000 cells / mm³. Tables and other
    references might use cells / mm³
- Look back: 24 hours

### Scoring

At most one point

``` r

cat(tail(as.character(body(phoenix::phoenix_immunologic)), 1), sep = "\n")
#> as.integer((anc < 0.5) | (alc < 1))
```

------------------------------------------------------------------------

## Renal

### Inputs

#### Age (see notes in cardiovascular)

#### Creatinine

- Units: mg/dL
- Expected Values: \[0, 50\]
- Caveats:
- Look back: 24 hours

### Scoring

Age-adjusted creatinine

``` r

cat(tail(as.character(body(phoenix::phoenix_renal)), 1), sep = "\n")
#> (age >= 0 & age < 1) * (crt >= 0.8) + (age >= 1 & age < 12) * (crt >= 0.3) + (age >= 12 & age < 24) * (crt >= 0.4) + (age >= 24 & age < 60) * (crt >= 0.6) + (age >= 60 & age < 144) * (crt >= 0.7) + (age >= 144 & age <= 216) * (crt >= 1)
```

------------------------------------------------------------------------

## Hepatic

### Inputs

#### Total Bilirubin

- Units: mg/dL
- Expected Values: \[0, 100\]
  - floating point
- Caveats:
- Look back: 24 hours

#### ALT

- Units: IU/L
- Expected Values: \[0, Inf)
- Caveats:
- Look back: 24 hours

### Scoring

0 or 1 points

``` r

cat(tail(as.character(body(phoenix::phoenix_hepatic)), 1), sep = "\n")
#> as.integer((bil >= 4) | (alt > 102))
```

------------------------------------------------------------------------

## References

Sanchez-Pinto, L. Nelson, Tellen D. Bennett, Peter E. DeWitt, et al.
2024. “Development and Validation of the Phoenix Criteria for Pediatric
Sepsis and Septic Shock.” *JAMA*, ahead of print, January.
<https://doi.org/10.1001/jama.2024.0196>.

Schlapbach, Luregn J., R. Scott Watson, Lauren R. Sorce, et al. 2024.
“International Consensus Criteria for Pediatric Sepsis and Septic
Shock.” *JAMA*, ahead of print, January.
<https://doi.org/10.1001/jama.2024.0179>.
