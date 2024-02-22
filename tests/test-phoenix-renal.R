library(phoenix)

eg <- phoenix_renal(creatinine, age, data = sepsis)
stopifnot(is.integer(eg))
