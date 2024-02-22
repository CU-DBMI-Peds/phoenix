library(phoenix)

eg <- phoenix_hepatic(bilirubin, alt, data = sepsis)
stopifnot(is.integer(eg))
