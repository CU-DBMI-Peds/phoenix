library(phoenix)

################################################################################
# verify that the return is an integer vector

eg <- phoenix_renal(creatinine, age, data = sepsis)
stopifnot("return is an integer vector" = is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_renal(), 0L))
stopifnot(identical(phoenix_renal(data = sepsis), 0L))

################################################################################
# verify error if lengths differ
x <- tryCatch(phoenix_renal(creatinine = numeric(0)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of creatinine is 0; Length of age is 1."
))

x <- tryCatch(phoenix_renal(creatinine = c(NA, NA), age = c(NA, NA, NA)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of creatinine is 2; Length of age is 3."
))

################################################################################
#                                 End of File                                  #
################################################################################
