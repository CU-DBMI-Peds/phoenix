# Phoenix Renal Score

Apply the Phoenix renal organ dysfunction score based on age adjusted
creatinine levels.

## Usage

``` r
phoenix_renal(
  creatinine = NA_real_,
  age = NA_real_,
  data = parent.frame(),
  ...
)
```

## Arguments

- creatinine:

  numeric vector; units of mg/dL

- age:

  numeric vector age in months

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

an integer vector with values 0 or 1

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Phoenix Renal Scoring

|                            |                                 |          |
|----------------------------|---------------------------------|----------|
| Age in \[0, 1) months      |                                 |          |
|                            | creatinine \[0, 0.8) mg/dL      | 0 points |
|                            | creatinine \[0.8, Inf) mg/dL    | 1 point  |
| Age in \[1, 12) months     |                                 |          |
|                            | creatinine in \[0, 0.3) mg/dL   | 0 points |
|                            | creatinine in \[0.3, Inf) mg/dL | 1 point  |
| Age in \[12, 24) months    |                                 |          |
|                            | creatinine in \[0, 0.4) mg/dL   | 0 points |
|                            | creatinine in \[0.4, Inf) mg/dL | 1 point  |
| Age in \[24, 60) months    |                                 |          |
|                            | creatinine in \[0, 0.6) mg/dL   | 0 points |
|                            | creatinine in \[0.6, Inf) mg/dL | 1 point  |
| Age in \[60, 144) months   |                                 |          |
|                            | creatinine in \[0, 0.7) mg/dL   | 0 points |
|                            | creatinine in \[0.7, Inf) mg/dL | 1 point  |
| Age in \[144, 216\] months |                                 |          |
|                            | creatinine in \[0, 1.0) mg/dL   | 0 points |
|                            | creatinine in \[1.0, Inf) mg/dL | 1 point  |

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

  - [`phoenix_respiratory`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_respiratory.md),

- [`phoenix8`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix8.md)
  for generating the diagnostic Phoenix 8 Sepsis criteria based on the
  four organ systems noted above and

  - [`phoenix_endocrine`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_endocrine.md),

  - [`phoenix_immunologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_immunologic.md),

  - `phoenix_renal`,

  - [`phoenix_hepatic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_hepatic.md),

[`vignette('phoenix')`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
for more details and examples.

## Examples

``` r
# using the example sepsis data set
# Expected units:
#   age: months
#   creatinine: mg/dL

renal_example <- sepsis[c("creatinine", "age")]
renal_example$score <- phoenix_renal(creatinine, age, sepsis)
renal_example
#>    creatinine    age score
#> 1       1.030   0.06     1
#> 2       0.510 201.70     0
#> 3       0.330  20.80     0
#> 4       0.310 192.50     0
#> 5       0.520 214.40     0
#> 6       0.770 101.20     1
#> 7       1.470 150.70     1
#> 8       0.580 159.70     0
#> 9       1.230 176.10     1
#> 10      0.180   6.60     0
#> 11      0.870  36.70     1
#> 12         NA  37.40     0
#> 13         NA   0.12     0
#> 14      0.120  62.30     0
#> 15      1.300  10.60     1
#> 16      0.418   0.89     0
#> 17      0.290  10.70     0
#> 18      1.100  10.60     1
#> 19      1.200   0.17     1
#> 20      0.418  71.90     0

# build an example data set with representative renal scores
DF <- expand.grid(age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145),
                  creatinine = c(NA, seq(0.0, 1.1, by = 0.1)))
DF$card <- phoenix_renal(age = age, creatinine = creatinine, data = DF)

head(DF)
#>    age creatinine card
#> 1   NA         NA    0
#> 2  0.4         NA    0
#> 3  1.0         NA    0
#> 4  3.0         NA    0
#> 5 12.0         NA    0
#> 6 18.0         NA    0
```
