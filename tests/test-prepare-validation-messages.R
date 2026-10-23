library(phoenix)

# Discrete-value validation should tell callers which values need recoding and
# which values are accepted by the selected preparation function.
x <- data.frame(
  encounter_id = c("E1", "E1"),
  encounter_clock = c(0, 60),
  o2support = c(2, 3)
)

err <- tryCatch(
  prepare_o2support(
    x = x,
    id.vars = "encounter_id",
    eclock = "encounter_clock",
    value.var = "o2support",
    verbose = FALSE
  ),
  error = function(e) e
)

stopifnot(
  inherits(err, "error"),
  identical(
    err$message,
    "Invalid values in x[['o2support']]: 2, 3. Expected one of: 0, 1."
  )
)
