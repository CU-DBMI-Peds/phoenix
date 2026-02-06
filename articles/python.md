# The Phoenix Sepsis Criteria in Python

## Background

It would be helpful to read the first few sections of the [Get
started](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.html)
article for details on the Phoenix criteria

## Python Module

### Install

The python module can be installed via

``` python
pip install phoenix-sepsis
```

### Importing the module

The needed modules to run the examples are:

``` python
import numpy as np
import pandas as pd
import importlib.resources
import phoenix as phx
```

### Example Data Set

The same example data provided in the R package has also been provided
in the python module.

``` python
path = importlib.resources.files('phoenix')
sepsis = pd.read_csv(path.joinpath('data').joinpath('sepsis.csv'))
print(sepsis.shape)
## (20, 27)
print(sepsis.head())
##    pid     age  fio2  pao2  spo2  ...     anc    alc creatinine  bilirubin    alt
## 0    1    0.06  0.75   NaN  99.0  ...     NaN    NaN       1.03        NaN   36.0
## 1    2  201.70  0.75  75.3  95.0  ...  14.220  2.220       0.51        0.2   32.0
## 2    3   20.80  1.00  49.5   NaN  ...   2.210  0.190       0.33        0.8  182.0
## 3    4  192.50   NaN   NaN   NaN  ...   3.184  0.645       0.31        8.5   21.0
## 4    5  214.40   NaN  38.7  95.0  ...     NaN    NaN       0.52        NaN    NaN
## 
## [5 rows x 27 columns]
```

| Column Name    | Note                                                        |
|:---------------|:------------------------------------------------------------|
| pid            | patient identification number                               |
| age            | age in months                                               |
| fio2           | fraction of inspired oxygen                                 |
| pao2           | partial pressure of oxygen in arterial blood (mmHg)         |
| spo2           | pulse oximetry                                              |
| vent           | indicator for invasive mechanical ventilation               |
| gcs_total      | total Glasgow Coma Scale                                    |
| pupil          | character vector reporting if pupils are reactive or fixed. |
| platelets      | platelets measured in 1,000 / microliter                    |
| inr            | international normalized ratio                              |
| d_dimer        | D-dimer; units of mg/L FEU                                  |
| fibrinogen     | units of mg/dL                                              |
| dbp            | diastolic blood pressure (mmHg)                             |
| sbp            | systolic blood pressure (mmHg)                              |
| lactate        | units of mmol/L                                             |
| dobutamine     | indicator for receiving systemic dobutamine                 |
| dopamine       | indicator for receiving systemic dopamine                   |
| epinephrine    | indicator for receiving systemic epinephrine                |
| milrinone      | indicator for receiving systemic milrinone                  |
| norepinephrine | indicator for receiving systemic norepinephrine             |
| vasopressin    | indicator for receiving systemic vasopressin                |
| glucose        | units of mg/dL                                              |
| anc            | units of 1,000 cells per cubic millimeter                   |
| alc            | units of 1,000 cells per cubic millimeter                   |
| creatinine     | units of mg/dL                                              |
| bilirubin      | units of mg/dL                                              |
| alt            | units of IU/L                                               |

### Organ Dysfunction Scores

All eight organ dysfunction scoring functions return integer valued
numpy arrays.

#### Respiratory

Scoring for respiratory dysfunction:

| Organ System                 | 0 Points | 1 Point                 | 2 Points | 3 Points |
|:-----------------------------|:---------|:------------------------|:---------|:---------|
| **Respiratory** (0-3 points) |          |                         |          |          |
|                              |          | Any respiratory support | IMV^(a)  | IMV      |
|   PaO₂:FiO₂                  | ≥ 400    | \< 400                  | \< 200   | \< 100   |
|   SpO₂:FiO₂^(b)              | ≥ 292    | \< 292                  | \< 220   | \< 148   |

^(a) IMV: invasive mechanical ventilation; PaO₂: arterial oxygen
pressure; SpO₂: pulse oximetry oxygen saturation;

^(b)SpO₂:FiO₂ is only valid when SpO₂ ≤ 97.

``` python
py_resp = phx.phoenix_respiratory(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy()
)
print(type(py_resp))
## <class 'numpy.ndarray'>
print(py_resp)
## [0 3 3 0 0 3 3 0 3 3 3 1 0 2 3 0 2 3 2 0]
```

#### Cardiovascular

| Organ System                                                          | 0 Points       | 1 Point           | 2 Points              | 3 Points |
|:----------------------------------------------------------------------|:---------------|:------------------|:----------------------|:---------|
| **Cardiovascular** (0-6 points; sum of medications, Lactate, and MAP) |                |                   |                       |          |
|    Systemic Vasoactive Medications^(c)                                | No medications | 1 medication      | 2 or more medications |          |
|    Lactate^(d) (mmol/L)                                               | \< 5           | 5 ≤ Lactate \< 11 | ≥ 11                  |          |
|    Age^(e) (months) adjusted MAP^(f) (mmHg)                           |                |                   |                       |          |
|      0 ≤ Age \< 1                                                     | ≥ 31           | 17 ≤ MAP \< 31    | \< 17                 |          |
|      1 ≤ Age \< 12                                                    | ≥ 39           | 25 ≤ MAP \< 39    | \< 25                 |          |
|      12 ≤ Age \< 24                                                   | ≥ 44           | 31 ≤ MAP \< 44    | \< 31                 |          |
|      24 ≤ Age \< 60                                                   | ≥ 45           | 32 ≤ MAP \< 45    | \< 32                 |          |
|      60 ≤ Age \< 144                                                  | ≥ 49           | 36 ≤ MAP \< 49    | \< 36                 |          |
|      144 ≤ Age \< 216                                                 | ≥ 52           | 38 ≤ MAP \< 52    | \< 38                 |          |

^(d)Lactate can be arterial or venous. Reference range 0.5 - 2.2 mmol/L
^(e)Age: measured in months and is not adjusted for prematurity.
^(f)MAP - Use measured mean arterial pressure preferentially (invasive
arterial if available, or non-invasive oscillometric), alternatively use
the calculation diastolic + (systolic - diastolic) / 3

As with the R package, the Python module has a function `map` to
simplify the estimation of mean arterial pressure based on systolic and
diastolic pressures. MAP is approximated as (2/3)*DBP + (1/3)*SBP.

``` python
py_card = phx.phoenix_cardiovascular(
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] +
                  sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = phx.map(sepsis["sbp"], sepsis["dbp"])
)
print(type(py_card))
## <class 'numpy.ndarray'>
print(py_card)
## [2 2 1 0 0 1 4 0 3 0 3 0 0 2 3 2 2 2 2 1]
```

#### Coagulation

| Organ System                                                      | 0 Points | 1 Point | 2 Points | 3 Points |
|:------------------------------------------------------------------|:---------|:--------|:---------|:---------|
| **Coagulation**^(g) (0-2 points; 1 for each lab; max of 2 points) |          |         |          |          |
|    Platelets (1000/μL)                                            | ≥ 100    | \< 100  |          |          |
|    INR                                                            | ≤ 1.3    | \> 1.3  |          |          |
|    D-Dimer (mg/L FEU)                                             | ≤ 2      | \> 2    |          |          |
|    Fibrinogen (mg/dL)                                             | ≥ 100    | \< 100  |          |          |

FEU: fibrinogen equivalent units; INR: International normalized ratio;

^(g)Coagulation variable reference ranges: platelets, 150-450 103/μL;
D-dimer, \< 0.5 mg/L FEU; fibrinogen, 180-410 mg/dL. International
normalized ratio reference range is based on local reference prothrombin
time.

``` python
py_coag = phx.phoenix_coagulation(
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen']
)
print(type(py_coag))
## <class 'numpy.ndarray'>
print(py_coag)
## [1 1 2 1 0 2 2 1 1 0 1 0 0 1 2 1 1 2 0 1]
```

#### Neurologic

| Organ System                    | 0 Points     | 1 Point  | 2 Points                 | 3 Points |
|:--------------------------------|:-------------|:---------|:-------------------------|:---------|
| **Neurologic**^(h) (0-2 points) |              |          |                          |          |
|                                 | GCS^(i) ≥ 11 | GCS ≤ 10 | Bilaterally fixed pupils |          |

FEU: fibrinogen equivalent units; INR: International normalized ratio;

^(h)Neurologic dysfunction scoring was pragmatically validated in both
sedated and on sedated patients and those with and without IMV. ^(i)GCS
measures level of consciousness based on verbal, eye, and motor
response. Values are integers from 3 to 15 with higher scores indicating
better neurologic function.

``` python
py_neur = phx.phoenix_neurologic(
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int)
)
print(type(py_neur))
## <class 'numpy.ndarray'>
print(py_neur)
## [0 1 0 0 0 1 0 0 1 1 2 0 0 0 0 0 0 0 0 0]
```

#### Endocrine

| Organ System              | 0 Points                 | 1 Point          | 2 Points | 3 Points |
|:--------------------------|:-------------------------|:-----------------|:---------|:---------|
| **Endocrine** (0-1 point) |                          |                  |          |          |
|    Blood Glucose (mg/dL)  | 50 ≤ Blood Glucose ≤ 150 | \< 50; or \> 150 |          |          |

``` python
py_endo = phx.phoenix_endocrine(sepsis["glucose"])
print(type(py_endo))
## <class 'numpy.ndarray'>
print(py_endo)
## [0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 1]
```

#### Immunologic

| Organ System                                           | 0 Points | 1 Point | 2 Points | 3 Points |
|:-------------------------------------------------------|:---------|:--------|:---------|:---------|
| **Immunologic** (0-1 point; point from ANC and/or ALC) |          |         |          |          |
|    ANC (cells/mm³)                                     | ≥ 500    | \< 500  |          |          |
|    ALC (cells/mm³)                                     | ≥ 1000   | \< 1000 |          |          |

ALC: Absolute lymphocyte count; ANC: Absolute neutrophil count;

``` python
py_immu = phx.phoenix_immunologic(sepsis["anc"], sepsis["alc"])
print(type(py_immu))
## <class 'numpy.ndarray'>
print(py_immu)
## [0 0 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
```

#### Renal

| Organ System                                    | 0 Points | 1 Point | 2 Points | 3 Points |
|:------------------------------------------------|:---------|:--------|:---------|:---------|
| **Renal** (0-1 point)                           |          |         |          |          |
|    Age^(e) (months) adjusted Creatinine (mg/dL) |          |         |          |          |
|      0 ≤ Age \< 1                               | \< 0.8   | ≥ 0.8   |          |          |
|      1 ≤ Age \< 12                              | \< 0.3   | ≥ 0.3   |          |          |
|      12 ≤ Age \< 24                             | \< 0.4   | ≥ 0.4   |          |          |
|      24 ≤ Age \< 60                             | \< 0.6   | ≥ 0.6   |          |          |
|      60 ≤ Age \< 144                            | \< 0.7   | ≥ 0.7   |          |          |
|      144 ≤ Age \< 216                           | \< 1.0   | ≥ 1.0   |          |          |

``` python
py_renal = phx.phoenix_renal(sepsis["creatinine"], sepsis["age"])
print(type(py_renal))
## <class 'numpy.ndarray'>
print(py_renal)
## [1 0 0 0 0 1 1 0 1 0 1 0 0 0 1 0 0 1 1 0]
```

#### Hepatic

| Organ System                                                   | 0 Points | 1 Point | 2 Points | 3 Points |
|:---------------------------------------------------------------|:---------|:--------|:---------|:---------|
| **Hepatic** (0-1 point; point from total bilirubin and/or ALT) |          |         |          |          |
|    Total Bilirubin (mg/dL)                                     | \< 4     | ≥ 4     |          |          |
|    ALT (IU/L)                                                  | ≤ 102    | \> 102  |          |          |

ALT: alanine aminotransferase;

``` python
py_hepatic = phx.phoenix_hepatic(sepsis["bilirubin"], sepsis["alt"])
print(type(py_hepatic))
## <class 'numpy.ndarray'>
print(py_hepatic)
## [0 0 1 1 0 0 1 0 1 0 0 0 0 0 1 0 0 1 0 0]
```

### Phoenix

The Phoenix score is the sum of the 1. respiratory, 2. cardiovascular,
3. coagulation, and 4. neurologic organ dysfunction scores.

Sepsis is the condition of having a suspected (or confirmed) infection
with two or more Phoenix points.

Septic Shock is defined as sepsis with at least one cardiovascular
point.

``` python
py_phoenix_scores = phx.phoenix(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy(),
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = phx.map(sepsis["sbp"], sepsis["dbp"]),
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen'],
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int),
    )
print(py_phoenix_scores.info())
## <class 'pandas.DataFrame'>
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
print(py_phoenix_scores.head())
##    phoenix_respiratory_score  ...  phoenix_septic_shock
## 0                          0  ...                     1
## 1                          3  ...                     1
## 2                          3  ...                     1
## 3                          0  ...                     0
## 4                          0  ...                     0
## 
## [5 rows x 7 columns]
```

### Phoenix-8

The Phoenix-8 score is the sum of the Phoenix score along with points
form the other four organ systems: 5. endocrine, 6. immunologic, 7.
renal, and 8. hepatic.

``` python
py_phoenix8_scores = phx.phoenix8(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy(),
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    map = phx.map(sepsis["sbp"], sepsis["dbp"]),
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen'],
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int),
    glucose = sepsis["glucose"],
    anc = sepsis["anc"],
    alc = sepsis["alc"],
    creatinine = sepsis["creatinine"],
    bilirubin = sepsis["bilirubin"],
    alt = sepsis["alt"],
    age = sepsis["age"]
    )
print(py_phoenix8_scores.info())
## <class 'pandas.DataFrame'>
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
print(py_phoenix8_scores.head())
##    phoenix_respiratory_score  ...  phoenix8_sepsis_score
## 0                          0  ...                      4
## 1                          3  ...                      7
## 2                          3  ...                      8
## 3                          0  ...                      3
## 4                          0  ...                      0
## 
## [5 rows x 12 columns]
```
