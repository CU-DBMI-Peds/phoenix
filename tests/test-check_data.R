devtools::load_all('~/R-dev/phoenix')
#devtools::document("~/R-dev/phoenix")
library(phoenix)
set.seed(42)

DATA <-
  expand.grid(imv = c(NA_integer_, 0L, 1L, 2L),
              other_respiratory_support = c(0L, 1L, 2L, NA_real_),
              fio2 = c(seq(0.20, 1.00, by = 0.1), -1.0),
              spo2 = c(seq(0, 100, by = 1), 0.88, 0.97, 0.98, -1, NA_real_),
              pao2 = c(seq(0, 101, by = 1), -1, NA_real_)
  )
DATA[["sf_ratio"]] <- DATA[["spo2"]] / DATA[["fio2"]]
DATA[["pf_ratio"]] <- DATA[["pao2"]] / DATA[["fio2"]]

# add random noise to some of the sf_ratio and pf_ratio values
idx <- sample(seq_len(nrow(DATA)), size = 1000)
DATA[["sf_ratio"]][idx] <- DATA[["sf_ratio"]][idx] + rnorm(1000)

idx <- sample(seq_len(nrow(DATA)), size = 1000)
DATA[["pf_ratio"]][idx] <- DATA[["pf_ratio"]][idx] + rnorm(1000)

# make sure there are cases where sf_ratio is provided when the fio2 and/or spo2
# is not provide
U   <- with(DATA, unique(spo2/fio2))
N   <- length(U)
idx <- which(is.na(DATA[["fio2"]]) | is.na(DATA[["spo2"]]))
idx <- sample(idx, size = N)
DATA[["sf_ratio"]][idx] <- sample(U)

# same for pf_ratio
U   <- with(DATA, unique(pao2/fio2))
N   <- length(U)
idx <- which(is.na(DATA[["fio2"]]) | is.na(DATA[["pao2"]]))
idx <- sample(idx, size = N)
DATA[["pf_ratio"]][idx] <- sample(U)

temp <-
  check_data(imv = imv,
             other_respiratory_support = other_respiratory_support,
             fio2 = fio2,
             spo2 = spo2,
             pao2 = pao2,
             sf_ratio = sf_ratio,
             pf_ratio = pf_ratio,
             data = DATA)
#lapply(temp, names)
#temp# |> print()
#temp
temp
print(temp)
summary(temp)
#show_warnings(temp, test = 4) |> head()
#with(show_fails(temp, test = 1), table(imv))

temp <-
check_data(imv = vent,
                                other_respiratory_support = as.integer(fio2 > 0.21),
                                fio2 = fio2,
                                spo2 = spo2,
                                pao2 = pao2,
                                data = sepsis)
str(temp)
print(temp)
summary(temp)
#show_fails(temp, 3)

