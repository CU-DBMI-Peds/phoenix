library(phoenix)
source('test-data.R')
neurologic$neuro_score <- phoenix_neurologic(gcs, pupils, neurologic)
stopifnot(identical(neurologic$expected_score, neurologic$neuro_score))
