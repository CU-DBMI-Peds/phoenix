# Phoenix Respiratory Score

Apply the Phoenix Respiratory Scoring rubric to a data set. The
respiratory score is part of the diagnostic Phoenix Sepsis criteria and
the diagnostic Phoenix 8 Sepsis criteria.

## Usage

``` r
phoenix_respiratory(
  pf_ratio = NA_real_,
  sf_ratio = NA_real_,
  imv = NA_integer_,
  other_respiratory_support = NA_integer_,
  data = parent.frame(),
  ...
)
```

## Arguments

- pf_ratio:

  numeric vector for the PaO2/FiO2 ratio; PaO2 = arterial oxygen
  pressure; FiO2 = fraction of inspired oxygen; PaO2 is measured in mmHg
  and FiO2 is from 0.21 (room air) to 1.00.

- sf_ratio:

  numeric vector for the SpO2/FiO2 ratio; SpO2 = oxygen saturation,
  measured in a percent; ratio for 92% oxygen saturation on room air is
  92/0.21 = 438.0952.

- imv:

  invasive mechanical ventilation; numeric or integer vector, (0 = not
  intubated; 1 = intubated)

- other_respiratory_support:

  other respiratory support; numeric or integer vector, (0 = no support;
  1 = support)

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

a integer vector with values 0, 1, 2, or 3.

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Details

`pf_ratio` is the ratio of partial pressure of oxygen in arterial blood
(PaO2) to the fraction of inspiratory oxygen concentration (FiO2).

`sf_ratio` is a non-invasive surrogate for `pf_ratio` using pulse
oximetry (SpO2) instead of invasive PaO2.

Important Note: when the Phoenix Sepsis criteria was developed there is
a requirement that SpO2 \<= 97 in order for the `sf_ratio` to be valid.
That assumption is not checked in this code and it is left to the end
user to account for this when building the `sf_ratio` vector.

`imv` Invasive mechanical ventilation - integer vector where 0 = not
intubated and 1 = intubated.

`other_respiratory_support` other respiratory support such as receiving
oxygen, high-flow, non-invasive positive pressure, or imv.

## Phoenix Respiratory Scoring

|                                       |                                                                  |                                              |                                              |
|---------------------------------------|------------------------------------------------------------------|----------------------------------------------|----------------------------------------------|
| 0 points                              | 1 point                                                          | 2 points                                     | 3 points                                     |
| pf_ratio \>= 400 and sf_ratio \>= 292 | (pf_ratio \< 400 or sf_ratio \< 292) and any respiratory support | (pf_ratio \< 200 or sf_ratio \< 220) and imv | (pf_ratio \< 100 or sf_ratio \< 148) and imv |

## References

See reference details in
[`phoenix-package`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix-package.md)
or by calling `citation('phoenix')`.

## See also

- [`phoenix`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix.md)
  for generating the diagnostic Phoenix Sepsis score based on the four
  organ systems:

  - [`phoenix_cardiovascular`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_cardiovascular.md),

  - [`phoenix_coagulation`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_coagulation.md),

  - [`phoenix_neurologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_neurologic.md),

  - `phoenix_respiratory`,

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
# Using the provided example data set:
# Expected units:
#   pf_ratio: PaO2 / FiO2
#     PaO2: mmHg
#     FiO2: decimal between 0.21 (room air) to 1.00 (pure oxygen)
#   sf_ratio: SpO2 / FiO2
#     SpO2: percentage, 0 to 100
#     FiO2: decimal between 0.21 (room air) to 1.00 (pure oxygen)
#   imv: (invasive mechanical ventilation) 1 for yes, 0 for no
#   other_respiratory_support: 1 for yes, 0 for no

phoenix_respiratory(
  pf_ratio = pao2 / fio2,
  sf_ratio = spo2 / fio2,
  imv      = vent,
  other_respiratory_support = as.integer(fio2 > 0.21),
  data = sepsis
)
#>  [1] 3 3 3 0 0 3 3 0 3 3 3 1 0 2 3 0 2 3 2 0

# A set of values that will get all possible respiratory scores:
DF <- expand.grid(
  pfr = c(NA, 500, 400, 350, 200, 187, 100, 56),
  sfr = c(NA, 300, 292, 254, 220, 177, 148, 76),
  vent = c(NA, 0, 1),
  o2  = c(NA, 0, 1)
)

phoenix_respiratory(
  pf_ratio = pfr,
  sf_ratio = sfr,
  imv = vent,
  other_respiratory_support = o2,
  data = DF
)
#>   [1] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#>  [38] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#>  [75] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#> [112] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 2 2 3 0 0 0 1 1 2 2 3 0 0 0 1
#> [149] 1 2 2 3 1 1 1 1 1 2 2 3 1 1 1 1 1 2 2 3 2 2 2 2 2 2 2 3 2 2 2 2 2 2 2 3 3
#> [186] 3 3 3 3 3 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#> [223] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#> [260] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#> [297] 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 2 2 3 0 0 0 1 1
#> [334] 2 2 3 0 0 0 1 1 2 2 3 1 1 1 1 1 2 2 3 1 1 1 1 1 2 2 3 2 2 2 2 2 2 2 3 2 2
#> [371] 2 2 2 2 2 3 3 3 3 3 3 3 3 3 0 0 0 1 1 1 1 1 0 0 0 1 1 1 1 1 0 0 0 1 1 1 1
#> [408] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
#> [445] 1 1 1 1 0 0 0 1 1 1 1 1 0 0 0 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1
#> [482] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 1 1 2
#> [519] 2 3 0 0 0 1 1 2 2 3 0 0 0 1 1 2 2 3 1 1 1 1 1 2 2 3 1 1 1 1 1 2 2 3 2 2 2
#> [556] 2 2 2 2 3 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3

```
