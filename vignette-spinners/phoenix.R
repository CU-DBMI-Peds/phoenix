#'---
#'title: "Phoenix Sepsis Score"
#'output:
#'  rmarkdown::html_vignette:
#'    toc: true
#'    number_sections: false
#'bibliography: references.bib
#'vignette: >
#'  %\VignetteIndexEntry{Phoenix Sepsis Score}
#'  %\VignetteEngine{knitr::rmarkdown}
#'  %\VignetteEncoding{UTF-8}
#'---
#'
#+ label = "setup", include = FALSE
library(qwraps2)
options(qwraps2_markup = "markdown")
knitr::opts_chunk$set(collapse = TRUE)
#'
# /*
devtools::load_all()
# */
library(phoenix)
packageVersion("phoenix")

#'
#' The of the diagnostic Phoenix Sepsis Criteria developed in
#' [@sanchez_2024_development](https://doi.org/10.1001/jama.2024.0196) and
#' [@schlapback_2024_international](https://doi.org/10.1001/jama.2024.0179) is
#' implimented in this package.
#'
#' # The Phoenix Sepsis Criteria
#'
#' The diagnostic Phoenix Sepsis Criteria is defined by dysfuntion in four organ
#' systems:
#'
#' |        | 0 Points | 1 Point | 2 Points | 3 Points |
#' |:-------|:-------- |:------- |:-------- |:-------- |
#' |**Respiratory** (0-3 points) | PaO<sub>2</sub>:FiO<sub>2</sub> &geq; 400 and SpO<sub>2</sub>:FiO<sub>2</sub> &geq; 292 | (PaO<sub>2</sub>:FiO<sub>2</sub> &lt; 400 or SpO<sub>2</sub>:FiO<sub>2</sub> &lt; 292) and any respiratory support | (PaO<sub>2</sub>:FiO<sub>2</sub> &lt; 200 or SpO<sub>2</sub>:FiO<sub>2</sub> &lt; 220) and IMV | (PaO<sub>2</sub>:FiO<sub>2</sub> &lt; 100 or SpO<sub>2</sub>:FiO<sub>2</sub> &lt; 148) and IMV |
#' |**Cardiovascular** (0-6 points) |
#' |&nbsp;&nbsp; _Vasoactive Medications_ | No medications | 1 medictation | 2 or more medictations |
#' |&nbsp;&nbsp; _Lactate_ | [0, 5) mmol/L | [5, 11) mmol/L | [11, &infin;) mmol/L |
#' |&nbsp;&nbsp; _MAP_ | | | |
#' |&nbsp;&nbsp;&nbsp;&nbsp;   0 &leq; Age <   1 | [31, &infin;) mmHg | [17, 31) mmHg | [0, 17) mmHg |
#' |&nbsp;&nbsp;&nbsp;&nbsp;   1 &leq; Age <  12 | [39, &infin;) mmHg | [25, 39) mmHg | [0, 25) mmHg |
#' |&nbsp;&nbsp;&nbsp;&nbsp;  12 &leq; Age <  24 | [44, &infin;) mmHg | [31, 44) mmHg | [0, 31) mmHg |
#' |&nbsp;&nbsp;&nbsp;&nbsp;  24 &leq; Age <  60 | [45, &infin;) mmHg | [32, 45) mmHg | [0, 32) mmHg |
#' |&nbsp;&nbsp;&nbsp;&nbsp;  60 &leq; Age < 144 | [49, &infin;) mmHg | [36, 49) mmHg | [0, 36) mmHg |
#' |&nbsp;&nbsp;&nbsp;&nbsp; 144 &leq; Age       | [52, &infin;) mmHg | [38, 52) mmHg | [0, 38) mmHg |
#' |**Coagulation** (0-2 points) | | 1 point each; max 2 |
#' |&nbsp;&nbsp; Platelets  | [100, &infin;) K/&mu;L | [0, 100) K/&mu;L |
#' |&nbsp;&nbsp; INR        | [0 , 1.3] | [1.3, &infin;) |
#' |&nbsp;&nbsp; D-Dimer    | [0, 2] mg/L FEU | (2, &infin;) mg/L FEU |
#' |&nbsp;&nbsp; Fibrinogen | [100, &infin;) mg/dL | [0, 100) mg/dL |
#' |**Neurologic** (0-2 points) | GCS &#8712; {11, 12, 13, 14, 15} | GCS &#8712; {3, 4, ..., 10} | Bilarterally fixed pupils |
#' <small>
#' * IMV: invasive mechanical ventalation</br>
#' * Age: measured in months</br>
#' * MAP: mean arterial pressure</br>
#' </small>
#'
#' A total score of 2 or more points is needed to diagnosis pediatric sepsis.
#'
#' # The Phoenix 8 Criteria
#'
#' This extended criteria uses the four organ systems above along with four additional organ dysfunction scores.
#'
#'
#' |        | 0 Points | 1 Point |
#' |:-------|:-------- |:------- |
#' |**Endocrine** (0-1 point) | blood glucose &#8712; [50, 150] mg/dL | blood glucose &#8713; [50, 150] mg/dL |
#' |**Immunologic** (0-1 point) | ANC &geq; 500 and ALC &geq; 1000 cells /mm<sup>3</sup> | ANC &lt; 500 and/or ALC &lt; 1000 cells/mm<sup>3</sup> |
#' |**Renal** (0-1 point) |
#' |&nbsp;&nbsp;   0 &leq; Age <   1 | Creatinine &lt; 0.8 mg/dL | Creatinine &geq; 0.8 mg/dL |
#' |&nbsp;&nbsp;   1 &leq; Age <  12 | Creatinine &lt; 0.3 mg/dL | Creatinine &geq; 0.3 mg/dL |
#' |&nbsp;&nbsp;  12 &leq; Age <  24 | Creatinine &lt; 0.4 mg/dL | Creatinine &geq; 0.4 mg/dL |
#' |&nbsp;&nbsp;  24 &leq; Age <  60 | Creatinine &lt; 0.6 mg/dL | Creatinine &geq; 0.6 mg/dL |
#' |&nbsp;&nbsp;  60 &leq; Age < 144 | Creatinine &lt; 0.7 mg/dL | Creatinine &geq; 0.7 mg/dL |
#' |&nbsp;&nbsp; 144 &leq; Age       | Creatinine &lt; 1.0 mg/dL | Creatinine &geq; 1.0 mg/dL |
#' |**Hepatic** (0-1 point) | Total bilirubin &lt; 4 mg/dL and ALT &gt; 102 IU/L | Total bilirubin %geq; 4 mg/dL and/or ALT &gt; 102 IU/L |
#' <small>
#' * Age: measured in months</br>
#' </small>
#'
#' # Development of the Criteria
#'
#' Details on the developed of the criteria are discribed in
#' @sanchez_2024_development and @schlapback_2024_international and end users
#' are encouraged to review these papers.  A couple quick notes about the data
#' and use in general.  Some specific deatils will be provided in each of the
#' sections for each organ system.
#'
#' *Missing data = 0 points*: During the development of the Phoenix criteria
#' missing data was mapped to zero points. This was done as it was reasonable to
#' assume that for some labs and metrics, missing data could indicate that there
#' was no concern and the testing was not order.  Further, the Phoenix criteria
#' was developed to be useful in both high, medium, and low resource settings
#' where some labs and values migth be uncommon or impossible to get.  As such,
#' we encourage end users of this package to do the same - missing values are
#' missing and should not be imputed.
#'
#' *Worst in first 24 hours*: The score was developed on the worse measured
#' value during the first 24 hours of an hospital encounter.  But this was also
#' done on a variable by variable basis.  For example, say one 54 month old
#' patient had the following cardiovascular scores:
#'
#' | time from admission | vasoactive medications | lacate  | MAP     |
#' | :--------:          | :-----:                | :-----: | :-----: |
#' | 0                   |                        |         | 55      |
#' | 20                  |                        |         | 55      |
#' | 120                 |                        |         | 55      |
#' | 382                 |                        |         | 55      |
#'
#' # Package Use
#'
#' There are functions to apply the Phoenix criteria to a data set for each of the organ systems and wrapers for full Phoenix and Phoenix-8 scores.
#'
#' ## Respiratory
#'
#'
#'
#' # References
#'<div id="refs"></div>
#'
#' # Session Info
#+ label = "sessioninfo"
sessionInfo()

# /* ---------------------------- END OF FILE ------------------------------- */
