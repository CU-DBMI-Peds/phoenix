# Phoenix Sepsis Neurological Score

Assessment of neurologic dysfunction based on Glasgow Coma Scale (GCS)
and pupil reactivity. This score is part of the diagnostic Phoenix
Sepsis criteria and Phoenix 8 Sepsis criteria.

## Usage

``` r
phoenix_neurologic(
  gcs = NA_integer_,
  fixed_pupils = NA_real_,
  data = parent.frame(),
  ...
)
```

## Arguments

- gcs:

  integer vector; total Glasgow Coma Score

- fixed_pupils:

  integer vector; 1 = bilaterally fixed pupil, 0 = otherwise

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

an integer vector with values 0, 1, or 2. As with all Phoenix organ
dysfunction scores, missing input values map to scores of zero.

## Details

Missing values will map to a value of 0 as was done when developing the
Phoenix criteria. Note that this is done on a input by input basis. That
is, if pupil reactivity is missing but GCS (total) is 9, then the
neurologic dysfunction score is 1.

GCS total is the sum of a score based on eyes, motor control, and verbal
responsiveness.

Eye response:

1.  no eye opening,

2.  eye opening to pain,

3.  eye opening to sound,

4.  eyes open spontaneously.

Verbal response:

1.  no verbal response,

2.  incomprehensible sounds,

3.  inappropriate words,

4.  confused,

5.  orientated

Motor response:

1.  no motor response,

2.  abnormal extension to pain,

3.  abnormal flexion to pain,

4.  withdrawal from pain,

5.  localized pain,

6.  obeys commands

## Phoenix Neurological Scoring

|                                             |          |
|---------------------------------------------|----------|
| Bilaterally fixed pupil                     | 2 points |
| Glasgow Coma Score (total) less or equal 10 | 1 point  |
| Reactive pupils and GCS \> 10               | 0 point  |

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

  - `phoenix_neurologic`,

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
# Expected units:
#   GCS integer values from 3, 4, 5, ..., 15 
#   fixed_pupils: 1 if bilaterially fixed pupils, 0 otherwise

phoenix_neurologic(
  gcs = gcs_total, 
  fixed_pupils = as.integer(pupil == "both-fixed"),
  data = sepsis
)
#>  [1] 0 1 0 0 0 1 0 0 1 1 2 0 0 0 0 0 0 0 0 0

# build an example data set with all possible neurologic scores
DF <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
DF$target <- 0L
DF$target[DF$gcs <= 10] <- 1L
DF$target[DF$pupils == 1] <- 2L
DF$current <- phoenix_neurologic(gcs, pupils, DF)
stopifnot(identical(DF$target, DF$current))
DF
#>    gcs pupils target current
#> 1    3      0      1       1
#> 2    4      0      1       1
#> 3    5      0      1       1
#> 4    6      0      1       1
#> 5    7      0      1       1
#> 6    8      0      1       1
#> 7    9      0      1       1
#> 8   10      0      1       1
#> 9   11      0      0       0
#> 10  12      0      0       0
#> 11  13      0      0       0
#> 12  14      0      0       0
#> 13  15      0      0       0
#> 14  NA      0      0       0
#> 15   3      1      2       2
#> 16   4      1      2       2
#> 17   5      1      2       2
#> 18   6      1      2       2
#> 19   7      1      2       2
#> 20   8      1      2       2
#> 21   9      1      2       2
#> 22  10      1      2       2
#> 23  11      1      2       2
#> 24  12      1      2       2
#> 25  13      1      2       2
#> 26  14      1      2       2
#> 27  15      1      2       2
#> 28  NA      1      2       2
#> 29   3     NA      1       1
#> 30   4     NA      1       1
#> 31   5     NA      1       1
#> 32   6     NA      1       1
#> 33   7     NA      1       1
#> 34   8     NA      1       1
#> 35   9     NA      1       1
#> 36  10     NA      1       1
#> 37  11     NA      0       0
#> 38  12     NA      0       0
#> 39  13     NA      0       0
#> 40  14     NA      0       0
#> 41  15     NA      0       0
#> 42  NA     NA      0       0
```
