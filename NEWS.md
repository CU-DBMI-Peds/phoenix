# Version 1.1.3.9000

## New Featues

### Operationalize Phoenix

* `prepare_<input>()` will run some simple checks for expected data ranges
  (values) and return an object that is expected to be passed to
  `prepare_phoenix_data()`.
* `prepare_phoenix_data()` applies last-observation-carry-forward windowing and
  data checks before applying a scoring method.

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
* Package now depends on R >= 4.0.0 due to the use of `deparse1()`
* Add data.table and dplyr to suggested packages.  The phoenix package will use
  the native data.table or dplyr data methods if the user passes a data.table or
  a tibble to the operationalization methods and the needed namespaces are
  avaialble.  If the namespaces are not availble then the code will default to
  data.frame methods.
* Add digest to suggested packages.  Used in testing.

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
