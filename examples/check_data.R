# Let's check the requirments for spo2, fio2, and sf_ratio
#
# Start with a large set of spo2 and fio2 values.  This includes impossible
# values.
DF <-
  expand.grid(spo2 = c(seq(-1, 101, by = 1), NA_real_, 0.89, 0.98),
              fio2 = c(seq(0.20, 1.01, by = 0.01), NA_real_))

# build a vector of sf_ratio
DF[["sf_ratio"]] <- with(DF, spo2/fio2)

# Let's add some noise to the sf_ratio for some cases
# record the old random seed so we can reset the random number generator after
# this example
if (!exists(".Random.seed", envir = .GlobalEnv)) runif(1)
oldseed <- .Random.seed
set.seed(42)

idx <- which(!is.na(DF[["sf_ratio"]]))
idx <- sample(idx, size = floor(0.1 * length(idx)))
DF[["sf_ratio"]][idx] <- DF[["sf_ratio"]][idx] + rnorm(n = length(idx))

# add some sf_ratios where the spo2 or fio2 is NA
idx <- which(is.na(DF[["sf_ratio"]]))
idx <- sample(idx, size = floor(0.5 * length(idx)))
DF[["sf_ratio"]][idx] <- runif(n = length(idx), min = 0, max = 100/0.21)
DF[["sf_ratio"]][max(idx)] <- DF[["sf_ratio"]][max(idx)] + 1

# reset the random number generator
.Random.seed <- oldseed

# Now, let's check the data
chk <-
  check_data(fio2 = fio2, spo2 = spo2, sf_ratio = sf_ratio, data = DF)

chk
print(chk, full_report = TRUE)
summary(chk)

sw <- show_warnings(chk, test = "0 <= spo2 <= 100")
head(sw)
summary(sw)
unique(sw$spo2)

sf <- show_failures(chk, test = "0 <= spo2 <= 100")
head(sf)
summary(sf)
unique(sf$spo2)

# If you want to get the indices for the considered data where the test failed:
idx <- chk[["0 <= spo2 <= 100"]]$fail
head(DF[idx, ])
