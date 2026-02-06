# Phoenix Cardiovascular Score

Generate the cardiovascular organ system dysfunction score as part of
the diagnostic Phoenix Sepsis Criteria.

## Usage

``` r
phoenix_cardiovascular(
  vasoactives = NA_integer_,
  lactate = NA_real_,
  age = NA_real_,
  map = NA_real_,
  data = parent.frame(),
  ...
)
```

## Arguments

- vasoactives:

  an integer vector, the number of systemic vasoactive medications being
  administered to the patient. Six vasoactive medications are
  considered: dobutamine, dopamine, epinephrine, milrinone,
  norepinephrine, vasopressin.

- lactate:

  numeric vector with the lactate value in mmol/L

- age:

  numeric vector age in months

- map:

  numeric vector, mean arterial pressure in mmHg

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

a integer vector with values 0, 1, 2, 3, 4, 5, or 6.

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Details

There were six systemic vasoactive medications considered when the
Phoenix criteria was developed: dobutamine, dopamine, epinephrine,
milrinone, norepinephrine, and vasopressin.

During development, the values used for `map` were taken preferentially
from arterial measurement, then cuff measures, and provided values
before approximating the map from blood pressure values via DBP + 1/3
(SBP - DBP), where DBP is the diastolic blood pressure and SBP is the
systolic blood pressure.

## Phoenix Cardiovascular Scoring

The Phoenix Cardiovascular score ranges from 0 to 6 points; 0, 1, or 2
points for each of systemic vasoactive medications, lactate, and MAP.

*Systemic Vasoactive Medications*

|                       |          |
|-----------------------|----------|
| 0 medications         | 0 points |
| 1 medication          | 1 point  |
| 2 or more medications | 2 points |

*Lactate*

|            |          |
|------------|----------|
| \[0, 5)    | 0 points |
| \[5, 11)   | 1 point  |
| \[11, Inf) | 2 points |

*MAP*

|                            |                 |          |
|----------------------------|-----------------|----------|
| Age in \[0, 1) months      |                 |          |
|                            | \[31, Inf) mmHg | 0 points |
|                            | \[17, 31) mmHg  | 1 point  |
|                            | \[0, 17) mmHg   | 2 points |
| Age in \[1, 12) months     |                 |          |
|                            | \[39, Inf) mmHg | 0 points |
|                            | \[25, 39) mmHg  | 1 point  |
|                            | \[0, 25) mmHg   | 2 points |
| Age in \[12, 24) months    |                 |          |
|                            | \[44, Inf) mmHg | 0 points |
|                            | \[31, 44) mmHg  | 1 point  |
|                            | \[0, 31) mmHg   | 2 points |
| Age in \[24, 60) months    |                 |          |
|                            | \[45, Inf) mmHg | 0 points |
|                            | \[32, 45) mmHg  | 1 point  |
|                            | \[0, 32) mmHg   | 2 points |
| Age in \[60, 144) months   |                 |          |
|                            | \[49, Inf) mmHg | 0 points |
|                            | \[36, 49) mmHg  | 1 point  |
|                            | \[0, 36) mmHg   | 2 points |
| Age in \[144, 216\] months |                 |          |
|                            | \[52, Inf) mmHg | 0 points |
|                            | \[38, 52) mmHg  | 1 point  |
|                            | \[0, 38) mmHg   | 2 points |

## References

See reference details in
[`phoenix-package`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix-package.md)
or by calling `citation('phoenix')`.

## See also

- [`phoenix`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix.md)
  for generating the diagnostic Phoenix Sepsis score based on the four
  organ systems:

  - `phoenix_cardiovascular`,

  - [`phoenix_coagulation`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_coagulation.md),

  - [`phoenix_neurologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_neurologic.md),

  - [`phoenix_respiratory`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_respiratory.md),

- [`phoenix8`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix8.md)
  for generating the diagnostic Phoenix 8 Sepsis criteria based on the
  four organ systems noted above and

  - [`phoenix_endocrine`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_endocrine.md),

  - [`phoenix_immunologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_immunologic.md),

  - [`phoenix_renal`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_renal.md),

  - [`phoenix_hepatic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_hepatic.md),

[`vignette('phoenix')`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
for more details and examples.

## Examples

``` r
# using the example sepsis data set
phoenix_cardiovascular(
   vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
   lactate = lactate,
   age = age,
   map = dbp + (sbp - dbp)/3,
   data = sepsis
)
#>  [1] 2 2 1 0 0 1 4 0 3 0 3 0 0 2 3 2 2 2 2 1

# example data set to get all the possible scores
DF <-
  expand.grid(vasos = c(NA, 0:6),
              lactate = c(NA, 3.2, 5, 7.8, 11, 14), # units of mmol/L
              age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
              map = c(NA, 16:52)) # mmHg
DF$card <- phoenix_cardiovascular(vasos, lactate, age, map, DF)
head(DF)
#>   vasos lactate age map card
#> 1    NA      NA  NA  NA    0
#> 2     0      NA  NA  NA    0
#> 3     1      NA  NA  NA    1
#> 4     2      NA  NA  NA    2
#> 5     3      NA  NA  NA    2
#> 6     4      NA  NA  NA    2

# what if lactate is unknown for all records? - set the value either in the
# data object or the arguement value to NA
DF2 <-
  expand.grid(vasos = c(NA, 0:6),
              age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
              map = c(NA, 16:52)) # mmHg
DF2$card <- phoenix_cardiovascular(vasos, lactate = NA, age, map, DF2)

DF3 <-
  expand.grid(vasos = c(NA, 0:6),
              lactate = NA, # mmol/L
              age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145), # months
              map = c(NA, 16:52)) # mmHg
DF3$card <- phoenix_cardiovascular(vasos, lactate, age, map, DF3)

identical(DF2$card, DF3$card)
#> [1] TRUE
```
