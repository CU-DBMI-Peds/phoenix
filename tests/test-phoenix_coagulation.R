library(phoenix)

eg <-
  phoenix_coagulation(platelets = platelets, inr = inr, d_dimer = d_dimer, fibrinogen = fibrinogen, data = sepsis)

stopifnot(is.integer(eg))
