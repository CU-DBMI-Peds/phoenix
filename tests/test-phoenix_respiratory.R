library(phoenix)

pfRatio <- c(80, 100, 152, 200, 250, 400, 500, NA)
sfRatio <- c(79, 148, 210, 220, 272, 292, 500, NA)
imv     <- c(0:1, NA)
ors     <- c(0:1, NA)

DF <- expand.grid(pfr = pfRatio, sfr = sfRatio, imv = imv, ors = ors)

DF$resp_score <- phoenix_respiratory(pfr, sfr, imv, ors, DF)

DF$expected_score <- 0L
DF$expected_score[DF$imv == 0 & DF$ors == 0] <- 0L
DF$expected_score[(DF$imv == 1 | DF$ors == 1) & (DF$pfr < 400 | DF$sfr < 292)] <- 1L
DF$expected_score[(DF$imv == 1) & ((DF$pfr >= 100 & DF$pfr < 200) | (DF$sfr >= 148 & DF$sfr < 220))] <- 2L
DF$expected_score[(DF$imv == 1) & (DF$pfr < 100 | DF$sfr < 148)] <- 3L

stopifnot(identical(DF$expected_score, DF$resp_score))
