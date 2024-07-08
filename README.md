<!-- README.md is generated from README.Rmd. Please edit that file -->



# phoenix: Phoenix Sepsis and Phoenix-8 Sepsis Criteria <img src="man/figures/hexsticker.png" width="150px" align="right"/>

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/CU-DBMI-Peds/phoenix/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CU-DBMI-Peds/phoenix/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/CU-DBMI-Peds/phoenix/graph/badge.svg?token=PKLXJ9SQOD)](https://app.codecov.io/gh/CU-DBMI-Peds/phoenix)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/phoenix)](https://cran.r-project.org/package=phoenix)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/phoenix)](https://www.r-pkg.org/pkg/phoenix)

Implementation of the Phoenix and Phoenix-8 Sepsis Criteria as
described in:

* ["Development and Validation of the Phoenix Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0196) by Sanchez-Pinto&ast;, Bennett&ast;, DeWitt&ast;&ast;, Russell&ast;&ast; et al. (2024)

  * <small> &ast; Drs Sanchez-Pinto and Bennett contributed equally; &ast;&ast; Dr DeWitt and Mr Russell contributed equally.</small>

* ["International Consensus Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0179) by Schlapbach, Watson, Sorce, et al. (2024).

The best overview for this package is the R vignette which you can view locally
after installing the R package via
```r
vignette("phoenix")
```
or you can read it online
[here](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.html)

The Phoenix Criteria have been implemented in

* an R package,
* a Python module, and
* example SQL queries.

The repository has been built with R as the primary and default language.

## Citation
If you use this package in your work, please cite the Phoenix criteria by citing
the two JAMA papers.  Please cite this code base by citing the application note,
and if using the R package, cite it explicitly as well.

    Peter E DeWitt, Seth Russell, Margaret N Rebull, L Nelson Sanchez-Pinto, Tellen
    D Bennett, phoenix: an R package and Python module for calculating the Phoenix
    pediatric sepsis score and criteria, JAMIA Open, Volume 7, Issue 3, October
    2024, ooae066, [doi:10.1093/jamiaopen/ooae066](doi:10.1093/jamiaopen/ooae066)

Bibtex formatted citations can be retrieved within R via

``` r
# Manuscripts
print(citation("phoenix"), bibtex = TRUE)

# R package
print(citation("phoenix", auto = TRUE), bibtex = TRUE)
```
Or in this repo from the file
[`inst/CITATION`](https://github.com/CU-DBMI-Peds/phoenix/blob/main/inst/CITATION)


## R

### Install

#### From CRAN
Install the current release from the Comprehensive R Archive Network (CRAN).
Within R call:

``` r
install.packages("phoenix", repos = "https://cran.rstudio.com")
```

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

### Examples

Details on the Phoenix criteria and the use of the R package can be found in the
manual for the package, the
[Get started](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.html) on
the website, or the vignette within R

``` r
vignette("phoenix")
```

## Python

A python module is available on PyPi.  You can install it via `pip`


``` python
pip install phoenix-sepsis
```


### Examples

Read the article [The Phoenix Septic Criteria in Python](https://cu-dbmi-peds.github.io/phoenix/articles/python.html)
for details and examples of using the python code as is.

## SQL

Read [The Phoenix Sepsis Criteria in SQL](https://cu-dbmi-peds.github.io/phoenix/articles/sql.html)
article for details and examples of implementing the scoring rubrics in SQL.
These examples are done in SQLite but will be easily translated into other SQL
dialects.

