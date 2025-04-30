library(phoenix)

################################################################################
# verify that the return is an integer vector
eg <-
  phoenix_respiratory(
    pf_ratio = pao2 / fio2,
    sf_ratio = spo2 / fio2,
    imv      = vent,
    other_respiratory_support = as.integer(fio2 > 0.21),
    data = sepsis
  )

stopifnot("return is an integer vector" = is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_respiratory(), 0L))
stopifnot(identical(phoenix_respiratory(data = sepsis), 0L))


################################################################################
# verify error if lengths differ
x <- tryCatch(phoenix_respiratory(pf_ratio = numeric(0)), error = function(e) e)
stopifnot(isTRUE(inherits(x, "error")))
stopifnot(grepl("All inputs need to either have the same length or have length 1.", x$message))

x <- tryCatch(phoenix_respiratory(pf_ratio = c(NA, NA), imv = c(NA, NA, NA)), error = function(e) e)
stopifnot(isTRUE(inherits(x, "error")))
stopifnot(grepl("All inputs need to either have the same length or have length 1.", x$message))

################################################################################
#                                 End of File                                  #
################################################################################
