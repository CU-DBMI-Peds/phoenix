library(phoenix)
set.seed(42)
inputs <- expand.grid(sbp = rnorm(n = 500, mean = 80, sd = 10),
                      dbp = rnorm(n = 500, mean = 55, sd = 11))

pkg <- with(inputs, mean_arterial_pressure(sbp, dbp))
legacy_alias_warning <- NULL
legacy_pkg <- withCallingHandlers(
  with(inputs, map(sbp, dbp)),
  warning = function(w) {
    legacy_alias_warning <<- conditionMessage(w)
    invokeRestart("muffleWarning")
  }
)

x1 <- with(inputs, 2/3 * dbp + 1/3 * sbp)
x2 <- with(inputs, dbp + (sbp - dbp) / 3)

stopifnot(isTRUE(all.equal(x1, x2)))
stopifnot(isTRUE(all.equal(pkg, x1)))
stopifnot(isTRUE(all.equal(pkg, x2)))
stopifnot(isTRUE(all.equal(legacy_pkg, pkg)))
stopifnot(identical(legacy_alias_warning, "`map()` is deprecated; use `mean_arterial_pressure()` instead."))

################################################################################
#                                 End of File                                  #
################################################################################
