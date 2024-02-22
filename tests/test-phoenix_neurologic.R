library(phoenix)

eg <-
     phoenix_neurologic(
       gcs = gcs_total,
       fixed_pupils = as.integer(pupil == "both-fixed"),
       data = sepsis
     )

stopifnot(is.integer(eg))
