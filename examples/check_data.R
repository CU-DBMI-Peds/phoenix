################################################################################
# EXAMPLE 1
#
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

################################################################################
# Example 2
#
# Use the example sepsis data set provided in the phoenix package
#
# We'll focus on the elements needed for respiratory scoring.  The sepsis data
# set only has FiO2, PaO2, SpO2, and an indicator for invasive mechanical
# ventilation.  We need to build the pf_ratio, the sf_ratio, and the
# other_respiratory_support vectors.
#
# Start by checking the data that is provided.  All the checks pass.
chk <- check_data(fio2 = fio2, pao2 = pao2, spo2 = spo2, imv = vent, data = sepsis)
summary(chk)

# Let's add on a definition for other_respiratory_support
chk <- check_data(fio2 = fio2,
                  pao2 = pao2,
                  spo2 = spo2,
                  imv = vent,
                  other_respiratory_support = as.integer(fio2 > 0.21),
                  data = sepsis)
summary(chk)

# A useful feature of check_data is that it will return the "considered_data"
# which will have the vector for other_respiratory_support now
head(chk$considered_data)

# Let's build the pf_ratio,  no warnings, no failed tests.
chk <- check_data(fio2 = fio2,
                  pao2 = pao2,
                  spo2 = spo2,
                  imv = vent,
                  other_respiratory_support = as.integer(fio2 > 0.21),
                  pf_ratio = pao2 / fio2,
                  data = sepsis)
summary(chk)

# Build the sf_ratio, we now have tests with warnings and failures
chk <- check_data(fio2 = fio2,
                  pao2 = pao2,
                  spo2 = spo2,
                  imv = vent,
                  other_respiratory_support = as.integer(fio2 > 0.21),
                  pf_ratio = pao2 / fio2,
                  sf_ratio = spo2 / fio2,
                  data = sepsis)
summary(chk)

chk
show_failures(chk, test = "(spo2 <= 97) | (spo2 > 97 & is.na(sf_ratio))")

# The problem is that SpO2 > 97 which makes the sf_ratio invalid for phoenix
# scoring. See references for details.

# Let's improve the definition for the sf_ratio.  This will remove the notice of
# a failed test, but will retain the warning of a spo2 value greater than 97.
chk <- check_data(fio2 = fio2,
                  pao2 = pao2,
                  spo2 = spo2,
                  imv = vent,
                  other_respiratory_support = as.integer(fio2 > 0.21),
                  pf_ratio = pao2 / fio2,
                  sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
                  data = sepsis)
chk
summary(chk)
show_warnings(chk, test = "(spo2 <= 97) | (spo2 > 97 & is.na(sf_ratio))")
show_failures(chk, test = "(spo2 <= 97) | (spo2 > 97 & is.na(sf_ratio))")

################################################################################
# The Full sepsis data set and check
chk <- check_data(fio2 = fio2,
                  pao2 = pao2,
                  spo2 = spo2,
                  imv = vent,
                  other_respiratory_support = as.integer(fio2 > 0.21),
                  pf_ratio = pao2 / fio2,
                  sf_ratio = ifelse(spo2 <= 97, spo2 / fio2, NA_real_),
                  age = age,
                  vasoactives = dopamine + dobutamine + epinephrine + norepinephrine + milrinone + vasopressin,
                  dopamine = dopamine,
                  dobutamine = dobutamine,
                  epinephrine = epinephrine,
                  norepinephrine = norepinephrine,
                  milrinone = milrinone,
                  vasopressin = vasopressin,
                  data = sepsis)
chk
show_failures(chk, 21)
