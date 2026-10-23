library(phoenix)
source("utilities.R")

# `value` is the standardized output field of every prepared time-varying
# input. A caller cannot ask a prepare_*() function to rename a different
# column to `value` while retaining an existing column of that name.
x <- data.frame(
  encounter_id = "E1",
  encounter_clock = 0,
  value = 2,
  o2support = 1
)

errors <-
  lapply(
    make_backends(x),
    function(x) {
      tryCatch(
        prepare_o2support(
          x = x,
          id.vars = "encounter_id",
          eclock = "encounter_clock",
          value.var = "o2support",
          verbose = FALSE
        ),
        error = function(e) e
      )
    }
  )

stopifnot(
  sapply(errors, inherits, "error"),
  sapply(
    sapply(errors, getElement, "message"),
    grepl,
    pattern = "`value` is reserved"
  )
)
