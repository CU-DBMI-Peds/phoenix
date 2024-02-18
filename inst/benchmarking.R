library(microbenchmark)
library(phoenix)

# Respiratory

N <- 1e6
resp <-
  data.frame(pfr = runif(n = N, min = 0, max = 500),
             sfr = runif(n = N, min = 0, max = 300),
             vent = sample(c(0, 1, NA), size = N, replace = TRUE),
             o2 = sample(c(0, 1, NA), size = N, replace = TRUE))

pureR <- function(pf_ratio, sf_ratio, imv, other_respiratory_support, data = parent.frame(), ...) {
  pfr <- eval(expr = substitute(pf_ratio), envir = data)
  sfr <- eval(expr = substitute(sf_ratio), envir = data)
  imv <- eval(expr = substitute(imv),      envir = data)
  ors <- eval(expr = substitute(other_respiratory_support), envir = data)

  if ( (length(pfr) != length(sfr)) | (length(pfr) != length(imv)) | (length(pfr) != length(ors)) ) {
    stop("length of all input variables are not equal")
  }

  # set "healthy" value for missing data
  pfr <- replace(pfr, which(is.na(pfr)), 500)
  sfr <- replace(sfr, which(is.na(sfr)), 500)
  imv <- as.integer(replace(imv, which(is.na(imv)), 0))
  stopifnot(all(imv %in% c(0L, 1L)))
  ors <- as.integer(replace(ors, which(is.na(ors)), 0))
  stopifnot(all(ors %in% c(0L, 1L)))
  ors <- pmax(imv, ors)

  imv * (
         ((pfr < 100) | (sfr < 148)) + 
         ((pfr < 200) | (sfr < 220))
       ) + 
  ors * ((pfr < 400) | (sfr < 292))
}

DF <- resp
DF$pureR <- pureR(pfr, sfr, vent, o2, resp)
DF$cpp   <- phoenix_respiratory(pfr, sfr, vent, o2, resp)
DF[DF$pureR != DF$cpp, ] |> head()
stopifnot(identical(DF$pureR, DF$cpp))

microbenchmark(
  R = pureR(pfr, sfr, vent, o2, resp)
  ,
  cpp = phoenix_respiratory(pfr, sfr, vent, o2, resp)
  )


