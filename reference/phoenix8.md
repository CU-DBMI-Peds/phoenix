# The Phoenix 8 Sepsis Score

The extended Phoenix criteria using a total eight organ systems. This is
intended mostly for research as an extension of the Phoenix Sepsis
Criteria which is based on four organ systems.

## Usage

``` r
phoenix8(
  pf_ratio,
  sf_ratio,
  imv,
  other_respiratory_support,
  vasoactives,
  lactate,
  map,
  platelets,
  inr,
  d_dimer,
  fibrinogen,
  gcs,
  fixed_pupils,
  glucose,
  anc,
  alc,
  creatinine,
  bilirubin,
  alt,
  age,
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

- vasoactives:

  an integer vector, the number of systemic vasoactive medications being
  administered to the patient. Six vasoactive medications are
  considered: dobutamine, dopamine, epinephrine, milrinone,
  norepinephrine, vasopressin.

- lactate:

  numeric vector with the lactate value in mmol/L

- map:

  numeric vector, mean arterial pressure in mmHg

- platelets:

  numeric vector for platelets counts in units of 1,000/uL (thousand per
  microliter)

- inr:

  numeric vector for the international normalised ratio blood test

- d_dimer:

  numeric vector for D-Dimer, units of mg/L FEU

- fibrinogen:

  numeric vector units of mg/dL

- gcs:

  integer vector; total Glasgow Coma Score

- fixed_pupils:

  integer vector; 1 = bilaterally fixed pupil, 0 = otherwise

- glucose:

  numeric vector; blood glucose measured in mg/dL

- anc:

  absolute neutrophil count; a numeric vector; units of 1,000 cells per
  cubic millimeter

- alc:

  absolute lymphocyte count; a numeric vector; units of 1,000 cells per
  cubic millimeter

- creatinine:

  numeric vector; units of mg/dL

- bilirubin:

  numeric vector; units of mg/dL

- alt:

  alanine aminotransferase; a numeric vector; units of IU/L

- age:

  numeric vector age in months

- data:

  a `list`, `data.frame`, or `environment` containing the input vectors

- ...:

  pass through

## Value

a `data.frame` with 12 integer columns.

1.  `phoenix_respiratory_score`

2.  `phoenix_cardiovascular_score`

3.  `phoenix_coagulation_score`

4.  `phoenix_neurologic_score`

5.  `phoenix_sepsis_score`

6.  `phoenix_sepsis` 0 = not septic; 1 = septic (phoenix_sepsis_score
    greater or equal 2)

7.  `phoenix_septic_shock` 0 = no septic shock; 1 = septic shock (sepsis
    with cardiovascular dysfunction)

8.  `phoenix_endocrine_score`

9.  `phoenix_immunologic_score`

10. `phoenix_renal_score`

11. `phoenix_hepatic_score`

12. `phoenix8_sepsis_score`

As with all other Phoenix organ system scores, missing values in the
data set will map to a score of zero - this is consistent with the
development of the criteria.

## Details

The Phoenix Sepsis Criteria is based on the scores from respiratory,
cardiovascular, coagulation, and neurologic systems. Phoenix 8 uses
these four plus endocrine, immunologic, renal, and hepatic. Details on
the scoring for each of the eight component organ systems are found in
the respective manual files.

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

- `phoenix8` for generating the diagnostic Phoenix 8 Sepsis criteria
  based on the four organ systems noted above and

  - [`phoenix_endocrine`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_endocrine.md),

  - [`phoenix_immunologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_immunologic.md),

  - [`phoenix_renal`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_renal.md),

  - [`phoenix_hepatic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_hepatic.md),

[`vignette('phoenix')`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
for more details and examples.

## Examples

``` r
# Using the example sepsis data set, read more details in the vignette

phoenix8_scores <-
  phoenix8(
    # Respiratory
      pf_ratio = pao2 / fio2,
      sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
      imv = vent,
      other_respiratory_support = as.integer(fio2 > 0.21),
    # Cardiovascular
      vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
      lactate = lactate,
      age = age, # Also used in the renal assessment.
      map = dbp + (sbp - dbp)/3,
    # Coagulation
      platelets = platelets,
      inr = inr,
      d_dimer = d_dimer,
      fibrinogen = fibrinogen,
    # Neurologic
      gcs = gcs_total,
      fixed_pupils = as.integer(pupil == "both-fixed"),
    # Endocrine
      glucose = glucose,
    # Immunologic
      anc = anc,
      alc = alc,
    # Renal
      creatinine = creatinine,
      # no need to specify age again
    # Hepatic
      bilirubin = bilirubin,
      alt = alt,
    data = sepsis
  )

str(phoenix8_scores)
#> 'data.frame':    20 obs. of  12 variables:
#>  $ phoenix_respiratory_score   : int  0 3 3 0 0 3 3 0 3 3 ...
#>  $ phoenix_cardiovascular_score: int  2 2 1 0 0 1 4 0 3 0 ...
#>  $ phoenix_coagulation_score   : int  1 1 2 1 0 2 2 1 1 0 ...
#>  $ phoenix_neurologic_score    : int  0 1 0 0 0 1 0 0 1 1 ...
#>  $ phoenix_sepsis_score        : int  3 7 6 1 0 7 9 1 8 4 ...
#>  $ phoenix_sepsis              : int  1 1 1 0 0 1 1 0 1 1 ...
#>  $ phoenix_septic_shock        : int  1 1 1 0 0 1 1 0 1 0 ...
#>  $ phoenix_endocrine_score     : int  0 0 0 0 0 0 0 0 1 0 ...
#>  $ phoenix_immunologic_score   : int  0 0 1 1 0 1 0 0 0 0 ...
#>  $ phoenix_renal_score         : int  1 0 0 0 0 1 1 0 1 0 ...
#>  $ phoenix_hepatic_score       : int  0 0 1 1 0 0 1 0 1 0 ...
#>  $ phoenix8_sepsis_score       : int  4 7 8 3 0 9 11 1 11 4 ...
```
