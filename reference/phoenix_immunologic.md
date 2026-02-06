# Phoenix Immunologic Score

Apply the Phoenix immunologic scoring based on ANC and ALC. This is only
part of Phoenix-8 and not Phoenix.

## Usage

``` r
phoenix_immunologic(anc = NA_real_, alc = NA_real_, data = parent.frame(), ...)
```

## Arguments

- anc:

  absolute neutrophil count; a numeric vector; units of 1,000 cells per
  cubic millimeter

- alc:

  absolute lymphocyte count; a numeric vector; units of 1,000 cells per
  cubic millimeter

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

a integer vector with values 0 or 1

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Phoenix Immunologic Scoring

1 point if ANC \< 0.500 or ALC \< 1.000 (units are 1000 cells per cubic
millimeter).

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

  - `phoenix_immunologic`,

  - [`phoenix_renal`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_renal.md),

  - [`phoenix_hepatic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_hepatic.md),

[`vignette('phoenix')`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
for more details and examples.

## Examples

``` r
# using the example sepsis data set
# Expected units for ALC and ANC are 1000 cells per cubic millimeter

immu_example <- sepsis[c("pid", "anc", "alc")]
immu_example$score <- phoenix_immunologic(anc, alc, sepsis)
immu_example
#>    pid    anc   alc score
#> 1    1     NA    NA     0
#> 2    2 14.220 2.220     0
#> 3    3  2.210 0.190     1
#> 4    4  3.184 0.645     1
#> 5    5     NA    NA     0
#> 6    6 20.200 0.240     1
#> 7    7     NA    NA     0
#> 8    8  3.760 1.550     0
#> 9    9  8.770 3.600     0
#> 10  10  9.084 4.617     0
#> 11  11     NA    NA     0
#> 12  12     NA    NA     0
#> 13  13     NA    NA     0
#> 14  14     NA    NA     0
#> 15  15     NA    NA     0
#> 16  16  4.720 4.300     0
#> 17  17  9.380 1.310     0
#> 18  18     NA    NA     0
#> 19  19 12.570 2.810     0
#> 20  20  3.410 2.850     0

# example data set with all possilbe immunologic scores
# Expected units for anc and alc are 1000 cells per cubic millimeter

DF <- expand.grid(anc = c(NA, 0.200, 0.500, 0.600),
                  alc = c(NA, 0.500, 1.000, 2.000))
phoenix_immunologic(anc = anc, alc = alc, data = DF)
#>  [1] 0 1 0 0 1 1 1 1 0 1 0 0 0 1 0 0
```
