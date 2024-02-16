library(phoenix)

x <- tools::assertError(phoenix_sepsis_neurologic(mtcars))
stopifnot(identical(x[[1]]$message, "fixed_pupils is not in names(mtcars)"))

x <- tools::assertError(phoenix_sepsis_neurologic(mtcars, fixed_pupils = "wt"))
stopifnot(identical(x[[1]]$message, "\"wt\" is not in names(mtcars)"))

x <- tools::assertError(phoenix_sepsis_neurologic(mtcars, fixed_pupils = wt))
stopifnot(identical(x[[1]]$message, "gcs is not in names(mtcars)"))

x <- tools::assertError(phoenix_sepsis_neurologic(mtcars, fixed_pupils = wt, gcs = "wt"))
stopifnot(identical(x[[1]]$message, "\"wt\" is not in names(mtcars)"))

DF <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
DF$target <- 0
DF$target[DF$gcs <= 10] <- 1
DF$target[DF$pupils == 1] <- 2
DF$current <- phoenix_sepsis_neurologic(DF, pupils, gcs)
stopifnot(identical(DF$target, DF$current))
