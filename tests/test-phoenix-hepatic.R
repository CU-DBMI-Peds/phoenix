library(phoenix)

################################################################################
# verify that the return is an integer vector
eg <- phoenix_hepatic(bilirubin, alt, data = sepsis)
stopifnot("return is an integer vector" = is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_hepatic(), 0L))
stopifnot(identical(phoenix_hepatic(data = sepsis), 0L))

################################################################################
#                                 End of File                                  #
################################################################################
