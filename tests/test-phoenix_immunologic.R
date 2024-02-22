library(phoenix)

eg <- phoenix_immunologic(anc, alc, sepsis)
stopifnot(is.integer(eg))
