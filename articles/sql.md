# The Phoenix Sepsis Criteria in sql

The following examples are provided to show how to apply the Phoenix
Sepsis criteria within an SQLite data base. We will use the same example
data set `sepsis` from the R package for the following examples. The
examples are made possible by using the following R packages

``` r
library(odbc)
library(DBI)
library(RSQLite)
library(phoenix)
```

To help distinguish between R and sql code chunks, chunks outlined in
blue are SQL and chunks with no outline are R chunks.

We start in R by setting up a local example SQL database with one table
`sepsis`

``` r
con <- dbConnect(drv = RSQLite::SQLite(), dbname = ":memory:")
dbWriteTable(conn = con, name = "sepsis", value = sepsis)
```

We can easily query the table:

``` sql
SELECT * FROM sepsis
```

| pid |    age | fio2 | pao2 | spo2 | vent | gcs_total | pupil         | platelets |  inr | d_dimer | fibrinogen | dbp | sbp | lactate | dobutamine | dopamine | epinephrine | milrinone | norepinephrine | vasopressin | glucose |    anc |   alc | creatinine | bilirubin |  alt |
|:----|-------:|-----:|-----:|-----:|-----:|----------:|:--------------|----------:|-----:|--------:|-----------:|----:|----:|--------:|-----------:|---------:|------------:|----------:|---------------:|------------:|--------:|-------:|------:|-----------:|----------:|-----:|
| 1   |   0.06 | 0.75 |   NA |   99 |    1 |        NA |               |       199 | 1.46 |      NA |        180 |  40 |  53 |      NA |          1 |        1 |           1 |         1 |              0 |           0 |      NA |     NA |    NA |       1.03 |        NA |   36 |
| 2   | 201.70 | 0.75 | 75.3 |   95 |    1 |         5 | both-reactive |       243 | 1.18 |    2.45 |        311 |  60 |  90 |    3.32 |          0 |        1 |           0 |         0 |              1 |           0 |     110 | 14.220 | 2.220 |       0.51 |       0.2 |   32 |
| 3   |  20.80 | 1.00 | 49.5 |   NA |    1 |        15 | both-reactive |        49 | 1.60 |      NA |        309 |  87 | 233 |    1.00 |          0 |        1 |           0 |         0 |              0 |           0 |      93 |  2.210 | 0.190 |       0.33 |       0.8 |  182 |
| 4   | 192.50 |   NA |   NA |   NA |    0 |        14 |               |        NA | 1.30 |    2.82 |        220 |  57 | 104 |      NA |          0 |        0 |           0 |         0 |              0 |           0 |     110 |  3.184 | 0.645 |       0.31 |       8.5 |   21 |
| 5   | 214.40 |   NA | 38.7 |   95 |    0 |        NA |               |       393 |   NA |      NA |         NA |  57 | 101 |      NA |          0 |        0 |           0 |         0 |              0 |           0 |      NA |     NA |    NA |       0.52 |        NA |   NA |
| 6   | 101.20 | 0.60 | 69.9 |   88 |    1 |         3 | both-reactive |        86 | 1.23 |    4.72 |        270 |  79 | 119 |    1.15 |          0 |        1 |           0 |         0 |              0 |           0 |     147 | 20.200 | 0.240 |       0.77 |       1.2 |   15 |
| 7   | 150.70 | 0.50 |   NA |   31 |    1 |        NA |               |        65 | 3.10 |      NA |         94 |  11 |  14 |      NA |          0 |        0 |           1 |         1 |              0 |           1 |      NA |     NA |    NA |       1.47 |       1.7 | 3664 |
| 8   | 159.70 | 0.30 |   NA |   97 |    1 |        15 | both-reactive |       215 | 0.97 |    5.15 |        489 |  66 | 112 |      NA |          0 |        0 |           0 |         0 |              0 |           0 |     100 |  3.760 | 1.550 |       0.58 |       0.5 |   50 |
| 9   | 176.10 | 0.65 | 51.0 |   82 |    1 |         3 | both-reactive |       101 | 1.08 |    7.71 |        456 |  51 | 117 |    8.10 |          0 |        0 |           1 |         1 |              1 |           1 |     264 |  8.770 | 3.600 |       1.23 |      21.1 |  151 |
| 10  |   6.60 | 0.80 |   NA |   76 |    1 |         3 | both-reactive |       292 |   NA |      NA |         NA |  58 |  84 |      NA |          0 |        0 |           0 |         0 |              0 |           0 |      93 |  9.084 | 4.617 |       0.18 |        NA |   NA |

Displaying records 1 - 10

## Respiratory

We need either create or code for the PF ratio, SF Ratio, invasive
mechanical ventilation, and other respiratory support. In the
construction of the PF ratio (pfr) and SF ratio (sfr) we replace missing
values with value that will map to a score of zero. If the percent of
inspiratory oxygen is greater than 0.21, that indicates the patient is
on some form of respiratory support.

``` sql
WITH respiratory AS (
  SELECT
    pid,
    COALESCE(pao2 / fio2, 500) AS pfr,
    COALESCE(IIF(spo2 <= 97, spo2 / fio2, 500), 500) AS sfr,
    COALESCE(vent, 0)          AS imv,
    IIF(fio2 > 0.21 OR vent = 1, 1, 0) AS other_respiratory_support
  FROM sepsis
)
SELECT *,
  imv * (IIF(pfr < 100 OR sfr < 148, 1, 0) + IIF(pfr < 200 OR sfr < 220, 1, 0) ) +
    other_respiratory_support * IIF(pfr < 400 OR sfr < 292, 1, 0) AS phoenix_respiratory_score
  FROM respiratory;
```

The above query was saved to an R `data.frame` called `resp` and will be
added to the virtual database for inspection later.

``` r
dbWriteTable(conn = con, name = "respiratory", value = resp)
```

## Cardiovascular

Missing values correspond to zero points. The combination of age and
mean arterial pressure will require both values to be know for possible
points to be assessed.

``` sql
WITH vars AS (
  SELECT
    pid,
    COALESCE(dobutamine, 0) +
      COALESCE(dopamine, 0) +
      COALESCE(epinephrine, 0) +
      COALESCE(milrinone, 0) +
      COALESCE(norepinephrine, 0) +
      COALESCE(vasopressin, 0) AS vasos,
    lactate,
    dbp + (sbp - dbp) / 3 AS map,
    age
  FROM sepsis
),
points AS (
  SELECT *,
    CASE WHEN vasos > 1 THEN 2
         WHEN vasos > 0 THEN 1
         ELSE 0 END AS vaso_points,
    CASE WHEN lactate >= 11 THEN 2
         WHEN lactate >=  5 THEN 1
         ELSE 0 END AS lactate_points,
    CASE WHEN (age >=   0 AND age <    1) AND (map < 17) THEN 2
         WHEN (age >=   1 AND age <   12) AND (map < 25) THEN 2
         WHEN (age >=  12 AND age <   24) AND (map < 31) THEN 2
         WHEN (age >=  24 AND age <   60) AND (map < 32) THEN 2
         WHEN (age >=  60 AND age <  144) AND (map < 36) THEN 2
         WHEN (age >= 144 AND age <= 216) AND (map < 38) THEN 2
         WHEN (age >=   0 AND age <    1) AND (map < 31) THEN 1
         WHEN (age >=   1 AND age <   12) AND (map < 39) THEN 1
         WHEN (age >=  12 AND age <   24) AND (map < 44) THEN 1
         WHEN (age >=  24 AND age <   60) AND (map < 45) THEN 1
         WHEN (age >=  60 AND age <  144) AND (map < 49) THEN 1
         WHEN (age >= 144 AND age <= 216) AND (map < 52) THEN 1
         ELSE 0 END AS map_points
  FROM vars
)
SELECT *,
  vaso_points + lactate_points + map_points AS phoenix_cardiovascular_score
FROM points;
```

The results of the above query were saved behind the scene to an R
`data.frame` called `card` which will be added to the SQLite database
for inspection later.

``` r
dbWriteTable(conn = con, name = "cardiovascular", value = card)
```

## Coagulation

``` sql
WITH points AS (
  SELECT
    pid,
    CASE WHEN platelets < 100 THEN 1 ELSE 0 END AS plts,
    CASE WHEN inr > 1.3 THEN 1 ELSE 0 END AS inr,
    CASE WHEN d_dimer > 2 THEN 1 ELSE 0 END AS ddm,
    CASE WHEN fibrinogen < 100 THEN 1 ELSE 0 END AS fib
  FROM sepsis
)
SELECT *,
  CASE WHEN plts + inr + ddm + fib >= 2 THEN 2
       ELSE plts + inr + ddm + fib END AS phoenix_coagulation_score
  FROM points
```

The above was stored as an R `data.frame` named `coag` and will be added
to the SQLite database for inspection later.

``` r
dbWriteTable(conn = con, name = "coagulation", value = coag)
```

## Neurologic

``` sql
WITH points AS (
  SELECT
    pid,
    CASE WHEN gcs_total <= 10 THEN 1 ELSE 0 END AS gcs,
    CASE WHEN pupil = "both-fixed" THEN 1 ELSE 0 END AS fixed_pupils
  FROM sepsis
)
SELECT *,
  CASE WHEN fixed_pupils = 1 THEN 2
       WHEN gcs = 1 THEN 1
       ELSE 0 END as phoenix_neurologic_score
  FROM points
```

The above was stored as an R `data.frame` named `neuro` and will be
added to the SQLite database for inspection later.

``` r
dbWriteTable(conn = con, name = "neurologic", value = neuro)
```

## Endocrine

``` sql
SELECT
  pid,
  CASE WHEN glucose <  50 THEN 1
       WHEN glucose > 150 THEN 1
       ELSE 0 END AS phoenix_endocrine_score
FROM sepsis
```

The above was stored as an R `data.frame` named `endo` and will be added
to the SQLite database for inspection later.

``` r
dbWriteTable(conn = con, name = "endocrine", value = endo)
```

## Immunologic

``` sql
SELECT
  pid,
  CASE WHEN anc < 0.500 THEN 1 -- Recall expected units are 1000cells/mm³
       WHEN alc < 1.000 THEN 1 -- Recall expected units are 1000cells/mm³
       ELSE 0 END AS phoenix_immunologic_score
FROM sepsis
```

The above was stored as an R `data.frame` named `immu` and will be added
to the SQLite database for inspection later.

``` r
dbWriteTable(conn = con, name = "immunologic", value = immu)
```

## Renal

``` sql
SELECT
  pid,
  CASE WHEN (age >=   0 AND age <    1) AND (creatinine >= 0.8) THEN 1
       WHEN (age >=   1 AND age <   12) AND (creatinine >= 0.3) THEN 1
       WHEN (age >=  12 AND age <   24) AND (creatinine >= 0.4) THEN 1
       WHEN (age >=  24 AND age <   60) AND (creatinine >= 0.6) THEN 1
       WHEN (age >=  60 AND age <  144) AND (creatinine >= 0.7) THEN 1
       WHEN (age >= 144 AND age <= 216) AND (creatinine >= 1.0) THEN 1
       ELSE 0 END AS phoenix_renal_score
FROM sepsis
```

The above was stored as an R `data.frame` named `renal` and will be
added to the SQLite database for inspection later.

``` r
dbWriteTable(conn = con, name = "renal", value = renal)
```

## Hepatic

``` sql
SELECT
  pid,
  CASE WHEN bilirubin >= 4 THEN 1
       WHEN alt > 102 THEN 1
       ELSE 0 END AS phoenix_hepatic_score
FROM sepsis
```

The above was stored as an R `data.frame` named `hep` and will be added
to the SQLite database for inspection later.

``` r
dbWriteTable(conn = con, name = "hepatic", value = hep)
```

## Phoenix

In R and python we provided wrappers for the total score. Here, we will
join together the results and get the totals. The results of the
following query are saved in an R `data.frame` called `phoenix_scores`.

``` sql
SELECT
  respiratory.pid AS pid,
  phoenix_respiratory_score,
  phoenix_cardiovascular_score,
  phoenix_coagulation_score,
  phoenix_neurologic_score,
  phoenix_respiratory_score + phoenix_cardiovascular_score +
    phoenix_coagulation_score + phoenix_neurologic_score AS phoenix_sepsis_score,
  IIF(phoenix_respiratory_score + phoenix_cardiovascular_score +
    phoenix_coagulation_score + phoenix_neurologic_score >=2, 1, 0) AS phoenix_sepsis,
  IIF(phoenix_respiratory_score + phoenix_cardiovascular_score +
    phoenix_coagulation_score + phoenix_neurologic_score >=2 AND phoenix_cardiovascular_score > 0, 1, 0) AS phoenix_septic_shock
FROM respiratory
LEFT JOIN cardiovascular
ON respiratory.pid = cardiovascular.pid
LEFT JOIN coagulation
ON respiratory.pid = coagulation.pid
LEFT JOIN neurologic
ON respiratory.pid = neurologic.pid
```

``` r
phoenix_scores
##    pid phoenix_respiratory_score phoenix_cardiovascular_score
## 1    1                         0                            2
## 2    2                         3                            2
## 3    3                         3                            1
## 4    4                         0                            0
## 5    5                         0                            0
## 6    6                         3                            1
## 7    7                         3                            4
## 8    8                         0                            0
## 9    9                         3                            3
## 10  10                         3                            0
## 11  11                         3                            3
## 12  12                         1                            0
## 13  13                         0                            0
## 14  14                         2                            2
## 15  15                         3                            3
## 16  16                         0                            2
## 17  17                         2                            2
## 18  18                         3                            2
## 19  19                         2                            2
## 20  20                         0                            1
##    phoenix_coagulation_score phoenix_neurologic_score phoenix_sepsis_score
## 1                          1                        0                    3
## 2                          1                        1                    7
## 3                          2                        0                    6
## 4                          1                        0                    1
## 5                          0                        0                    0
## 6                          2                        1                    7
## 7                          2                        0                    9
## 8                          1                        0                    1
## 9                          1                        1                    8
## 10                         0                        1                    4
## 11                         1                        2                    9
## 12                         0                        0                    1
## 13                         0                        0                    0
## 14                         1                        0                    5
## 15                         2                        0                    8
## 16                         1                        0                    3
## 17                         1                        0                    5
## 18                         2                        0                    7
## 19                         0                        0                    4
## 20                         1                        0                    2
##    phoenix_sepsis phoenix_septic_shock
## 1               1                    1
## 2               1                    1
## 3               1                    1
## 4               0                    0
## 5               0                    0
## 6               1                    1
## 7               1                    1
## 8               0                    0
## 9               1                    1
## 10              1                    0
## 11              1                    1
## 12              0                    0
## 13              0                    0
## 14              1                    1
## 15              1                    1
## 16              1                    1
## 17              1                    1
## 18              1                    1
## 19              1                    1
## 20              1                    1
```

This output is the same as the output generated in R via:

``` r
phoenix_scores_from_r <-
  phoenix(
    # respiratory
      pf_ratio = pao2 / fio2,
      sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
      imv = vent,
      other_respiratory_support = as.integer(fio2 > 0.21),
    # cardiovascular
      vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
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
## 'data.frame':    20 obs. of  8 variables:
##  $ pid                         : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
##  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
##  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
##  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
##  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
##  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
##  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...
str(phoenix_scores_from_r)
## 'data.frame':    20 obs. of  7 variables:
##  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
##  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
##  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
##  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
##  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
##  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
##  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...

identical(phoenix_scores[, -1], phoenix_scores_from_r)
## [1] TRUE
```

## Phoenix 8

For Phoenix 8 you need only four more organ dysfunction scores. The
result of the following query is saved as an R `data.frame` called
`phoenix8_scores`

``` sql
SELECT
  respiratory.pid AS pid,
  phoenix_respiratory_score,
  phoenix_cardiovascular_score,
  phoenix_coagulation_score,
  phoenix_neurologic_score,
  phoenix_respiratory_score + phoenix_cardiovascular_score +
    phoenix_coagulation_score + phoenix_neurologic_score AS phoenix_sepsis_score,
  IIF(phoenix_respiratory_score + phoenix_cardiovascular_score +
    phoenix_coagulation_score + phoenix_neurologic_score >=2, 1, 0) AS phoenix_sepsis,
  IIF(phoenix_respiratory_score + phoenix_cardiovascular_score +
    phoenix_coagulation_score + phoenix_neurologic_score >=2 AND phoenix_cardiovascular_score > 0, 1, 0) AS phoenix_septic_shock,
  phoenix_endocrine_score,
  phoenix_immunologic_score,
  phoenix_renal_score,
  phoenix_hepatic_score,
  phoenix_respiratory_score + phoenix_cardiovascular_score +
    phoenix_coagulation_score + phoenix_neurologic_score  +
    phoenix_endocrine_score + phoenix_immunologic_score +
    phoenix_renal_score + phoenix_hepatic_score AS phoenix8_sepsis_score
FROM respiratory
LEFT JOIN cardiovascular
ON respiratory.pid = cardiovascular.pid
LEFT JOIN coagulation
ON respiratory.pid = coagulation.pid
LEFT JOIN neurologic
ON respiratory.pid = neurologic.pid
LEFT JOIN endocrine
ON respiratory.pid = endocrine.pid
LEFT JOIN immunologic
ON respiratory.pid = immunologic.pid
LEFT JOIN renal
ON respiratory.pid = renal.pid
LEFT JOIN hepatic
ON respiratory.pid = hepatic.pid
```

``` r
phoenix8_scores
##    pid phoenix_respiratory_score phoenix_cardiovascular_score
## 1    1                         0                            2
## 2    2                         3                            2
## 3    3                         3                            1
## 4    4                         0                            0
## 5    5                         0                            0
## 6    6                         3                            1
## 7    7                         3                            4
## 8    8                         0                            0
## 9    9                         3                            3
## 10  10                         3                            0
## 11  11                         3                            3
## 12  12                         1                            0
## 13  13                         0                            0
## 14  14                         2                            2
## 15  15                         3                            3
## 16  16                         0                            2
## 17  17                         2                            2
## 18  18                         3                            2
## 19  19                         2                            2
## 20  20                         0                            1
##    phoenix_coagulation_score phoenix_neurologic_score phoenix_sepsis_score
## 1                          1                        0                    3
## 2                          1                        1                    7
## 3                          2                        0                    6
## 4                          1                        0                    1
## 5                          0                        0                    0
## 6                          2                        1                    7
## 7                          2                        0                    9
## 8                          1                        0                    1
## 9                          1                        1                    8
## 10                         0                        1                    4
## 11                         1                        2                    9
## 12                         0                        0                    1
## 13                         0                        0                    0
## 14                         1                        0                    5
## 15                         2                        0                    8
## 16                         1                        0                    3
## 17                         1                        0                    5
## 18                         2                        0                    7
## 19                         0                        0                    4
## 20                         1                        0                    2
##    phoenix_sepsis phoenix_septic_shock phoenix_endocrine_score
## 1               1                    1                       0
## 2               1                    1                       0
## 3               1                    1                       0
## 4               0                    0                       0
## 5               0                    0                       0
## 6               1                    1                       0
## 7               1                    1                       0
## 8               0                    0                       0
## 9               1                    1                       1
## 10              1                    0                       0
## 11              1                    1                       1
## 12              0                    0                       0
## 13              0                    0                       0
## 14              1                    1                       0
## 15              1                    1                       0
## 16              1                    1                       0
## 17              1                    1                       0
## 18              1                    1                       0
## 19              1                    1                       0
## 20              1                    1                       1
##    phoenix_immunologic_score phoenix_renal_score phoenix_hepatic_score
## 1                          0                   1                     0
## 2                          0                   0                     0
## 3                          1                   0                     1
## 4                          1                   0                     1
## 5                          0                   0                     0
## 6                          1                   1                     0
## 7                          0                   1                     1
## 8                          0                   0                     0
## 9                          0                   1                     1
## 10                         0                   0                     0
## 11                         0                   1                     0
## 12                         0                   0                     0
## 13                         0                   0                     0
## 14                         0                   0                     0
## 15                         0                   1                     1
## 16                         0                   0                     0
## 17                         0                   0                     0
## 18                         0                   1                     1
## 19                         0                   1                     0
## 20                         0                   0                     0
##    phoenix8_sepsis_score
## 1                      4
## 2                      7
## 3                      8
## 4                      3
## 5                      0
## 6                      9
## 7                     11
## 8                      1
## 9                     11
## 10                     4
## 11                    11
## 12                     1
## 13                     0
## 14                     5
## 15                    10
## 16                     3
## 17                     5
## 18                     9
## 19                     5
## 20                     3
phoenix8_scores_r <-
  phoenix8(
    # respiratory
      pf_ratio = pao2 / fio2,
      sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
      imv = vent,
      other_respiratory_support = as.integer(fio2 > 0.21),
    # cardiovascular
      vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
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
## 'data.frame':    20 obs. of  13 variables:
##  $ pid                         : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
##  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
##  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
##  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
##  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
##  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
##  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...
##  $ phoenix_endocrine_score     : int  0 0 0 0 0 0 0 0 1 0 ...
##  $ phoenix_immunologic_score   : int  0 0 1 1 0 1 0 0 0 0 ...
##  $ phoenix_renal_score         : int  1 0 0 0 0 1 1 0 1 0 ...
##  $ phoenix_hepatic_score       : int  0 0 1 1 0 0 1 0 1 0 ...
##  $ phoenix8_sepsis_score       : int  4 7 8 3 0 9 11 1 11 4 ...
str(phoenix8_scores_r)
## 'data.frame':    20 obs. of  12 variables:
##  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
##  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
##  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
##  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
##  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
##  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
##  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...
##  $ phoenix_endocrine_score     : int  0 0 0 0 0 0 0 0 1 0 ...
##  $ phoenix_immunologic_score   : int  0 0 1 1 0 1 0 0 0 0 ...
##  $ phoenix_renal_score         : int  1 0 0 0 0 1 1 0 1 0 ...
##  $ phoenix_hepatic_score       : int  0 0 1 1 0 0 1 0 1 0 ...
##  $ phoenix8_sepsis_score       : int  4 7 8 3 0 9 11 1 11 4 ...

identical(phoenix8_scores[, -1], phoenix8_scores_r)
## [1] TRUE
```

``` r
dbDisconnect(con)
```
