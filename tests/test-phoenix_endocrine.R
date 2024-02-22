library(phoenix)

eg <- phoenix_endocrine(glucose, sepsis)
stopifnot(is.integer(eg))
