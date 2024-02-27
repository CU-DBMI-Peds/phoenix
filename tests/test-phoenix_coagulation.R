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
#                                 End of File                                  #
################################################################################
