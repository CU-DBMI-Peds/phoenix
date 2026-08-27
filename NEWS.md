# Version 1.1.3.9008

## API Changes

* Move the prepared-data respiratory PFR/SFR source-time selector from
  `score_prepared_phoenix_data()` to `prepare_phoenix_data()`. The MAP
  freshness controls and respiratory freshness control now live in the same
  preparation call: `map.sdbp.delta`, `map.delta`, and `pao2.spo2.delta`.
* Add `PFR_RESP`, `SFR_RESP`, `PFR_RESP_eclock`, and `SFR_RESP_eclock` to
  prepared Phoenix data. These columns are the row-level respiratory scoring
  inputs used by the `jama2024`, `olm`, and `ccd` aggregation schemes. The
  independent `PFR` and `SFR` columns are retained for FCD, where PFR and SFR
  are aggregated independently over the scoring interval.
* Simplify `score_prepared_phoenix_data()` by removing the
  `pao2.spo2.delta` argument. Scoring now consumes the respiratory input
  selection already encoded in the prepared data.

## New Features

* Add the `phx` dataset for examples of the operationalized methods.

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
* Add optional respiratory oxygenation source-time selection through
  `pao2.spo2.delta`.  The default value `NULL` preserves the published
  PFR-or-SFR threshold logic.  Non-`NULL` values select between PFR and SFR
  using their source times; `Inf` prefers PFR whenever both ratios are
  available, and finite values use SFR only when the SpO2 source is sufficiently
  newer than the PaO2 source.
* Expose `pao2.spo2.delta` on `phoenix_respiratory()`, `phoenix()`,
  `phoenix8()`, and `prepare_phoenix_data()`.  The direct `phoenix()` and
  `phoenix8()` wrappers default to the original PFR-or-SFR logic, while callers
  may opt into source-time selection explicitly.
* Add MAP freshness controls to `prepare_phoenix_data()`: `map.sdbp.delta`
  limits how far apart paired SBP/DBP source times may be when estimating MAP,
  and `map.delta` controls when newer lower-priority MAP candidates can override
  the source-priority hierarchy.  Defaults preserve the original MAP source
  priority behavior.
* Expose the same MAP candidate-selection logic through
  `phoenix_cardiovascular()`, `phoenix()`, and `phoenix8()` for scheduled
  row-level scoring.  Direct callers may still provide a final
  `mean_arterial_pressure`, or they may provide raw arterial/cuff MAP and
  SBP/DBP candidates with source times and let the package apply the documented
  freshness rules.
* Give all clinical input arguments in `phoenix()` and `phoenix8()` typed
  missing-value defaults.  This makes sparse row-level scoring calls consistent
  with the organ-level scoring functions, where omitted or missing inputs map to
  zero contribution for that component.

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
* Add source-time columns for derived PFR and SFR values in prepared Phoenix
  data, enabling respiratory source-time selection during prepared-data
  construction.
* Package now depends on R >= 4.0.0 due to the use of `deparse1()`
* Add data.table, dplyr, tidyr, and tidyselect to suggested packages.  The
  operationalization helpers use guarded backend-aware paths for data.frames,
  data.tables, and tibbles without importing these optional namespaces.
* Add digest to suggested packages.  Used in testing.
* Update package build tooling, data generation Make targets, pkgdown reference
  sections, R examples, Python examples, and SQL examples for the new
  operationalization workflow and renamed arguments.
* Update the operational-definition article with implementation crosswalk
  comments that map respiratory oxygenation selection and MAP freshness
  notation to the corresponding R code paths.

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
