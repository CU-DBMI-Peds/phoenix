# Changelog

## Version 1.1.3:

CRAN release: 2025-10-22

- Spelling and grammar fixes in the documentation for the R, python, and
  sql.

## Version 1.1.2:

CRAN release: 2025-05-02

### Bug Fixes

- correct the limits for assessing immunologic dysfunction
  ([\#11](https://github.com/CU-DBMI-Peds/phoenix/issues/11))

### Other Changes

- Improve documentation

  - Fix copy and paste errors
  - Add expected units to examples

## Version 1.1.1:

CRAN release: 2024-07-08

- updated documentation and citation details.

## Version 1.1.0:

CRAN release: 2024-05-03

### New Features:

- The function `map` has been added to get the estimated mean arterial
  pressure from systolic and diastolic pressures.

### Other Changes:

- Update documentation.

## Version 1.0.0:

CRAN release: 2024-03-12

Initial Release

Functions for applying the Phoenix Pediatric Sepsis and Septic Shock
criteria

### Features

- There are eight organ dysfunction scoring functions

  - [`phoenix_respiratory()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_respiratory.md)
  - [`phoenix_cardiovascular()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_cardiovascular.md)
  - [`phoenix_coagulation()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_coagulation.md)
  - [`phoenix_neurologic()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_neurologic.md)
  - [`phoenix_endocrine()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_endocrine.md)
  - [`phoenix_immunologic()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_immunologic.md)
  - [`phoenix_renal()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_renal.md)
  - [`phoenix_hepatic()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_hepatic.md)

- [`phoenix()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix.md) -
  this is a wrapper function for applying the four-system Phoenix
  criteria (respiratory, cardiovascular, coagulation, and neurologic).
  The return is a data.frame with each of the four organ dysfunction
  scores, a total score, and indicators for sepsis (score ≥ 2), and
  septic shock (sepsis with cardiovascular dysfunction).

- [`phoenix8()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix8.md) -
  a wrapper about all eight organ systems and returns the same
  data.frame as
  [`phoenix()`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix.md)
  with the additional columns for the other four organ systems and the
  Phoenix-8 total score.

- [`vignette("phoenix")`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
  has details on the expected inputs, example use, and expected outputs.

- `sepsis` is a 20 row by 27 column data.frame of example data used to
  illustrate the use of the phoenix R package.
