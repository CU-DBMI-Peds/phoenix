library(phoenix)
source('test-data.R')
respiratory$resp_score <- phoenix_respiratory(pfr, sfr, imv, ors, respiratory)
stopifnot(identical(respiratory$expected_score, respiratory$resp_score))
