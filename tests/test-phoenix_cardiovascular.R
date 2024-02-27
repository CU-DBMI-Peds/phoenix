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
#                                 End of File                                  #
################################################################################
