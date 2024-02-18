# respiratory
pfRatio <- c(80, 100, 152, 200, 250, 400, 500, NA)
sfRatio <- c(79, 148, 210, 220, 272, 292, 500, NA)
imv     <- c(0:1, NA)
ors     <- c(0:1, NA)

respiratory <- expand.grid(pfr = pfRatio, sfr = sfRatio, imv = imv, ors = ors)
respiratory$expected_score <- 0L
respiratory$expected_score[respiratory$imv == 0 & respiratory$ors == 0] <- 0L
respiratory$expected_score[(respiratory$imv == 1 | respiratory$ors == 1) & (respiratory$pfr < 400 | respiratory$sfr < 292)] <- 1L
respiratory$expected_score[(respiratory$imv == 1) & ((respiratory$pfr >= 100 & respiratory$pfr < 200) | (respiratory$sfr >= 148 & respiratory$sfr < 220))] <- 2L
respiratory$expected_score[(respiratory$imv == 1) & (respiratory$pfr < 100 | respiratory$sfr < 148)] <- 3L

# neurologic
neurologic <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
neurologic$expected_score <- 0
neurologic$expected_score[which(neurologic$gcs <= 10)] <- 1
neurologic$expected_score[which(neurologic$pupils == 1)] <- 2

