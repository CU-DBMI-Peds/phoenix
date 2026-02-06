# Phoenix Endocrine Score

Assess the Phoenix endocrine organ dysfunction score. This score is not
part of the Phoenix score, only part of the Phoenix-8 score.

## Usage

``` r
phoenix_endocrine(glucose = NA_real_, data = parent.frame(), ...)
```

## Arguments

- glucose:

  numeric vector; blood glucose measured in mg/dL

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

a integer vector with values 0 or 1

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Phoenix Endocrine Scoring

The endocrine dysfunction score is based on blood glucose with one point
for levels \< 50 mg/dL or \> 150 mg/dL.

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

  - `phoenix_endocrine`,

  - [`phoenix_immunologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_immunologic.md),

  - [`phoenix_renal`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_renal.md),

  - [`phoenix_hepatic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_hepatic.md),

[`vignette('phoenix')`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
for more details and examples.

## Examples

``` r
# using the example sepsis data set
# recall glucose is expected to have units of mg/dL

endo_example       <- sepsis[c("pid", "glucose")]
endo_example$score <- phoenix_endocrine(glucose, data = sepsis)
endo_example
#>    pid glucose score
#> 1    1      NA     0
#> 2    2   110.0     0
#> 3    3    93.0     0
#> 4    4   110.0     0
#> 5    5      NA     0
#> 6    6   147.0     0
#> 7    7      NA     0
#> 8    8   100.0     0
#> 9    9   264.0     1
#> 10  10    93.0     0
#> 11  11   341.0     1
#> 12  12      NA     0
#> 13  13      NA     0
#> 14  14      NA     0
#> 15  15      NA     0
#> 16  16    82.4     0
#> 17  17   130.0     0
#> 18  18      NA     0
#> 19  19   103.0     0
#> 20  20   159.8     1

# example data set to get all the possible endocrine scores
# recall glucose is expected to have units of mg/dL

DF <- data.frame(glc = c(NA, 12, 50, 55, 100, 150, 178))
phoenix_endocrine(glucose = glc, data = DF)
#> [1] 0 1 0 0 0 0 1
```
