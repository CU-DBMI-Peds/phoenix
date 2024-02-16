library(phoenix)

DF <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
DF$target <- 0
DF$target[DF$gcs <= 10] <- 1
DF$target[DF$pupils == 1] <- 2
DF$current <- phoenix_neurologic(gcs, pupils, DF)
stopifnot(identical(DF$target, DF$current))
