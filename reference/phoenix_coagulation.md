# Phoenix Coagulation Score

Applies the Phoenix coagulation organ dysfunction scoring to a set of
inputs.

## Usage

``` r
phoenix_coagulation(
  platelets = NA_real_,
  inr = NA_real_,
  d_dimer = NA_real_,
  fibrinogen = NA_real_,
  data = parent.frame(),
  ...
)
```

## Arguments

- platelets:

  numeric vector for platelets counts in units of 1,000/uL (thousand per
  microliter)

- inr:

  numeric vector for the international normalised ratio blood test

- d_dimer:

  numeric vector for D-Dimer, units of mg/L FEU

- fibrinogen:

  numeric vector units of mg/dL

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

a integer vector with values 0, 1, or 2

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Phoenix Coagulation Scoring

1 point each for platelets \< 100 K/micro liter, INR \> 1.3, D-dimer \>
2 mg/L FEU, and fibrinogen \< 100 mg/dL, with a max total score of 2.

## References

See reference details in
[`phoenix-package`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix-package.md)
or by calling `citation('phoenix')`.

## See also

- [`phoenix`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix.md)
  for generating the diagnostic Phoenix Sepsis score based on the four
  organ systems:

  - [`phoenix_cardiovascular`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_cardiovascular.md),

  - `phoenix_coagulation`,

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
# using the example data set
phoenix_coagulation(
  platelets = platelets,    # 1000/uL (thousand per microliter)
  inr = inr,                # unitless
  d_dimer = d_dimer,        # mg/L FEU
  fibrinogen = fibrinogen,  # mg/dL
  data = sepsis
)
#>  [1] 1 1 2 1 0 2 2 1 1 0 1 0 0 1 2 1 1 2 0 1

# build a data.frame with values for all possible combationations of values
# leading to all possible coagulation scores.
DF <-
  expand.grid(plts = c(NA, 20, 100, 150),
              inr  = c(NA, 0.2, 1.3, 1.8),
              ddmr = c(NA, 1.7, 2.0, 2.8),
              fib  = c(NA, 88, 100, 120))

DF$coag <- phoenix_coagulation(plts, inr, ddmr, fib, DF)
DF
#>     plts inr ddmr fib coag
#> 1     NA  NA   NA  NA    0
#> 2     20  NA   NA  NA    1
#> 3    100  NA   NA  NA    0
#> 4    150  NA   NA  NA    0
#> 5     NA 0.2   NA  NA    0
#> 6     20 0.2   NA  NA    1
#> 7    100 0.2   NA  NA    0
#> 8    150 0.2   NA  NA    0
#> 9     NA 1.3   NA  NA    0
#> 10    20 1.3   NA  NA    1
#> 11   100 1.3   NA  NA    0
#> 12   150 1.3   NA  NA    0
#> 13    NA 1.8   NA  NA    1
#> 14    20 1.8   NA  NA    2
#> 15   100 1.8   NA  NA    1
#> 16   150 1.8   NA  NA    1
#> 17    NA  NA  1.7  NA    0
#> 18    20  NA  1.7  NA    1
#> 19   100  NA  1.7  NA    0
#> 20   150  NA  1.7  NA    0
#> 21    NA 0.2  1.7  NA    0
#> 22    20 0.2  1.7  NA    1
#> 23   100 0.2  1.7  NA    0
#> 24   150 0.2  1.7  NA    0
#> 25    NA 1.3  1.7  NA    0
#> 26    20 1.3  1.7  NA    1
#> 27   100 1.3  1.7  NA    0
#> 28   150 1.3  1.7  NA    0
#> 29    NA 1.8  1.7  NA    1
#> 30    20 1.8  1.7  NA    2
#> 31   100 1.8  1.7  NA    1
#> 32   150 1.8  1.7  NA    1
#> 33    NA  NA  2.0  NA    0
#> 34    20  NA  2.0  NA    1
#> 35   100  NA  2.0  NA    0
#> 36   150  NA  2.0  NA    0
#> 37    NA 0.2  2.0  NA    0
#> 38    20 0.2  2.0  NA    1
#> 39   100 0.2  2.0  NA    0
#> 40   150 0.2  2.0  NA    0
#> 41    NA 1.3  2.0  NA    0
#> 42    20 1.3  2.0  NA    1
#> 43   100 1.3  2.0  NA    0
#> 44   150 1.3  2.0  NA    0
#> 45    NA 1.8  2.0  NA    1
#> 46    20 1.8  2.0  NA    2
#> 47   100 1.8  2.0  NA    1
#> 48   150 1.8  2.0  NA    1
#> 49    NA  NA  2.8  NA    1
#> 50    20  NA  2.8  NA    2
#> 51   100  NA  2.8  NA    1
#> 52   150  NA  2.8  NA    1
#> 53    NA 0.2  2.8  NA    1
#> 54    20 0.2  2.8  NA    2
#> 55   100 0.2  2.8  NA    1
#> 56   150 0.2  2.8  NA    1
#> 57    NA 1.3  2.8  NA    1
#> 58    20 1.3  2.8  NA    2
#> 59   100 1.3  2.8  NA    1
#> 60   150 1.3  2.8  NA    1
#> 61    NA 1.8  2.8  NA    2
#> 62    20 1.8  2.8  NA    2
#> 63   100 1.8  2.8  NA    2
#> 64   150 1.8  2.8  NA    2
#> 65    NA  NA   NA  88    1
#> 66    20  NA   NA  88    2
#> 67   100  NA   NA  88    1
#> 68   150  NA   NA  88    1
#> 69    NA 0.2   NA  88    1
#> 70    20 0.2   NA  88    2
#> 71   100 0.2   NA  88    1
#> 72   150 0.2   NA  88    1
#> 73    NA 1.3   NA  88    1
#> 74    20 1.3   NA  88    2
#> 75   100 1.3   NA  88    1
#> 76   150 1.3   NA  88    1
#> 77    NA 1.8   NA  88    2
#> 78    20 1.8   NA  88    2
#> 79   100 1.8   NA  88    2
#> 80   150 1.8   NA  88    2
#> 81    NA  NA  1.7  88    1
#> 82    20  NA  1.7  88    2
#> 83   100  NA  1.7  88    1
#> 84   150  NA  1.7  88    1
#> 85    NA 0.2  1.7  88    1
#> 86    20 0.2  1.7  88    2
#> 87   100 0.2  1.7  88    1
#> 88   150 0.2  1.7  88    1
#> 89    NA 1.3  1.7  88    1
#> 90    20 1.3  1.7  88    2
#> 91   100 1.3  1.7  88    1
#> 92   150 1.3  1.7  88    1
#> 93    NA 1.8  1.7  88    2
#> 94    20 1.8  1.7  88    2
#> 95   100 1.8  1.7  88    2
#> 96   150 1.8  1.7  88    2
#> 97    NA  NA  2.0  88    1
#> 98    20  NA  2.0  88    2
#> 99   100  NA  2.0  88    1
#> 100  150  NA  2.0  88    1
#> 101   NA 0.2  2.0  88    1
#> 102   20 0.2  2.0  88    2
#> 103  100 0.2  2.0  88    1
#> 104  150 0.2  2.0  88    1
#> 105   NA 1.3  2.0  88    1
#> 106   20 1.3  2.0  88    2
#> 107  100 1.3  2.0  88    1
#> 108  150 1.3  2.0  88    1
#> 109   NA 1.8  2.0  88    2
#> 110   20 1.8  2.0  88    2
#> 111  100 1.8  2.0  88    2
#> 112  150 1.8  2.0  88    2
#> 113   NA  NA  2.8  88    2
#> 114   20  NA  2.8  88    2
#> 115  100  NA  2.8  88    2
#> 116  150  NA  2.8  88    2
#> 117   NA 0.2  2.8  88    2
#> 118   20 0.2  2.8  88    2
#> 119  100 0.2  2.8  88    2
#> 120  150 0.2  2.8  88    2
#> 121   NA 1.3  2.8  88    2
#> 122   20 1.3  2.8  88    2
#> 123  100 1.3  2.8  88    2
#> 124  150 1.3  2.8  88    2
#> 125   NA 1.8  2.8  88    2
#> 126   20 1.8  2.8  88    2
#> 127  100 1.8  2.8  88    2
#> 128  150 1.8  2.8  88    2
#> 129   NA  NA   NA 100    0
#> 130   20  NA   NA 100    1
#> 131  100  NA   NA 100    0
#> 132  150  NA   NA 100    0
#> 133   NA 0.2   NA 100    0
#> 134   20 0.2   NA 100    1
#> 135  100 0.2   NA 100    0
#> 136  150 0.2   NA 100    0
#> 137   NA 1.3   NA 100    0
#> 138   20 1.3   NA 100    1
#> 139  100 1.3   NA 100    0
#> 140  150 1.3   NA 100    0
#> 141   NA 1.8   NA 100    1
#> 142   20 1.8   NA 100    2
#> 143  100 1.8   NA 100    1
#> 144  150 1.8   NA 100    1
#> 145   NA  NA  1.7 100    0
#> 146   20  NA  1.7 100    1
#> 147  100  NA  1.7 100    0
#> 148  150  NA  1.7 100    0
#> 149   NA 0.2  1.7 100    0
#> 150   20 0.2  1.7 100    1
#> 151  100 0.2  1.7 100    0
#> 152  150 0.2  1.7 100    0
#> 153   NA 1.3  1.7 100    0
#> 154   20 1.3  1.7 100    1
#> 155  100 1.3  1.7 100    0
#> 156  150 1.3  1.7 100    0
#> 157   NA 1.8  1.7 100    1
#> 158   20 1.8  1.7 100    2
#> 159  100 1.8  1.7 100    1
#> 160  150 1.8  1.7 100    1
#> 161   NA  NA  2.0 100    0
#> 162   20  NA  2.0 100    1
#> 163  100  NA  2.0 100    0
#> 164  150  NA  2.0 100    0
#> 165   NA 0.2  2.0 100    0
#> 166   20 0.2  2.0 100    1
#> 167  100 0.2  2.0 100    0
#> 168  150 0.2  2.0 100    0
#> 169   NA 1.3  2.0 100    0
#> 170   20 1.3  2.0 100    1
#> 171  100 1.3  2.0 100    0
#> 172  150 1.3  2.0 100    0
#> 173   NA 1.8  2.0 100    1
#> 174   20 1.8  2.0 100    2
#> 175  100 1.8  2.0 100    1
#> 176  150 1.8  2.0 100    1
#> 177   NA  NA  2.8 100    1
#> 178   20  NA  2.8 100    2
#> 179  100  NA  2.8 100    1
#> 180  150  NA  2.8 100    1
#> 181   NA 0.2  2.8 100    1
#> 182   20 0.2  2.8 100    2
#> 183  100 0.2  2.8 100    1
#> 184  150 0.2  2.8 100    1
#> 185   NA 1.3  2.8 100    1
#> 186   20 1.3  2.8 100    2
#> 187  100 1.3  2.8 100    1
#> 188  150 1.3  2.8 100    1
#> 189   NA 1.8  2.8 100    2
#> 190   20 1.8  2.8 100    2
#> 191  100 1.8  2.8 100    2
#> 192  150 1.8  2.8 100    2
#> 193   NA  NA   NA 120    0
#> 194   20  NA   NA 120    1
#> 195  100  NA   NA 120    0
#> 196  150  NA   NA 120    0
#> 197   NA 0.2   NA 120    0
#> 198   20 0.2   NA 120    1
#> 199  100 0.2   NA 120    0
#> 200  150 0.2   NA 120    0
#> 201   NA 1.3   NA 120    0
#> 202   20 1.3   NA 120    1
#> 203  100 1.3   NA 120    0
#> 204  150 1.3   NA 120    0
#> 205   NA 1.8   NA 120    1
#> 206   20 1.8   NA 120    2
#> 207  100 1.8   NA 120    1
#> 208  150 1.8   NA 120    1
#> 209   NA  NA  1.7 120    0
#> 210   20  NA  1.7 120    1
#> 211  100  NA  1.7 120    0
#> 212  150  NA  1.7 120    0
#> 213   NA 0.2  1.7 120    0
#> 214   20 0.2  1.7 120    1
#> 215  100 0.2  1.7 120    0
#> 216  150 0.2  1.7 120    0
#> 217   NA 1.3  1.7 120    0
#> 218   20 1.3  1.7 120    1
#> 219  100 1.3  1.7 120    0
#> 220  150 1.3  1.7 120    0
#> 221   NA 1.8  1.7 120    1
#> 222   20 1.8  1.7 120    2
#> 223  100 1.8  1.7 120    1
#> 224  150 1.8  1.7 120    1
#> 225   NA  NA  2.0 120    0
#> 226   20  NA  2.0 120    1
#> 227  100  NA  2.0 120    0
#> 228  150  NA  2.0 120    0
#> 229   NA 0.2  2.0 120    0
#> 230   20 0.2  2.0 120    1
#> 231  100 0.2  2.0 120    0
#> 232  150 0.2  2.0 120    0
#> 233   NA 1.3  2.0 120    0
#> 234   20 1.3  2.0 120    1
#> 235  100 1.3  2.0 120    0
#> 236  150 1.3  2.0 120    0
#> 237   NA 1.8  2.0 120    1
#> 238   20 1.8  2.0 120    2
#> 239  100 1.8  2.0 120    1
#> 240  150 1.8  2.0 120    1
#> 241   NA  NA  2.8 120    1
#> 242   20  NA  2.8 120    2
#> 243  100  NA  2.8 120    1
#> 244  150  NA  2.8 120    1
#> 245   NA 0.2  2.8 120    1
#> 246   20 0.2  2.8 120    2
#> 247  100 0.2  2.8 120    1
#> 248  150 0.2  2.8 120    1
#> 249   NA 1.3  2.8 120    1
#> 250   20 1.3  2.8 120    2
#> 251  100 1.3  2.8 120    1
#> 252  150 1.3  2.8 120    1
#> 253   NA 1.8  2.8 120    2
#> 254   20 1.8  2.8 120    2
#> 255  100 1.8  2.8 120    2
#> 256  150 1.8  2.8 120    2
```
