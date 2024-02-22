library(phoenix)

eg <-
  phoenix_cardiovascular(
     vasoactives = dobutamine + dopamine + epinephrine + milrinone + norepinephrine + vasopressin,
     lactate = lactate,
     age = age,
     map = dbp + (sbp - dbp)/3,
     data = sepsis
  )

stopifnot(is.integer(eg))
