library(phoenix)

################################################################################
# verify that the return is an integer vector
eg <- phoenix_immunologic(anc, alc, sepsis)
stopifnot("return is an integer vector" = is.integer(eg))

################################################################################
# verify that a single 0 is returned when nothing is passed, or just a data set
# is passed
stopifnot(identical(phoenix_immunologic(), 0L))
stopifnot(identical(phoenix_immunologic(data = sepsis), 0L))

################################################################################
# verify error if lengths differ
x <- tryCatch(phoenix_immunologic(anc = numeric(0)), error = function(e) e)
stopifnot(isTRUE(inherits(x, "error")))
stopifnot(grepl("All inputs need to either have the same length or have length 1.", x$message))

x <- tryCatch(phoenix_immunologic(anc = c(NA, NA), alc = c(NA, NA, NA)), error = function(e) e)
stopifnot(isTRUE(inherits(x, "error")))
stopifnot(grepl("All inputs need to either have the same length or have length 1.", x$message))

################################################################################
#                                 End of File                                  #
################################################################################
