# Version 1.1.3.9005

## New Features

### Operationalize Phoenix

* Add `prepare_<input>()` functions for transforming long-format clinical data
  into validated Phoenix inputs.  These helpers check identifiers, encounter
  clock values, missingness, expected ranges or allowable discrete values, and
  duplicate observations.
* Add `prepare_phoenix_data()` for assembling prepared inputs into a
  longitudinal encounter data set, applying last-observation-carried-forward
  windows, and constructing derived variables used for scoring, including
  PaO2/FiO2 ratio, SpO2/FiO2 ratio, invasive mechanical ventilation, other
  respiratory support, mean arterial pressure, Glasgow Coma Scale, fixed pupils,
  and suspected infection.
* Add `score_prepared_phoenix_data()` for scoring prepared longitudinal data
  within a user-defined observation window.  The default `jama2024` method
  reproduces the Phoenix and Phoenix-8 score definitions.  Exploratory
  aggregation methods are available as `olm` (organ-level maxima), `ccd`
  (organ-level maxima with cardiovascular component decoupling), and `fcd`
  (full component decoupling).
* `score_prepared_phoenix_data()` now returns organ dysfunction summary score
  (ODSS) columns separately from Phoenix Sepsis Score (PSS) columns.  ODSS is
  computed regardless of suspected infection status; PSS is the suspected
  infection-gated score.  The returned data include the suspected infection
  indicator used for the window.

## Other changes

* Soft deprecate the `imv` argument in the R and Python `phoenix_respiratory()`,
  `phoenix()`, and `phoenix8()` functions in favor of
  `invasive_mechanical_ventilation`.  Positional calls and named `imv =` calls
  still work for compatibility.  SQL examples now use the longer name.
* Rename the public mean arterial pressure helper and arguments from `map` to
  `mean_arterial_pressure` in R, Python, examples, and SQL documentation.  The
  R and Python `map()` helper remains available as a soft-deprecated alias for
  `mean_arterial_pressure()`, and the `map` argument remains available as a
  soft-deprecated alias for `mean_arterial_pressure` in
  `phoenix_cardiovascular()`, `phoenix()`, and `phoenix8()`.
* Use more explicit names for respiratory preparation inputs that distinguish
  mean airway pressure values from the invasive mechanical ventilation
  indicator.
* Change the default GCS carry-forward look-back in `prepare_phoenix_data()` to
  720 minutes to match the operational definition.
* Package now depends on R >= 4.0.0 due to the use of `deparse1()`
* Add data.table, dplyr, tidyr, and tidyselect to suggested packages.  The
  operationalization helpers use guarded backend-aware paths for data.frames,
  data.tables, and tibbles without importing these optional namespaces.
* Add digest to suggested packages.  Used in testing.
* Update package build tooling, data generation Make targets, pkgdown reference
  sections, R examples, Python examples, and SQL examples for the new
  operationalization workflow and renamed arguments.

## Bug Fixes

* Use `get()` instead of `quote()` so that the methods will work when the
  namespace is load and not attached. (#20)

# Version 1.1.3:

* Spelling and grammar fixes in the documentation for the R, python, and
  sql.

# Version 1.1.2:

## Bug Fixes

* correct the limits for assessing immunologic dysfunction (#11)

## Other Changes

* Improve documentation

  * Fix copy and paste errors
  * Add expected units to examples

# Version 1.1.1:

* updated documentation and citation details.

# Version 1.1.0:

## New Features:

* The function `map` has been added to get the estimated mean arterial pressure
  from systolic and diastolic pressures.

## Other Changes:

* Update documentation.

# Version 1.0.0:

Initial Release

Functions for applying the Phoenix Pediatric Sepsis and Septic Shock criteria

## Features

* There are eight organ dysfunction scoring functions
  * `phoenix_respiratory()`
  * `phoenix_cardiovascular()`
  * `phoenix_coagulation()`
  * `phoenix_neurologic()`
  * `phoenix_endocrine()`
  * `phoenix_immunologic()`
  * `phoenix_renal()`
  * `phoenix_hepatic()`

* `phoenix()` - this is a wrapper function for applying the four-system Phoenix
  criteria (respiratory, cardiovascular, coagulation, and neurologic).  The
  return is a data.frame with each of the four organ dysfunction scores, a total
  score, and indicators for sepsis (score &geq; 2), and septic shock (sepsis
  with cardiovascular dysfunction).

* `phoenix8()` - a wrapper about all eight organ systems and returns the same
  data.frame as `phoenix()` with the additional columns for the other four organ
  systems and the Phoenix-8 total score.

* `vignette("phoenix")` has details on the expected inputs, example use, and
  expected outputs.

* `sepsis` is a 20 row by 27 column data.frame of example data used to
  illustrate the use of the phoenix R package.
