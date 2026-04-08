################################################################################
# file: tests/utilities.R
#
# provide simple utility functions used in the tests/
#
# defined in this file:
#
#   functions:
#     as_data_table_if_available()
#     as_tibble_if_available()
#     make_backends()
#     sort_prepared()
################################################################################

################################################################################
# as_data_table_if_available will call data.table::as.data.table() to make a
# copy and set the data.frame x to be a data.table if and only if the data.table
# namespace is available.  Otherwise the original x is returned.
as_data_table_if_available <- function(x) {
  stopifnot(inherits(x, "data.frame"))
  if (requireNamespace(package = "data.table", quietly = TRUE)) {
    x <- getExportedValue(ns = "data.table", name = "as.data.table")(x)
  }
  x
}

################################################################################
# as_tibble_if_available will call dplyr::as_tibble() on x if and only if the
# dplyr namespace is available.  Otherwise the original x is returned.
as_tibble_if_available <- function(x) {
  stopifnot(inherits(x, "data.frame"))
  if (requireNamespace(package = "dplyr", quietly = TRUE)) {
    x <- getExportedValue(ns = "dplyr", name = "as_tibble")(x)
  }
  x
}

################################################################################
# make_backends returns the three backend variants used throughout the tests/:
# a base data.frame, a data.table when available, and a tibble when available.
# If a package namespace is not available then the original data.frame is
# returned for that backend slot.
make_backends <- function(x) {
  stopifnot(inherits(x, "data.frame"))
  list(
    DF = x,
    DT = as_data_table_if_available(x),
    TB = as_tibble_if_available(x)
  )
}

################################################################################
# sort_prepared orders a prepared longitudinal object by the encounter clock.
# The grouped preparation tests use this so value assertions are not affected by
# harmless backend-specific row ordering differences after duplicate reduction.
sort_prepared <- function(x, eclock = "minutes_from_admission") {
  stopifnot(inherits(x, "data.frame"))
  x[order(x[[eclock]]), ]
}

################################################################################
#                                 End of File                                  #
################################################################################
