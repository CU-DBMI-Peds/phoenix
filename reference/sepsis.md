# sepsis

A fully synthetic data set with variables needed for examples and
documentation of the Phoenix Sepsis Criteria.

## Usage

``` r
sepsis
```

## Format

a data.frame with 20 rows and 27 columns

|          |                |                                                             |
|----------|----------------|-------------------------------------------------------------|
| \[, 1\]  | pid            | patient identification number                               |
| \[, 2\]  | age            | age in months                                               |
| \[, 3\]  | fio2           | fraction of inspired oxygen                                 |
| \[, 4\]  | pao2           | partial pressure of oxygen in arterial blood (mmHg)         |
| \[, 5\]  | spo2           | pulse oximetry                                              |
| \[, 6\]  | vent           | indicator for invasive mechanical ventilation               |
| \[, 7\]  | gcs_total      | total Glasgow Coma Scale                                    |
| \[, 8\]  | pupil          | character vector reporting if pupils are reactive or fixed. |
| \[, 9\]  | platelets      | platelets measured in 1,000 / microliter                    |
| \[, 10\] | inr            | international normalized ratio                              |
| \[, 11\] | d_dimer        | D-dimer; units of mg/L FEU                                  |
| \[, 12\] | fibrinogen     | units of mg/dL                                              |
| \[, 13\] | dbp            | diastolic blood pressure (mmHg)                             |
| \[, 14\] | sbp            | systolic blood pressure (mmHg)                              |
| \[, 15\] | lactate        | units of mmol/L                                             |
| \[, 16\] | dobutamine     | indicator for receiving systemic dobutamine                 |
| \[, 17\] | dopamine       | indicator for receiving systemic dopamine                   |
| \[, 18\] | epinephrine    | indicator for receiving systemic epinephrine                |
| \[, 19\] | milrinone      | indicator for receiving systemic milrinone                  |
| \[, 20\] | norepinephrine | indicator for receiving systemic norepinephrine             |
| \[, 21\] | vasopressin    | indicator for receiving systemic vasopressin                |
| \[, 22\] | glucose        | units of mg/dL                                              |
| \[, 23\] | anc            | units of 1,000 cells per cubic millimeter                   |
| \[, 24\] | alc            | units of 1,000 cells per cubic millimeter                   |
| \[, 25\] | creatinine     | units of mg/dL                                              |
| \[, 26\] | bilirubin      | units of mg/dL                                              |
| \[, 27\] | alt            | units of IU/L                                               |
