# Utility Functions for medicalcoder
isTRUEorFALSE <- function(x) {
  # this function came from data.table
  is.logical(x) && length(x) == 1L && !is.na(x)
}
