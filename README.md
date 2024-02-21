# phoenix: Phoenix Sepsis and Phoenix-8 Sepsis Criteria <img src="man/figures/phoenix_hex.png" width="150px" align="right"/>

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/dewittpe/phoenix/workflows/R-CMD-check/badge.svg)](https://github.com/dewittpe/phoenix/actions)
[![Coverage Status](https://img.shields.io/codecov/c/github/dewittpe/phoenix/master.svg)](https://app.codecov.io/github/dewittpe/phoenix?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/phoenix)](https://cran.r-project.org/package=phoenix)
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
[here](https://www.peteredewitt.com/phoenix/articles/phoenix.html)


The Phoenix Criteria has been implemented as an

* R package
* python module

The repository has been built with R as the primary and default language.

## R

### Install

#### From CRAN
This package is not yet on CRAN - it will be soon!

#### Developmental
Install the development version of `phoenix` directly from github via the
[`remotes`](https://github.com/hadley/remotes/) package:

    if (!("remotes" %in% rownames(installed.packages()))) {
      warning("installing remotes from https://cran.rstudio.com")
      install.packages("remotes", repo = "https://cran.rstudio.com")
    }

    remotes::install_github("dewittpe/phoenix")

*NOTE:* If you are working on a Windows machine you will need to download and
install [`Rtools`](https://cran.r-project.org/bin/windows/Rtools/).

## python

The subdirectory `python` provided a module and example use.  It is our goal to
make this python code more robust and distribute it via pypy soon.


