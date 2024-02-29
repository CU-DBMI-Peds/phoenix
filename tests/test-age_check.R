library(phoenix)

################################################################################
# error if non-numeric value passed:
x <- tools::assertError(age_check("A"))
stopifnot(identical(x[[1]]$message, "no applicable method for 'age_check' applied to an object of class \"character\""))
x <- tools::assertError(age_check(sepsis))
stopifnot(identical(x[[1]]$message, "no applicable method for 'age_check' applied to an object of class \"data.frame\""))

################################################################################
# No warnings
x <- age_check(sepsis$age)
stopifnot(identical(x,
  structure(list(Count = c(0L, 0L, 0L, 4L, 4L, 1L, 2L, 3L, 6L, 0L),
                 Warnings = c("", "", "", "", "", "", "", "", "", "")),
            class = "data.frame",
            row.names = c("NAs", "(-Inf, 0)", "zeros", "(  0,   1)", "[  1,  12)", "[ 12,  24)", "[ 24,  60)", "[ 60, 144)", "[144, 216]", "(216, Inf)"))
 )
)

################################################################################
# Check warnings
x <- tools::assertWarning(age_check(c(-10, 0, 820)))
stopifnot(identical(length(x), 3L))
stopifnot(identical(x[[1]]$message, "At least one negative age"))
stopifnot(identical(x[[2]]$message, "At least one age of zero reported"))
stopifnot(identical(x[[3]]$message, "At least one age exceeding 216 months (18 years) reported"))

x <- tools::assertWarning(age_check(1:18))
stopifnot(identical(length(x), 1L))
stopifnot(identical(x[[1]]$message, "All ages <= 18. Are you sure the values are months and not years?"))

################################################################################
#                                 End of File                                  #
################################################################################
