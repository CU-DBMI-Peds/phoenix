library(phoenix)

eg <-
  phoenix_respiratory(
    pf_ratio = pao2 / fio2,
    sf_ratio = spo2 / fio2,
    imv      = vent,
    other_respiratory_support = as.integer(fio2 > 0.21),
    data = sepsis
  )

stopifnot(is.integer(eg))
