<!-- README.md is generated from README.Rmd. Please edit that file -->

# phoenix: Phoenix Sepsis and Phoenix-8 Sepsis Criteria

Implementation of the Phoenix and Phoenix-8 Sepsis Criteria as
described in:

* ["Development and Validation of the Phoenix Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0196) by Sanchez-Pinto&ast;, Bennett&ast;, DeWitt&ast;&ast;, Russell&ast;&ast; et al. (2024)

  * <small> &ast; Drs Sanchez-Pinto and Bennett contributed equally; &ast;&ast; Dr DeWitt and Mr Russell contributed equally.</small>

* ["International Consensus Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0179) by Schlapbach, Watson, Sorce, et al. (2024).

## Phoenix Criteria
A patient is considered septic if they have a suspected (or proven) infection with
at total Phoenix score of at least two points.  The Phoenix score is the sum of
the scores from four organ dysfunction scores:

1. Respiratory,
2. Cardiovascular,
3. Coagulation, and
4. Neurologic.

Septic shock is defined as sepsis with at least one cardiovascular point.

In addition to the Phoenix criteria there is an extended criteria intended for
research, Phoenix-8, which includes the four organ systems above along with

5. Endocrine,
6. Immunologic,
7. Renal, and
8. Hepatic.

## Phoenix Rubric

| Organ System                                                          | 0 Points                         | 1 Point                 | 2 Points                 | 3 Points | 
| :------                                                               | :--                              | :--                     | :--                      | :--      | 
| **Respiratory** (0-3 points)                                          |                                  |                         |                          |          | 
|                                                                       |                                  | Any respiratory support | IMV<sup>a</sup>                   | IMV      | 
| &nbsp;&nbsp;PaO<sub>2</sub>:FiO<sub>2</sub>                                             | &geq; 400                        | < 400                   | < 200                    | < 100    | 
| &nbsp;&nbsp;SpO<sub>2</sub>:FiO<sub>2</sub><sup>b</sup>                                          | &geq; 292                        | < 292                   | < 220                    | < 148    | 
| **Cardiovascular** (0-6 points; sum of medications, Lactate, and MAP) |                                  |                         |                          |          | 
| &nbsp;&nbsp; Systemic Vasoactive Medications<sup>c</sup>                       | No medications                   | 1 medication            | 2 or more medications    |          | 
| &nbsp;&nbsp; Lactate<sup>d</sup> (mmol/L)                                      | &lt; 5                           | 5 &leq; Lactate &lt; 11 | &geq; 11                 |          | 
| &nbsp;&nbsp; Age<sup>e</sup> (months) adjusted MAP<sup>f</sup> (mmHg)                   |                                  |                         |                          |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;   0 &leq; Age &lt;   1                       | &geq; 31                         | 17 &leq; MAP &lt; 31    | &lt; 17                  |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;   1 &leq; Age &lt;  12                       | &geq; 39                         | 25 &leq; MAP &lt; 39    | &lt; 25                  |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;  12 &leq; Age &lt;  24                       | &geq; 44                         | 31 &leq; MAP &lt; 44    | &lt; 31                  |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;  24 &leq; Age &lt;  60                       | &geq; 45                         | 32 &leq; MAP &lt; 45    | &lt; 32                  |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;  60 &leq; Age &lt; 144                       | &geq; 49                         | 36 &leq; MAP &lt; 49    | &lt; 36                  |          | 
| &nbsp;&nbsp;&nbsp;&nbsp; 144 &leq; Age &lt; 216                       | &geq; 52                         | 38 &leq; MAP &lt; 52    | &lt; 38                  |          | 
| **Coagulation**<sup>g</sup> (0-2 points; 1 for each lab; max of 2 points)      |                                  |                         |                          |          | 
| &nbsp;&nbsp; Platelets (1000/&mu;L)                                   | &geq; 100                        | &lt; 100                |                          |          | 
| &nbsp;&nbsp; INR                                                      | &leq; 1.3                        | &gt; 1.3                |                          |          | 
| &nbsp;&nbsp; D-Dimer (mg/L FEU)                                       | &leq; 2                          | &gt; 2                  |                          |          | 
| &nbsp;&nbsp; Fibrinogen (mg/dL)                                       | &geq; 100                        | &lt; 100                |                          |          | 
| **Neurologic**<sup>h</sup> (0-2 points)                                        |                                  |                         |                          |          | 
| &nbsp;&nbsp;                                                          | GCS<sup>i</sup> &geq; 11                  | GCS &leq; 10            | Bilaterally fixed pupils |          | 
| **Endocrine** (0-1 point)                                             |                                  |                         |                          |          | 
| &nbsp;&nbsp; Blood Glucose (mg/dL)                                    | 50 &leq; Blood Glucose &leq; 150 | &lt; 50; or &gt; 150    |                          |          | 
| **Immunologic** (0-1 point; point from ANC and/or ALC)                |                                  |                         |                          |          | 
| &nbsp;&nbsp; ANC (cells/mm<sup>3</sup>)                                        | &geq; 500                        | &lt; 500                |                          |          | 
| &nbsp;&nbsp; ALC (cells/mm<sup>3</sup>)                                        | &geq; 1000                       | &lt; 1000               |                          |          | 
| **Renal** (0-1 point)                                                 |                                  |                         |                          |          | 
| &nbsp;&nbsp; Age<sup>e</sup> (months) adjusted Creatinine (mg/dL)              |                                  |                         |                          |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;   0 &leq; Age &lt;   1                       | &lt; 0.8                         | &geq; 0.8               |                          |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;   1 &leq; Age &lt;  12                       | &lt; 0.3                         | &geq; 0.3               |                          |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;  12 &leq; Age &lt;  24                       | &lt; 0.4                         | &geq; 0.4               |                          |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;  24 &leq; Age &lt;  60                       | &lt; 0.6                         | &geq; 0.6               |                          |          | 
| &nbsp;&nbsp;&nbsp;&nbsp;  60 &leq; Age &lt; 144                       | &lt; 0.7                         | &geq; 0.7               |                          |          | 
| &nbsp;&nbsp;&nbsp;&nbsp; 144 &leq; Age &lt; 216                       | &lt; 1.0                         | &geq; 1.0               |                          |          | 
| **Hepatic** (0-1 point; point from total bilirubin and/or ALT)        |                                  |                         |                          |          | 
| &nbsp;&nbsp; Total Bilirubin (mg/dL)                                  | &lt; 4                           | &geq; 4                 |                          |          | 
| &nbsp;&nbsp; ALT (IU/L)                                               | &leq; 102                        | &gt; 102                |                          |          | 

<small>
<sup>a</sup>Abbreviations: ALC: Absolute lymphocyte count; ALT: alanine aminotransferase; ANC: Absolute neutrophil count; FEU: fibrinogen equivalent units; FiO<sub>2</sub>: fraction of inspired oxygen; GCS: Glasgow Coma Score; IMV: invasive mechanical ventilation; INR: International normalized ratio; MAP: mean arterial pressure; PaO<sub>2</sub>: arterial oxygen pressure; SpO<sub>2</sub>: pulse oximetry oxygen saturation;

<sup>b</sup>SpO<sub>2</sub>:FiO<sub>2</sub> is only valid when SpO<sub>2</sub> &leq; 97.

<sup>c</sup>Vasoactive medications: any systemic dose of dobutamine, dopamine, epinephrine, milrinone, norepinephrine, and/or vasopressin.

<sup>d</sup>Lactate can be arterial or venous. Reference range 0.5 - 2.2 mmol/L

<sup>e</sup>Age: measured in months and is not adjusted for prematurity.

<sup>f</sup>MAP - Use measured mean arterial pressure preferentially (invasive arterial if available, or non-invasive oscillometric), alternatively use the calculation diastolic + (systolic - diastolic) / 3

<sup>g</sup>Coagulation variable reference ranges: platelets, 150-450 103/μL; D-dimer, < 0.5 mg/L FEU; fibrinogen, 180-410 mg/dL. International normalized ratio reference range is based on local reference prothrombin time.

<sup>h</sup>Neurologic dysfunction scoring was pragmatically validated in both sedated and on sedated patients and those with and without IMV.

<sup>i</sup>GCS measures level of consciousness based on verbal, eye, and motor response. Values are integers from 3 to 15 with higher scores indicating better neurologic function.
</small>


## Software

* Python module
* R package: [![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/phoenix)](https://cran.r-project.org/package=phoenix)
* [Example SQL queries](https://cu-dbmi-peds.github.io/phoenix/articles/sql.html)

## Example use of the Python Module




``` python
import numpy as np
import pandas as pd
import importlib.resources

import phoenix as phx
```

### Example Data set

There is an example data set included in the package in a file called
`sepsis.csv`.  Load that file to use in the following examples.


``` python
# read in the example data set
path = importlib.resources.files('phoenix')
sepsis = pd.read_csv(path.joinpath('data').joinpath('sepsis.csv'))
print(sepsis.head())
##    pid     age  fio2  pao2  spo2  vent  gcs_total          pupil  platelets   inr  ...  epinephrine  milrinone  norepinephrine  vasopressin  glucose     anc    alc  creatinine  bilirubin    alt
## 0    1    0.06  0.75   NaN  99.0     1        NaN            NaN      199.0  1.46  ...            1          1               0            0      NaN     NaN    NaN        1.03        NaN   36.0
## 1    2  201.70  0.75  75.3  95.0     1        5.0  both-reactive      243.0  1.18  ...            0          0               1            0    110.0  14.220  2.220        0.51        0.2   32.0
## 2    3   20.80  1.00  49.5   NaN     1       15.0  both-reactive       49.0  1.60  ...            0          0               0            0     93.0   2.210  0.190        0.33        0.8  182.0
## 3    4  192.50   NaN   NaN   NaN     0       14.0            NaN        NaN  1.30  ...            0          0               0            0    110.0   3.184  0.645        0.31        8.5   21.0
## 4    5  214.40   NaN  38.7  95.0     0        NaN            NaN      393.0   NaN  ...            0          0               0            0      NaN     NaN    NaN        0.52        NaN    NaN
## 
## [5 rows x 27 columns]
```

### Organ Dysfunction Scoring
There is one function for each of the eight component organ dysfunction scores.
Each of these functions return a numpy array of integers.

#### Respiratory Dysfunction Scoring


``` python
# Expected Units:
#   PaO2: mmHg
#   FiO2: reported as a decimal, 0.21 to 1.00
#   Spo2: percentage, values from 0 to 100
resp = phx.phoenix_respiratory(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy()
    )
print(type(resp))
## <class 'numpy.ndarray'>
print(resp)
## [0 3 3 0 0 3 3 0 3 3 3 1 0 2 3 0 2 3 2 0]
```

#### Cardiovascular Dysfunction Scoring


``` python
# Expected Units:
#   vasoactives: vector is expected to be integer values 0, 1, 2, 3, 4, 5, 6.
#                In this example each of the six possible vasoactive medication
#                columns are integer value 0 or 1 indicators
#
#   lactate: mmol/L
#
#   map (mean arterial pressure): mmHg.
#                                 In the example below we report the map as the
#                                 weighted average of systolic (sbp) and
#                                 diastolic (dbp) pressures, also reported in
#                                 mmHg.

card = phx.phoenix_cardiovascular(
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"]       + sepsis["epinephrine"] +
                  sepsis["milrinone"]  + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3
)
print(type(card))
## <class 'numpy.ndarray'>
print(card)
## [2 2 1 0 0 1 4 0 3 0 3 0 0 2 3 2 2 2 2 1]
```

#### Coagulation Dysfunction Scoring


``` python
# Expected units:
#   platelets: 1000/μL
#   inr: 
#   D-Dimer: (mg/L FEU)
#   Fibrinogen: mg/dL
coag = phx.phoenix_coagulation(
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen']
)
print(type(coag))
## <class 'numpy.ndarray'>
print(coag)
## [1 1 2 1 0 2 2 1 1 0 1 0 0 1 2 1 1 2 0 1]
```

#### Neurologic Dysfunction Scoring


``` python
# Expected Units:
#   GCS - Glascow Coma Score: Integers in 3, 4, ..., 14, 15
#   fixed pupils: 0 or 1 integer values. 1 for bilaterally fixed pupils, 0
#                 otherwise
neuro = phx.phoenix_neurologic(
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int)
)
print(type(neuro))
## <class 'numpy.ndarray'>
print(neuro)
## [0 1 0 0 0 1 0 0 1 1 2 0 0 0 0 0 0 0 0 0]
```

#### Endocrine Dysfunction Scoring


``` python
# Expected units:
#   glucose: mg/dL
endo = phx.phoenix_endocrine(sepsis["glucose"])
print(type(endo))
## <class 'numpy.ndarray'>
print(endo)
## [0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 1]
```

#### Immunologic Dysfunction Scoring


``` python
# Expected Units:
#   ANC: 1000 cells / mm³
#   ALC: 1000 cells / mm³
immu = phx.phoenix_immunologic(sepsis["anc"], sepsis["alc"])
print(type(immu))
## <class 'numpy.ndarray'>
print(immu)
## [0 0 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
```

#### Renal Dysfunction Scoring


``` python
# Expected Units:
#   age: months
#   creatinine: mg/dL
renal = phx.phoenix_renal(sepsis["creatinine"], sepsis["age"])
print(type(renal))
## <class 'numpy.ndarray'>
print(renal)
## [1 0 0 0 0 1 1 0 1 0 1 0 0 0 1 0 0 1 1 0]
```

#### Hepatic Dysfunction Scoring


``` python
# Expected Units:
#   (total) Bilirubin: mg/dL
#   ALT: IU/L
hepatic = phx.phoenix_hepatic(sepsis["bilirubin"], sepsis["alt"])
print(type(hepatic))
## <class 'numpy.ndarray'>
print(hepatic)
## [0 0 1 1 0 0 1 0 1 0 0 0 0 0 1 0 0 1 0 0]
```

### Phoenix Scoring

The Phoenix score is the sum of the respiratory, cardiovascular, coagulation,
and neurologic scores.  Sepsis is defined as a total score of at least two
points and septic shock is defined as sepsis with at least one cardiovascular
point.


``` python
# Expected Units: please review the scoring for specific organ systems

phoenix = phx.phoenix(
   # Respiratory
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = sepsis["spo2"] / sepsis["fio2"],
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy(),
  # Cardiovascular
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3,
  # Coagulation
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen'],
  # Neurologic
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int))
print(phoenix.info())
## <class 'pandas.core.frame.DataFrame'>
## RangeIndex: 20 entries, 0 to 19
## Data columns (total 7 columns):
##  #   Column                        Non-Null Count  Dtype
## ---  ------                        --------------  -----
##  0   phoenix_respiratory_score     20 non-null     int64
##  1   phoenix_cardiovascular_score  20 non-null     int64
##  2   phoenix_coagulation_score     20 non-null     int64
##  3   phoenix_neurologic_score      20 non-null     int64
##  4   phoenix_sepsis_score          20 non-null     int64
##  5   phoenix_sepsis                20 non-null     int64
##  6   phoenix_septic_shock          20 non-null     int64
## dtypes: int64(7)
## memory usage: 1.2 KB
## None
print(phoenix.head())
##    phoenix_respiratory_score  phoenix_cardiovascular_score  phoenix_coagulation_score  phoenix_neurologic_score  phoenix_sepsis_score  phoenix_sepsis  phoenix_septic_shock
## 0                          3                             2                          1                         0                     6               1                     1
## 1                          3                             2                          1                         1                     7               1                     1
## 2                          3                             1                          2                         0                     6               1                     1
## 3                          0                             0                          1                         0                     1               0                     0
## 4                          0                             0                          0                         0                     0               0                     0
```

### Phoenix-8 Scoring

Phoenix-8 is an extended score using all eight organ dysfunction scores.


``` python
# Expected Units: please review the scoring for specific organ systems

phoenix8_scores = phx.phoenix8(

   # Respiratory
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy(),

  # Cardiovascular
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    map = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3,
    age = sepsis["age"],

  # Coagulation
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen'],

  # Neurologic
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int),

  # Endocrine
    glucose = sepsis["glucose"],

  # Immunologic
    anc = sepsis["anc"],
    alc = sepsis["alc"],

  # Renal
    creatinine = sepsis["creatinine"],
    # age needed here too, already noted with cardiovascular

  # Hepatic
    bilirubin = sepsis["bilirubin"],
    alt = sepsis["alt"])
print(phoenix8_scores.info())
## <class 'pandas.core.frame.DataFrame'>
## RangeIndex: 20 entries, 0 to 19
## Data columns (total 12 columns):
##  #   Column                        Non-Null Count  Dtype
## ---  ------                        --------------  -----
##  0   phoenix_respiratory_score     20 non-null     int64
##  1   phoenix_cardiovascular_score  20 non-null     int64
##  2   phoenix_coagulation_score     20 non-null     int64
##  3   phoenix_neurologic_score      20 non-null     int64
##  4   phoenix_sepsis_score          20 non-null     int64
##  5   phoenix_sepsis                20 non-null     int64
##  6   phoenix_septic_shock          20 non-null     int64
##  7   phoenix_endocrine_score       20 non-null     int64
##  8   phoenix_immunologic_score     20 non-null     int64
##  9   phoenix_renal_score           20 non-null     int64
##  10  phoenix_hepatic_score         20 non-null     int64
##  11  phoenix8_sepsis_score         20 non-null     int64
## dtypes: int64(12)
## memory usage: 2.0 KB
## None
print(phoenix8_scores.head())
##    phoenix_respiratory_score  phoenix_cardiovascular_score  phoenix_coagulation_score  ...  phoenix_renal_score  phoenix_hepatic_score  phoenix8_sepsis_score
## 0                          0                             2                          1  ...                    1                      0                      4
## 1                          3                             2                          1  ...                    0                      0                      7
## 2                          3                             1                          2  ...                    0                      1                      8
## 3                          0                             0                          1  ...                    0                      1                      3
## 4                          0                             0                          0  ...                    0                      0                      0
## 
## [5 rows x 12 columns]
```
