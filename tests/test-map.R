library(phoenix)
set.seed(42)
inputs <- expand.grid(sbp = rnorm(n = 500, mean = 80, sd = 10),
                      dbp = rnorm(n = 500, mean = 55, sd = 11))

pkg <- with(inputs, map(sbp, dbp))

x1 <- with(inputs, 2/3 * dbp + 1/3 * sbp)
x2 <- with(inputs, dbp + (sbp - dbp) / 3)

stopifnot(isTRUE(all.equal(x1, x2)))
stopifnot(isTRUE(all.equal(pkg, x1)))
stopifnot(isTRUE(all.equal(pkg, x2)))

################################################################################
#                                 End of File                                  #
################################################################################
