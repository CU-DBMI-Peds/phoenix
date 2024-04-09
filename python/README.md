<!-- README.md is generated from README.Rmd. Please edit that file -->

# phoenix: Phoenix Sepsis and Phoenix-8 Sepsis Criteria

Implementation of the Phoenix and Phoenix-8 Sepsis Criteria as
described in:

* ["Development and Validation of the Phoenix Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0196) by Sanchez-Pinto&ast;, Bennett&ast;, DeWitt&ast;&ast;, Russell&ast;&ast; et al. (2024)

  * <small> &ast; Drs Sanchez-Pinto and Bennett contributed equally; &ast;&ast; Dr DeWitt and Mr Russell contributed equally.</small>

* ["International Consensus Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0179) by Schlapbach, Watson, Sorce, et al. (2024).

## Software

* python module
* [![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/phoenix)](https://cran.r-project.org/package=phoenix)
* Example SQL queries

* Source code on [github](https://github.com/CU-DBMI-Peds/phoenix/)
* [Issue tracker](https://github.com/CU-DBMI-Peds/phoenix/issues/)

## Example use




```python
import numpy as np
import pandas as pd
import phoenix as phx
import importlib.resources

# read in the example data set
with importlib.resources.path('phoenix', 'data') as data_path:
    sepsis = pd.read_csv(data_path / "sepsis.csv")
## <string>:3: DeprecationWarning: path is deprecated. Use files() instead. Refer to https://importlib-resources.readthedocs.io/en/latest/using.html#migrating-from-legacy for migration advice.

print(sepsis)
##     pid     age  fio2  pao2  spo2  vent  gcs_total          pupil  platelets    inr  ...  epinephrine  milrinone  norepinephrine  vasopressin  glucose     anc    alc  creatinine  bilirubin     alt
## 0     1    0.06  0.75   NaN  99.0     1        NaN            NaN      199.0  1.460  ...            1          1               0            0      NaN     NaN    NaN       1.030        NaN    36.0
## 1     2  201.70  0.75  75.3  95.0     1        5.0  both-reactive      243.0  1.180  ...            0          0               1            0    110.0  14.220  2.220       0.510      0.200    32.0
## 2     3   20.80  1.00  49.5   NaN     1       15.0  both-reactive       49.0  1.600  ...            0          0               0            0     93.0   2.210  0.190       0.330      0.800   182.0
## 3     4  192.50   NaN   NaN   NaN     0       14.0            NaN        NaN  1.300  ...            0          0               0            0    110.0   3.184  0.645       0.310      8.500    21.0
## 4     5  214.40   NaN  38.7  95.0     0        NaN            NaN      393.0    NaN  ...            0          0               0            0      NaN     NaN    NaN       0.520        NaN     NaN
## 5     6  101.20  0.60  69.9  88.0     1        3.0  both-reactive       86.0  1.230  ...            0          0               0            0    147.0  20.200  0.240       0.770      1.200    15.0
## 6     7  150.70  0.50   NaN  31.0     1        NaN            NaN       65.0  3.100  ...            1          1               0            1      NaN     NaN    NaN       1.470      1.700  3664.0
## 7     8  159.70  0.30   NaN  97.0     1       15.0  both-reactive      215.0  0.970  ...            0          0               0            0    100.0   3.760  1.550       0.580      0.500    50.0
## 8     9  176.10  0.65  51.0  82.0     1        3.0  both-reactive      101.0  1.080  ...            1          1               1            1    264.0   8.770  3.600       1.230     21.100   151.0
## 9    10    6.60  0.80   NaN  76.0     1        3.0  both-reactive      292.0    NaN  ...            0          0               0            0     93.0   9.084  4.617       0.180        NaN     NaN
## 10   11   36.70  0.65  54.0   NaN     1        3.0     both-fixed        NaN  3.000  ...            1          0               0            0    341.0     NaN    NaN       0.870      0.180     NaN
## 11   12   37.40  0.35   NaN  91.0     0        NaN            NaN        NaN    NaN  ...            0          0               0            0      NaN     NaN    NaN         NaN        NaN     NaN
## 12   13    0.12  0.30   NaN  97.0     1        NaN            NaN        NaN    NaN  ...            0          0               0            0      NaN     NaN    NaN         NaN        NaN     NaN
## 13   14   62.30  0.50   NaN  89.0     1        NaN            NaN       24.0  1.146  ...            1          1               0            0      NaN     NaN    NaN       0.120      3.300    60.0
## 14   15   10.60  1.00  42.5  45.0     1        NaN            NaN       82.0  1.424  ...            1          1               0            1      NaN     NaN    NaN       1.300      1.300  1792.0
## 15   16    0.89   NaN   NaN   NaN     0        NaN            NaN      355.0  1.230  ...            1          1               1            0     82.4   4.720  4.300       0.418      1.579    15.0
## 16   17   10.70  0.45  61.3  97.0     1       11.0  both-reactive      166.0  1.000  ...            1          1               0            1    130.0   9.380  1.310       0.290      0.600    41.0
## 17   18   10.60  1.00  64.1  92.0     1        NaN            NaN       80.0  1.641  ...            1          1               0            1      NaN     NaN    NaN       1.100      1.300  1790.0
## 18   19    0.17  0.50   NaN  97.0     1        NaN            NaN      190.0    NaN  ...            1          1               0            0    103.0  12.570  2.810       1.200        NaN     NaN
## 19   20   71.90   NaN   NaN   NaN     0        NaN            NaN       78.0  1.160  ...            1          0               0            0    159.8   3.410  2.850       0.418      0.363    22.0
## 
## [20 rows x 27 columns]

print("Respiratory Score")
## Respiratory Score
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

print("Cardiovascular Score")
## Cardiovascular Score
card = phx.phoenix_cardiovascular(
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3
)
print(type(card))
## <class 'numpy.ndarray'>
print(card)
## [2 2 1 0 0 1 4 0 3 0 3 0 0 2 3 2 2 2 2 1]

print("Coagulation Score")
## Coagulation Score
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

print("Neurologic Score")
## Neurologic Score
neuro = phx.phoenix_neurologic(
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int)
)
print(type(neuro))
## <class 'numpy.ndarray'>
print(neuro)
## [0 1 0 0 0 1 0 0 1 1 2 0 0 0 0 0 0 0 0 0]


print("Phoenix Sepsis Score")
## Phoenix Sepsis Score
phoenix = phx.phoenix(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = sepsis["spo2"] / sepsis["fio2"],
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy(),
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3,
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen'],
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int),
    )

print(type(phoenix))
## <class 'pandas.core.frame.DataFrame'>
print(phoenix)
##     phoenix_respiratory_score  phoenix_cardiovascular_score  phoenix_coagulation_score  phoenix_neurologic_score  phoenix_sepsis_score  phoenix_sepsis  phoenix_septic_shock
## 0                           3                             2                          1                         0                     6               1                     1
## 1                           3                             2                          1                         1                     7               1                     1
## 2                           3                             1                          2                         0                     6               1                     1
## 3                           0                             0                          1                         0                     1               0                     0
## 4                           0                             0                          0                         0                     0               0                     0
## 5                           3                             1                          2                         1                     7               1                     1
## 6                           3                             4                          2                         0                     9               1                     1
## 7                           0                             0                          1                         0                     1               0                     0
## 8                           3                             3                          1                         1                     8               1                     1
## 9                           3                             0                          0                         1                     4               1                     0
## 10                          3                             3                          1                         2                     9               1                     1
## 11                          1                             0                          0                         0                     1               0                     0
## 12                          0                             0                          0                         0                     0               0                     0
## 13                          2                             2                          1                         0                     5               1                     1
## 14                          3                             3                          2                         0                     8               1                     1
## 15                          0                             2                          1                         0                     3               1                     1
## 16                          2                             2                          1                         0                     5               1                     1
## 17                          3                             2                          2                         0                     7               1                     1
## 18                          2                             2                          0                         0                     4               1                     1
## 19                          0                             1                          1                         0                     2               1                     1
```
