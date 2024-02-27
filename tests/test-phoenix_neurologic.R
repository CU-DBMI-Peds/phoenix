library(phoenix)

################################################################################
# verify that the return is an integer vector
eg <-
     phoenix_neurologic(
       gcs = gcs_total,
       fixed_pupils = as.integer(pupil == "both-fixed"),
       data = sepsis
     )

stopifnot("return is an integer vector" = is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_neurologic(), 0L))
stopifnot(identical(phoenix_neurologic(data = sepsis), 0L))


################################################################################
#                                 End of File                                  #
################################################################################
