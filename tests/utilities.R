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
#                                 End of File                                  #
################################################################################
