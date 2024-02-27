library(phoenix)

################################################################################
# verify that the return is an integer vector
eg <- phoenix_endocrine(glucose, sepsis)
stopifnot(is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_endocrine(), 0L))
stopifnot(identical(phoenix_endocrine(data = sepsis), 0L))

################################################################################
#                                 End of File                                  #
################################################################################
