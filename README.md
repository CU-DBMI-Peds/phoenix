<!-- README.md is generated from README.Rmd. Please edit that file -->



# phoenix: Phoenix Sepsis and Phoenix-8 Sepsis Criteria <img src="man/figures/phoenix_hex.png" width="150px" align="right"/>

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/CU-DBMI-Peds/phoenix/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CU-DBMI-Peds/phoenix/actions/workflows/R-CMD-check.yaml)
[![codecov](https://app.codecov.io/gh/CU-DBMI-Peds/phoenix/graph/badge.svg?token=PKLXJ9SQOD)](https://app.codecov.io/gh/CU-DBMI-Peds/phoenix)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/phoenix)](https://cran.r-project.org/package=phoenix)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/phoenix)](http://www.r-pkg.org/pkg/phoenix)

Implementation of the Phoenix and Phoenix-8 Sepsis Criteria as
described in:

* ["Development and Validation of the Phoenix Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0196) by Sanchez-Pinto, Bennett, DeWitt, Russell et.al. (2024)

* ["International Consensus Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0179) by Schlapbach, Watson, Sorce, et.al. (2024).

The best overview for this package is the R vignette which you can view locally
after installing the R package via
```r
vignette("phoenix")
```
or you can read it online
[here](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.html)

The Phoenix Criteria has been implemented as an

* R package
* python module
* SQL queries

The repository has been built with R as the primary and default language.

## R

### Install

#### From CRAN
This package is not yet on CRAN - it will be soon!

#### Developmental
Install the development version of `phoenix` directly from github via the
[`remotes`](https://github.com/r-lib/remotes/) package:

    if (!("remotes" %in% rownames(installed.packages()))) {
      warning("installing remotes from https://cran.rstudio.com")
      install.packages("remotes", repo = "https://cran.rstudio.com")
    }

    remotes::install_github("cu-dbmi-peds/phoenix")

*NOTE:* If you are working on a Windows machine you will need to download and
install [`Rtools`](https://cran.r-project.org/bin/windows/Rtools/).

### Use

The package comes with an example data set call `sepsis.`  To get the Phoenix
score and determine sepsis (score &geq; 2) and septic shock (score &geq; 2 and
cardiovascular dysfunction, just call the `phoenix` function:


```r
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
#> 'data.frame':	20 obs. of  7 variables:
#>  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
#>  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
#>  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
#>  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
#>  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
#>  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
#>  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...
# 'data.frame':	20 obs. of  7 variables:
#  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
#  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
#  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
#  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
#  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
#  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
#  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...
```

## python

The subdirectory `python` provided a module and example use.  It is our goal to
make this python code more robust and distribute it via PyPI soon.

You can read the article [The Phoenix Septic Criteria in python](https://cu-dbmi-peds.github.io/phoenix/articles/python.html)
for details and examples of using the python code as is.




```python
import numpy as np
import pandas as pd
import python.phoenix as phx
sepsis = pd.read_csv("./python/sepsis.csv")

phx.phoenix(
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
#>     phoenix_respiratory_score  phoenix_cardiovascular_score  phoenix_coagulation_score  phoenix_neurologic_score  phoenix_sepsis_score  phoenix_sepsis  phoenix_septic_shock
#> 0                           3                             2                          1                         0                     6               1                     1
#> 1                           3                             2                          1                         1                     7               1                     1
#> 2                           3                             1                          2                         0                     6               1                     1
#> 3                           0                             0                          1                         0                     1               0                     0
#> 4                           0                             0                          0                         0                     0               0                     0
#> 5                           3                             1                          2                         1                     7               1                     1
#> 6                           3                             4                          2                         0                     9               1                     1
#> 7                           0                             0                          1                         0                     1               0                     0
#> 8                           3                             3                          1                         1                     8               1                     1
#> 9                           3                             0                          0                         1                     4               1                     0
#> 10                          3                             3                          1                         2                     9               1                     1
#> 11                          1                             0                          0                         0                     1               0                     0
#> 12                          0                             0                          0                         0                     0               0                     0
#> 13                          2                             2                          1                         0                     5               1                     1
#> 14                          3                             3                          2                         0                     8               1                     1
#> 15                          0                             2                          1                         0                     3               1                     1
#> 16                          2                             2                          1                         0                     5               1                     1
#> 17                          3                             2                          2                         0                     7               1                     1
#> 18                          2                             2                          0                         0                     4               1                     1
#> 19                          0                             1                          1                         0                     2               1                     1
```


## SQL

Read [The Phoenix Sepsis Criteria in SQL](https://cu-dbmi-peds.github.io/phoenix/articles/sql.html)
article for details and examples of implementing the scoring rubrics in SQL.
These examples are done in SQLite but will be easily translated into other SQL
dialects.

