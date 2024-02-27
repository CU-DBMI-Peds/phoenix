library(phoenix)

################################################################################
# verify that the return is an integer vector
eg <-
  phoenix_coagulation(platelets = platelets, inr = inr, d_dimer = d_dimer, fibrinogen = fibrinogen, data = sepsis)

stopifnot("return is an integer vector" = is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_coagulation(), 0L))
stopifnot(identical(phoenix_coagulation(data = sepsis), 0L))

################################################################################
# verify individual input scores
stopifnot(identical(phoenix_coagulation(platelets =  NA), 0L))
stopifnot(identical(phoenix_coagulation(platelets = 101), 0L))
stopifnot(identical(phoenix_coagulation(platelets = 100), 0L))
stopifnot(identical(phoenix_coagulation(platelets =  99), 1L))
stopifnot(identical(phoenix_coagulation(platelets =  c(NA, 1010, 100, 99)), c(0L, 0L, 0L, 1L)))

stopifnot(identical(phoenix_coagulation(inr =  NA), 0L))
stopifnot(identical(phoenix_coagulation(inr = 1.2), 0L))
stopifnot(identical(phoenix_coagulation(inr = 1.3), 0L))
stopifnot(identical(phoenix_coagulation(inr = 1.4), 1L))
stopifnot(identical(phoenix_coagulation(inr = c(NA, 1.2, 1.3, 1.4)), c(0L, 0L, 0L, 1L)))

stopifnot(identical(phoenix_coagulation(d_dimer =  NA), 0L))
stopifnot(identical(phoenix_coagulation(d_dimer = 1.9), 0L))
stopifnot(identical(phoenix_coagulation(d_dimer = 2.0), 0L))
stopifnot(identical(phoenix_coagulation(d_dimer = 2.1), 1L))
stopifnot(identical(phoenix_coagulation(d_dimer = c(NA, 1.9, 2.0, 2.1)), c(0L, 0L, 0L, 1L)))

stopifnot(identical(phoenix_coagulation(fibrinogen =  NA), 0L))
stopifnot(identical(phoenix_coagulation(fibrinogen = 101), 0L))
stopifnot(identical(phoenix_coagulation(fibrinogen = 100), 0L))
stopifnot(identical(phoenix_coagulation(fibrinogen =  99), 1L))
stopifnot(identical(phoenix_coagulation(fibrinogen =  c(NA, 1010, 100, 99)), c(0L, 0L, 0L, 1L)))

################################################################################
# verify one repeated value
stopifnot(identical(phoenix_coagulation(platelets = 99, fibrinogen =  c(NA, 1010, 100, 99)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(inr = 1.4,      fibrinogen =  c(NA, 1010, 100, 99)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(d_dimer = 2.1,  fibrinogen =  c(NA, 1010, 100, 99)), c(1L, 1L, 1L, 2L)))

stopifnot(identical(phoenix_coagulation(inr = 1.4,       platelets =  c(NA, 1010, 100, 99)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(d_dimer = 2.1,   platelets =  c(NA, 1010, 100, 99)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(fibrinogen = 99, platelets =  c(NA, 1010, 100, 99)), c(1L, 1L, 1L, 2L)))

stopifnot(identical(phoenix_coagulation(platelets = 99,  inr = c(NA, 1.2, 1.3, 1.4)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(d_dimer = 2.1,   inr = c(NA, 1.2, 1.3, 1.4)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(fibrinogen = 99, inr = c(NA, 1.2, 1.3, 1.4)), c(1L, 1L, 1L, 2L)))

stopifnot(identical(phoenix_coagulation(platelets = 99,  d_dimer = c(NA, 1.9, 2.0, 2.1)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(inr = 1.4,       d_dimer = c(NA, 1.9, 2.0, 2.1)), c(1L, 1L, 1L, 2L)))
stopifnot(identical(phoenix_coagulation(fibrinogen = 99, d_dimer = c(NA, 1.9, 2.0, 2.1)), c(1L, 1L, 1L, 2L)))

################################################################################
# verify error if lengths differ
x <- tryCatch(phoenix_coagulation(platelets = numeric(0)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of platelets is 0; Length of inr is 1; Length of d_dimer is 1; Length of fibrinogen is 1."
))

x <- tryCatch(phoenix_coagulation(platelets = c(NA, NA), d_dimer = c(NA, NA, NA)), error = function(e) e)
stopifnot(inherits(x, "simpleError"))
stopifnot(identical(
  x$message,
 "All inputs need to either have the same length or have length 1. Length of platelets is 2; Length of inr is 1; Length of d_dimer is 3; Length of fibrinogen is 1."
))


################################################################################
#                                 End of File                                  #
################################################################################
