' Tools for working with data.frames.
#'
#' To have zero namespaces in Imports but still have the performance and utility
#' of data.table and/or dplyr, the following functions are provided for working
#' with data.frames.
#'
#' `phxdft_select()` deep-copies data.table subsets (via data.table::copy()) to
#' avoid aliasing when downstream code mutates; this intentionally trades some
#' performance for isolation.
#'
#' @param x a data.frame, data.table, or tibble
#' @param i Optional. Indicates the rows on which the values must be updated. If
#'   not `NULL`, implies all rows.
#' @param j Column name (character).  For `phxdft_set` this is the column assigned
#'   `value`, update values if it exits. If `x[[j]]` does note exist it will be
#'   created.
#' @param value replacement values
#'
#' @family data.frame tools
#' @noRd
#' @name phxdft_data_frame_tools
NULL

#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_set <- function(x, i = NULL, j, value) {
  stopifnot(is.data.frame(x))
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # calling data.table::setDT to make sure that the object can be modified by
    # reference. Without data.table::setDT here we see an error if the table was
    # read from disk (e.g., readRDS()) or hand-constructed:
    #
    #   This data.table has either been loaded from disk (e.g. using
    #   readRDS()/load()) or constructed manually (e.g. using structure()).
    #   Please run setDT() or setalloccol() on it first (to pre-allocate space
    #   for new columns) before assigning by reference to it.
    #
    # data.tables read via readRDS()/load() or hand‑constructed can have an
    # invalid .internal.selfref, so the first by‑reference op (set()/:= ) errors.
    # data.table::setDT() reinitializes the selfref so data.table::set() can work
    # by reference. This wrapper keeps by-ref semantics consistent across backends.

    getExportedValue(name = "setDT", ns = "data.table")(x = x)
    getExportedValue(name = "set", ns = "data.table")(x = x, i = i, j = j, value = value)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    mutate <- getExportedValue(name = "mutate", ns = "dplyr")
    if (is.null(i)) {
      newcol <- if (nrow(x) == 0L) value[0] else value
    } else {
      newcol <- x[[j]]
      if (is.null(newcol)) {
        newcol <- rep(NA, length = nrow(x))
        storage.mode(newcol) <- typeof(value)
      }
      newcol[i] <- value
    }
    x <- do.call(mutate, c(list(.data = x), stats::setNames(list(newcol), j)))
  } else {
    if (is.null(i)) {
      x[[j]] <- value
    } else {
      if (is.null(x[[j]])) {
        x[[j]] <- rep(NA, nrow(x))
        storage.mode(x[[j]]) <- typeof(value)
      }
      x[[j]][i] <- value
    }
  }
  x
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_select <- function(x, cols) {
  stopifnot(is.data.frame(x))
  if (missing(cols)) {
    return(x)
  }

  #  # By making sure that cols is a character vector the `with = FALSE` is not
  #  # needed for data.tables which will allow for a simple call.  This is
  #  # important because `[.data.frame` will error if `with = FALSE` is passed.
  #  # `[.data.table` does not need `with = FALSE` if `j` is a character vector.
  #  stopifnot(inherits(cols, "character"))
  #  #x[, cols, drop = FALSE, with = FALSE]
  #  x[, cols, drop = FALSE]

  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # note: the data.table::copy() is needed here because x[, cols] returns a
    # shallow copy of the columns. The use of phxdft_select in the package
    # implicitly assumes deep copies. Downstream setorder()/setnames() mutate in
    # place, so copying here preserves the original. This pays a copy cost to
    # protect callers who expect an isolated subset.
    return(getExportedValue(name = "copy", ns = "data.table")(x[, cols, drop = FALSE, with = FALSE]))
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    select <- getExportedValue(name = "select", ns = "dplyr")
    all_of <- getExportedValue(name = "all_of", ns = "dplyr")
    return(select(x, all_of(cols)))
  } else {
    return(x[, cols, drop = FALSE])
  }
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_subset <- function(x, i, cols) {
  stopifnot(is.data.frame(x))

  if (missing(i)) {
    if (missing(cols)) {
      return(x)
    } else {
      return(phxdft_select(x, cols = cols))
    }
  } else {
    # match base/data.table semantics: logical i is converted to positions
    rows <- if (is.logical(i)) which(i) else i

    if (missing(cols)) {
      if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
        return(x[rows, , drop = FALSE, with = FALSE])
      } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
        slice <- getExportedValue(name = "slice", ns = "dplyr")
        return(slice(x, rows))
      } else {
        return(x[rows, , drop = FALSE])
      }
    } else {
      if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
        return(x[rows, cols, drop = FALSE, with = FALSE])
      } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
        slice  <- getExportedValue(name = "slice",  ns = "dplyr")
        select <- getExportedValue(name = "select", ns = "dplyr")
        all_of <- getExportedValue(name = "all_of", ns = "dplyr")
        x <- slice(x, rows)
        return(select(x, all_of(cols)))
      } else {
        cols_idx <- match(cols, names(x))
        return(x[rows, cols_idx, drop = FALSE])
      }
    }
  }
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_setorder <- function(x, by) {
  stopifnot(is.data.frame(x))
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    getExportedValue(name = "setorderv", ns = "data.table")(x, by)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    arrange <- getExportedValue(name = "arrange", ns = "dplyr")
    x <- do.call(arrange, c(list(.data = x), lapply(by, as.name)))
  } else {
    x <- x[do.call(order, x[by]), , drop = FALSE]
  }
  x
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_setnames <- function(x, old, new, ...) {
  stopifnot(is.data.frame(x))
  stopifnot(is.character(old), is.character(new))
  stopifnot(length(old) == length(new))
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    getExportedValue(name = "setnames", ns = "data.table")(x, old, new, ...)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    rename <- getExportedValue(name = "rename", ns = "dplyr")
    args <- c(list(.data = x), stats::setNames(lapply(old, as.name), new))
    x <- do.call(rename, args)
  } else {
    for (i in seq_len(length(old))) {
      names(x)[names(x) == old[i]] <- new[i]
    }
  }
  x
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_duplicated <- function(x, by = seq_along(x), ...) {
  stopifnot(is.data.frame(x))
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # Flag this frame as data.table-aware so duplicated.data.table uses its
    # optimized path instead of falling back to duplicated.data.frame.
    .datatable.aware <- TRUE
    rtn <- utils::getFromNamespace(x = 'duplicated.data.table', ns = "data.table")(x, by = by, ...)
  } else {  # this is for base R data.frames and tidyverse tbl_df
    rtn <- duplicated(x[, by, drop = FALSE], ...)
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_unique <- function(x, ...) {
  stopifnot(is.data.frame(x))
  if (requireNamespace(package = "data.table", quietly = TRUE) && inherits(x, "data.table")) {
    # Flag this frame as data.table-aware so unique.data.table uses its
    # optimized path instead of falling back to unique.data.frame.
    .datatable.aware <- TRUE
    rtn <- utils::getFromNamespace(x = 'unique.data.table', ns = "data.table")(x, ...)
  } else if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    rtn <- getExportedValue(name = "distinct", ns = "dplyr")(.data = x, ...)
  } else {
    rtn <- unique(x, ...)
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_left_join <- function(x, y, ...) {
  stopifnot(is.data.frame(x), is.data.frame(y))

  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    lj <- getExportedValue(name = "left_join", ns = "dplyr")
    dots <- list(...)
    if (!is.null(dots$by.x) & !is.null(dots$by.y)) {
      by <- stats::setNames(dots$by.y, dots$by.x)
      dots$by.x <- NULL
      dots$by.y <- NULL
    } else if (!is.null(dots$by)) {
      by <- dots$by
      dots$by   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots$suffixes)) {
      suffix <- dots$suffixes
      dots$suffixes <- NULL
    } else {
      suffix <- c(".x", ".y")
    }
    # normalize to dplyr's by/suffix arguments to mirror base/data.table defaults
    rtn <- do.call(what = lj, args = c(list(x = x, y = y, by = by, suffix = suffix), dots))
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::merge.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- merge(x = x, y = y, all.x = TRUE, all.y = FALSE, sort = FALSE, allow.cartesian = TRUE, ...)
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_full_outer_join <- function(x, y, ...) {
  stopifnot(is.data.frame(x), is.data.frame(y))

  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    fj <- getExportedValue(name = "full_join", ns = "dplyr")
    dots <- list(...)
    if (!is.null(dots$by.x) & !is.null(dots$by.y)) {
      by <- stats::setNames(dots$by.y, dots$by.x)
      dots$by.x <- NULL
      dots$by.y <- NULL
    } else if (!is.null(dots$by)) {
      by <- dots$by
      dots$by   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots$suffixes)) {
      suffix <- dots$suffixes
      dots$suffixes <- NULL
    } else {
      suffix <- c(".x", ".y")
    }
    # normalize to dplyr's by/suffix arguments to mirror base/data.table defaults
    rtn <- do.call(what = fj, args = c(list(x = x, y = y, by = by, suffix = suffix), dots))
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::merge.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- merge(x = x, y = y, all.x = TRUE, all.y = TRUE, sort = FALSE, allow.cartesian = TRUE, ...)
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_inner_join <- function(x, y, ...) {
  stopifnot(is.data.frame(x), is.data.frame(y))

  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    ij <- getExportedValue(name = "inner_join", ns = "dplyr")
    dots <- list(...)
    if (!is.null(dots$by.x) & !is.null(dots$by.y)) {
      by <- stats::setNames(dots$by.y, dots$by.x)
      dots$by.x <- NULL
      dots$by.y <- NULL
    } else if (!is.null(dots$by)) {
      by <- dots$by
      dots$by   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots$suffixes)) {
      suffix <- dots$suffixes
      dots$suffixes <- NULL
    } else {
      suffix <- c(".x", ".y")
    }
    # normalize to dplyr's by/suffix arguments to mirror base/data.table defaults
    rtn <- do.call(what = ij, args = c(list(x = x, y = y, by = by, suffix = suffix), dots))
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::merge.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- merge(x = x, y = y, all.x = FALSE, all.y = FALSE, sort = FALSE, ...)
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_cbind <- function(x, ...) {
  stopifnot(is.data.frame(x))
  if (requireNamespace(package = "dplyr", quietly = TRUE) && inherits(x, "tbl_df")) {
    cb <- getExportedValue(name = "bind_cols", ns = "dplyr")
    rtn <- cb(x, ...)
  } else {
    # if x is a data.table and the data.table namespace is available then the
    # data.table:::cbind.data.table method will be called and a specific block
    # for data.table is not needed here
    rtn <- cbind(x, ...)
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_aggregate <- function(y, by, data, FUN) {
  stopifnot(inherits(data, "data.frame"))
  if (inherits(data, "data.table") && requireNamespace("data.table", quietly = TRUE)) {
    .datatable.aware <- TRUE
    rtn <- data[, lapply(get(y), FUN), by = mget(by)]
  } else if (inherits(data, "tbl_df") && requireNamespace("dplyr", quietly = TRUE)) {
    stop("not yet built")
  } else {
    f <- stats::as.formula(sprintf("%s ~ %s", value.var, paste(c(id.vars, eclock), collapse = "+")))
    rtn <- stats::aggregate(x = f, data = data, FUN = FUN, ...)
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_rbindlist <- function(x) {
  if (!(is.list(x) && all(sapply(x, inherits, "data.frame")))) {
    stop("input is expected to be a list of data.frames, data.tables, or tibbles")
  }
  if (inherits(x[[1]], "data.table") && requireNamespace("data.table", quietly = TRUE)) {
    rtn <- getExportedValue(name = "rbindlist", ns = "data.table")(x, use.names = TRUE, fill = TRUE)
  } else if (inherits(data, "tbl_df") && requireNamespace("dplyr", quietly = TRUE)) {
    stop("not yet built")
  } else {
    stop("not yet built")
  }
  rtn
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_dcast <- function(data, formula, value.var) {
  stopifnot(inherits(data, "data.frame"))

  if (inherits(data, "data.table") && requireNamespace("data.table", quietly = TRUE)) {
    rtn <- getExportedValue(name = "dcast", ns = "data.table")(data = data, formula = formula, value.var = value.var)
  } else if (inherits(data, "tbl_df") && requireNamespace("dplyr", quietly = TRUE)) {
    stop("not yet built")
  } else {
    stop("not yet built")
  }
  rtn
}
