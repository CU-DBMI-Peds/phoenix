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
