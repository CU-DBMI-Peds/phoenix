# phoenix: Phoenix Sepsis and Phoenix-8 Spesis Criteria <img src="man/figures/phoenix_hex.png" width="150px" align="right"/>

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/dewittpe/phoenix/workflows/R-CMD-check/badge.svg)](https://github.com/dewittpe/phoenix/actions)
[![Coverage Status](https://img.shields.io/codecov/c/github/dewittpe/phoenix/master.svg)](https://app.codecov.io/github/dewittpe/phoenix?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/phoenix)](https://cran.r-project.org/package=phoenix)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/phoenix)](http://www.r-pkg.org/pkg/phoenix)

Implementation of the Phoenix and Phoenix-8 Sepsis Criteria as
described in ["Development and Validation of the Phoenix Criteria for
Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0196) by
Sanchez-Pinto, Bennett, DeWitt, Russell et.al. (2024) and
["International Consensus Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0179) by
Schlapback, Watson, Sorce, et.al. (2024).

## Install

### From CRAN
This package is not yet on CRAN - it will be soon!

### Developmental
Install the development version of `phoenix` directly from github via the
[`remotes`](https://github.com/hadley/remotes/) package:

    if (!("remotes" %in% rownames(installed.packages()))) {
      warning("installing remotes from https://cran.rstudio.com")
      install.packages("remotes", repo = "https://cran.rstudio.com")
    }

    remotes::install_github("dewittpe/phoenix")

*NOTE:* If you are working on a Windows machine you will need to download and
install [`Rtools`](https://cran.r-project.org/bin/windows/Rtools/).
