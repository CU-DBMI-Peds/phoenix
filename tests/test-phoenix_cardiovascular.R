library(phoenix)

################################################################################
# verify that the return is an integer vector
eg <-
  phoenix_cardiovascular(
     vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
     lactate = lactate,
     age = age,
     map = dbp + (sbp - dbp)/3,
     data = sepsis
  )

stopifnot("return is an integer vector" = is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_cardiovascular(), 0L))
stopifnot(identical(phoenix_cardiovascular(data = sepsis), 0L))

################################################################################
# verify error if lengths differ
x <- tryCatch(phoenix_cardiovascular(vasoactives = numeric(0)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of vasoactives is 0; Length of lactate is 1; Length of age is 1; Length of map is 1."
))

x <- tryCatch(phoenix_cardiovascular(vasoactives = c(NA, NA), age = c(NA, NA, NA)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of vasoactives is 2; Length of lactate is 1; Length of age is 3; Length of map is 1."
))


################################################################################
#                                 End of File                                  #
################################################################################
