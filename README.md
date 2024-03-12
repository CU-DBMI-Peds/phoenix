<!-- README.md is generated from README.Rmd. Please edit that file -->



# phoenix: Phoenix Sepsis and Phoenix-8 Sepsis Criteria <img src="man/figures/phoenix_hex.png" width="150px" align="right"/>

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/CU-DBMI-Peds/phoenix/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CU-DBMI-Peds/phoenix/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/CU-DBMI-Peds/phoenix/graph/badge.svg?token=PKLXJ9SQOD)](https://app.codecov.io/gh/CU-DBMI-Peds/phoenix)
<!--
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/phoenix)](https://cran.r-project.org/package=phoenix)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/phoenix)](http://www.r-pkg.org/pkg/phoenix)
-->

Implementation of the Phoenix and Phoenix-8 Sepsis Criteria as
described in:

* ["Development and Validation of the Phoenix Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0196) by Sanchez-Pinto&ast;, Bennett&ast;, DeWitt&ast;&ast;, Russell&ast;&ast; et al. (2024)

  * <small> &ast; Drs Sanchez-Pinto and Bennett contributed equally; &ast;&ast; Dr DeWitt and Mr Russel contributed equally.</small>

* ["International Consensus Criteria for Pediatric Sepsis and Septic Shock"](doi:10.1001/jama.2024.0179) by Schlapbach, Watson, Sorce, et al. (2024).

The best overview for this package is the R vignette which you can view locally
after installing the R package via
```r
vignette("phoenix")
```
or you can read it online
[here](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.html)

The Phoenix Criteria have been implemented as in a

* R package,
* Python module, and
* example SQL queries.

The repository has been built with R as the primary and default language.

## Citation
If you use this package in your work, please cite the Phoenix criteria by citing
the two JAMA papers.  Please cite this code base by citing the research letter,
and if using the R package, cite it explicitly as well.


```r
# Manuscripts
print(citation("phoenix"), bibtex = TRUE)
#> There are two references to cite the Phoenix criteria:
#> 
#> 1) Sanchez-Pinto, Bennett, DeWitt, Russell, et al. (2024); and
#> 
#> 2) Schlapbach, Watson, Sorce, Argent, et al. (2024).
#> 
#> There are two references to cite for the R package itself:
#> 
#> 1) DeWitt et al. (2024) (in press and will be updated soon); and
#> 
#> 2) the result of evaluating `citation('phoenix', auto = FALSE)`
#> 
#>   Sanchez-Pinto, Nelson L, Bennett, D. T, DeWitt, E. P, Russell, Seth,
#>   Rebull, N. M, Martin, Blake, Akech, Samuel, Albers, J. D, Alpern, R.
#>   E, Balamuth, Fran, Bembea, Melania, Chisti, Jobayer M, Evans, Idris,
#>   Horvat, M. C, Jaramillo-Bustamante, Camilo J, Kissoon, Niranjan,
#>   Menon, Kusum, Scott, F. H, Weiss, L. S, Wiens, O. M, Zimmerman, J. J,
#>   Argent, C. A, Sorce, R. L, Schlapbach, J. L, Watson, Scott R, Force
#>   SoCCMPSDT (2024). "Development and Validation of the Phoenix Criteria
#>   for Pediatric Sepsis and Septic Shock." _JAMA_, *331*(8), 675-686.
#>   ISSN 0098-7484, doi:10.1001/jama.2024.0196
#>   <https://doi.org/10.1001/jama.2024.0196>, Drs Sanchez-Pinto and
#>   Bennett contributed equally. Drs DeWitt and Mr Russell contributed
#>   equally. Drs Argent, Sorce, Schlapbach, and Watson contributed
#>   equally.,
#>   https://jamanetwork.com/journals/jama/articlepdf/2814296/jama_sanchezpinto_2024_oi_240003_1709591810.56162.pdf,
#>   <https://doi.org/10.1001/jama.2024.0196>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Article{,
#>     author = {{Sanchez-Pinto} and L. Nelson and {Bennett} and Tellen D. and {DeWitt} and Peter E. and {Russell} and {Seth} and {Rebull} and Margaret N. and {Martin} and {Blake} and {Akech} and {Samuel} and {Albers} and David J. and {Alpern} and Elizabeth R. and {Balamuth} and {Fran} and {Bembea} and {Melania} and {Chisti} and Mohammod Jobayer and {Evans} and {Idris} and {Horvat} and Christopher M. and {Jaramillo-Bustamante} and Juan Camilo and {Kissoon} and {Niranjan} and {Menon} and {Kusum} and {Scott} and Halden F. and {Weiss} and Scott L. and {Wiens} and Matthew O. and {Zimmerman} and Jerry J. and {Argent} and Andrew C. and {Sorce} and Lauren R. and {Schlapbach} and Luregn J. and {Watson} and R. Scott and Society of Critical Care Medicine Pediatric Sepsis Definition Task Force},
#>     title = {Development and Validation of the Phoenix Criteria for Pediatric Sepsis and Septic Shock},
#>     journal = {JAMA},
#>     volume = {331},
#>     number = {8},
#>     pages = {675-686},
#>     year = {2024},
#>     month = {02},
#>     abstract = {The Society of Critical Care Medicine Pediatric Sepsis Definition Task Force sought to develop and validate new clinical criteria for pediatric sepsis and septic shock using measures of organ dysfunction through a data-driven approach.To derive and validate novel criteria for pediatric sepsis and septic shock across differently resourced settings.Multicenter, international, retrospective cohort study in 10 health systems in the US, Colombia, Bangladesh, China, and Kenya, 3 of which were used as external validation sites. Data were collected from emergency and inpatient encounters for children (aged \&lt;18 years) from 2010 to 2019: 3 049 699 in the development (including derivation and internal validation) set and 581 317 in the external validation set.Stacked regression models to predict mortality in children with suspected infection were derived and validated using the best-performing organ dysfunction subscores from 8 existing scores. The final model was then translated into an integer-based score used to establish binary criteria for sepsis and septic shock.The primary outcome for all analyses was in-hospital mortality. Model- and integer-based score performance measures included the area under the precision recall curve (AUPRC; primary) and area under the receiver operating characteristic curve (AUROC; secondary). For binary criteria, primary performance measures were positive predictive value and sensitivity.Among the 172 984 children with suspected infection in the first 24 hours (development set; 1.2\% mortality), a 4-organ-system model performed best. The integer version of that model, the Phoenix Sepsis Score, had AUPRCs of 0.23 to 0.38 (95\% CI range, 0.20-0.39) and AUROCs of 0.71 to 0.92 (95\% CI range, 0.70-0.92) to predict mortality in the validation sets. Using a Phoenix Sepsis Score of 2 points or higher in children with suspected infection as criteria for sepsis and sepsis plus 1 or more cardiovascular point as criteria for septic shock resulted in a higher positive predictive value and higher or similar sensitivity compared with the 2005 International Pediatric Sepsis Consensus Conference (IPSCC) criteria across differently resourced settings.The novel Phoenix sepsis criteria, which were derived and validated using data from higher- and lower-resource settings, had improved performance for the diagnosis of pediatric sepsis and septic shock compared with the existing IPSCC criteria.},
#>     issn = {0098-7484},
#>     doi = {10.1001/jama.2024.0196},
#>     url = {https://doi.org/10.1001/jama.2024.0196},
#>     eprint = {https://jamanetwork.com/journals/jama/articlepdf/2814296/jama_sanchezpinto_2024_oi_240003_1709591810.56162.pdf},
#>     note = {Drs Sanchez-Pinto and Bennett contributed equally. Drs DeWitt and Mr Russell contributed equally. Drs Argent, Sorce, Schlapbach, and Watson contributed equally.},
#>   }
#> 
#>   Schlapbach, J. L, Watson, Scott R, Sorce, R. L, Argent, C. A, Menon,
#>   Kusum, Hall, W. M, Akech, Samuel, Albers, J. D, Alpern, R. E,
#>   Balamuth, Fran, Bembea, Melania, Biban, Paolo, Carrol, D. E, Chiotos,
#>   Kathleen, Chisti, Jobayer M, DeWitt, E. P, Evans, Idris, de Oliveira
#>   F, Cláudio, Horvat, M. C, Inwald, David, Ishimine, Paul,
#>   Jaramillo-Bustamante, Camilo J, Levin, Michael, Lodha, Rakesh,
#>   Martin, Blake, Nadel, Simon, Nakagawa, Satoshi, Peters, J. M,
#>   Randolph, G. A, Ranjit, Suchitra, Rebull, N. M, Russell, Seth, Scott,
#>   F. H, de Souza, Carla D, Tissieres, Pierre, Weiss, L. S, Wiens, O. M,
#>   Wynn, L. J, Kissoon, Niranjan, Zimmerman, J. J, Sanchez-Pinto, Nelson
#>   L, Bennett, D. T, Force SoCCMPSDT (2024). "International Consensus
#>   Criteria for Pediatric Sepsis and Septic Shock." _JAMA_, *331*(8),
#>   665-674. ISSN 0098-7484, doi:10.1001/jama.2024.0179
#>   <https://doi.org/10.1001/jama.2024.0179>, Drs Schlapbach, Watson,
#>   Sorce, and Argent contributed equally. Drs Sanchez-Pinto and Bennett
#>   contributed equally.,
#>   https://jamanetwork.com/journals/jama/articlepdf/2814297/jama_schlapbach_2024_oi_240002_1708641862.24494.pdf,
#>   <https://doi.org/10.1001/jama.2024.0179>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Article{,
#>     author = {{Schlapbach} and Luregn J. and {Watson} and R. Scott and {Sorce} and Lauren R. and {Argent} and Andrew C. and {Menon} and {Kusum} and {Hall} and Mark W. and {Akech} and {Samuel} and {Albers} and David J. and {Alpern} and Elizabeth R. and {Balamuth} and {Fran} and {Bembea} and {Melania} and {Biban} and {Paolo} and {Carrol} and Enitan D. and {Chiotos} and {Kathleen} and {Chisti} and Mohammod Jobayer and {DeWitt} and Peter E. and {Evans} and {Idris} and Flauzino {de Oliveira} and {Cláudio} and {Horvat} and Christopher M. and {Inwald} and {David} and {Ishimine} and {Paul} and {Jaramillo-Bustamante} and Juan Camilo and {Levin} and {Michael} and {Lodha} and {Rakesh} and {Martin} and {Blake} and {Nadel} and {Simon} and {Nakagawa} and {Satoshi} and {Peters} and Mark J. and {Randolph} and Adrienne G. and {Ranjit} and {Suchitra} and {Rebull} and Margaret N. and {Russell} and {Seth} and {Scott} and Halden F. and {de Souza} and Daniela Carla and {Tissieres} and {Pierre} and {Weiss} and Scott L. and {Wiens} and Matthew O. and {Wynn} and James L. and {Kissoon} and {Niranjan} and {Zimmerman} and Jerry J. and {Sanchez-Pinto} and L. Nelson and {Bennett} and Tellen D. and Society of Critical Care Medicine Pediatric Sepsis Definition Task Force},
#>     title = {International Consensus Criteria for Pediatric Sepsis and Septic Shock},
#>     journal = {JAMA},
#>     volume = {331},
#>     number = {8},
#>     pages = {665-674},
#>     year = {2024},
#>     month = {02},
#>     abstract = {Sepsis is a leading cause of death among children worldwide. Current pediatric-specific criteria for sepsis were published in 2005 based on expert opinion. In 2016, the Third International Consensus Definitions for Sepsis and Septic Shock (Sepsis-3) defined sepsis as life-threatening organ dysfunction caused by a dysregulated host response to infection, but it excluded children.To update and evaluate criteria for sepsis and septic shock in children.The Society of Critical Care Medicine (SCCM) convened a task force of 35 pediatric experts in critical care, emergency medicine, infectious diseases, general pediatrics, nursing, public health, and neonatology from 6 continents. Using evidence from an international survey, systematic review and meta-analysis, and a new organ dysfunction score developed based on more than 3 million electronic health record encounters from 10 sites on 4 continents, a modified Delphi consensus process was employed to develop criteria.Based on survey data, most pediatric clinicians used sepsis to refer to infection with life-threatening organ dysfunction, which differed from prior pediatric sepsis criteria that used systemic inflammatory response syndrome (SIRS) criteria, which have poor predictive properties, and included the redundant term, severe sepsis. The SCCM task force recommends that sepsis in children be identified by a Phoenix Sepsis Score of at least 2 points in children with suspected infection, which indicates potentially life-threatening dysfunction of the respiratory, cardiovascular, coagulation, and/or neurological systems. Children with a Phoenix Sepsis Score of at least 2 points had in-hospital mortality of 7.1\% in higher-resource settings and 28.5\% in lower-resource settings, more than 8 times that of children with suspected infection not meeting these criteria. Mortality was higher in children who had organ dysfunction in at least 1 of 4—respiratory, cardiovascular, coagulation, and/or neurological—organ systems that was not the primary site of infection. Septic shock was defined as children with sepsis who had cardiovascular dysfunction, indicated by at least 1 cardiovascular point in the Phoenix Sepsis Score, which included severe hypotension for age, blood lactate exceeding 5 mmol/L, or need for vasoactive medication. Children with septic shock had an in-hospital mortality rate of 10.8\% and 33.5\% in higher- and lower-resource settings, respectively.The Phoenix sepsis criteria for sepsis and septic shock in children were derived and validated by the international SCCM Pediatric Sepsis Definition Task Force using a large international database and survey, systematic review and meta-analysis, and modified Delphi consensus approach. A Phoenix Sepsis Score of at least 2 identified potentially life-threatening organ dysfunction in children younger than 18 years with infection, and its use has the potential to improve clinical care, epidemiological assessment, and research in pediatric sepsis and septic shock around the world.},
#>     issn = {0098-7484},
#>     doi = {10.1001/jama.2024.0179},
#>     url = {https://doi.org/10.1001/jama.2024.0179},
#>     eprint = {https://jamanetwork.com/journals/jama/articlepdf/2814297/jama_schlapbach_2024_oi_240002_1708641862.24494.pdf},
#>     note = {Drs Schlapbach, Watson, Sorce, and Argent contributed equally. Drs Sanchez-Pinto and Bennett contributed equally.},
#>   }

# R package
print(citation("phoenix", auto = TRUE), bibtex = TRUE)
#> Warning in citation("phoenix", auto = TRUE): could not determine year for
#> 'phoenix' from package DESCRIPTION file
#> To cite package 'phoenix' in publications use:
#> 
#>   DeWitt P (????). _phoenix: Phoenix Sepsis Criteria_. R package
#>   version 0.0.0.9001, <https://github.com/CU-DBMI-Peds/phoenix/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {phoenix: Phoenix Sepsis Criteria},
#>     author = {Peter DeWitt},
#>     note = {R package version 0.0.0.9001},
#>     url = {https://github.com/CU-DBMI-Peds/phoenix/},
#>   }
```


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

The package comes with an example data set called `sepsis.`  To get the Phoenix
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
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
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
#> 0                           0                             2                          1                         0                     3               1                     1
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

