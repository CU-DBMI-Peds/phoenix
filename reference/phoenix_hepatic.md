# Phoenix Hepatic Score

Apply the Phoenix Hepatic scoring based on total bilirubin and ALT.

## Usage

``` r
phoenix_hepatic(
  bilirubin = NA_real_,
  alt = NA_real_,
  data = parent.frame(),
  ...
)
```

## Arguments

- bilirubin:

  numeric vector; units of mg/dL

- alt:

  alanine aminotransferase; a numeric vector; units of IU/L

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

a integer vector with values 0 or 1

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Phoenix Hepatic Scoring

1 point for total bilirubin greater or equal to 4 mg/dL and/or ALT
strictly greater than 102 IU/L.

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

  - [`phoenix_renal`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_renal.md),

  - `phoenix_hepatic`,

[`vignette('phoenix')`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
for more details and examples.

## Examples

``` r
# using the example sepsis data set
# recall expected units:
#   (total) bilirubin: mg/dL
#   alt: IU/L

hep_example       <- sepsis[c("pid", "bilirubin", "alt")]
hep_example$score <- phoenix_hepatic(bilirubin, alt, sepsis)
hep_example
#>    pid bilirubin  alt score
#> 1    1        NA   36     0
#> 2    2     0.200   32     0
#> 3    3     0.800  182     1
#> 4    4     8.500   21     1
#> 5    5        NA   NA     0
#> 6    6     1.200   15     0
#> 7    7     1.700 3664     1
#> 8    8     0.500   50     0
#> 9    9    21.100  151     1
#> 10  10        NA   NA     0
#> 11  11     0.180   NA     0
#> 12  12        NA   NA     0
#> 13  13        NA   NA     0
#> 14  14     3.300   60     0
#> 15  15     1.300 1792     1
#> 16  16     1.579   15     0
#> 17  17     0.600   41     0
#> 18  18     1.300 1790     1
#> 19  19        NA   NA     0
#> 20  20     0.363   22     0

# example data set with all possilbe hepatic scores
DF <- expand.grid(bil = c(NA, 3.2, 4.0, 4.3), alt = c(NA, 99, 102, 106))
phoenix_hepatic(bilirubin = bil, alt = alt, data = DF)
#>  [1] 0 0 1 1 0 0 1 1 0 0 1 1 1 1 1 1
```
