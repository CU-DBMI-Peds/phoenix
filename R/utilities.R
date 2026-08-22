#' Tools for working with data.frames.
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
#'   `value`, update values if it exists. If `x[[j]]` does not exist it will be
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
    getExportedValue(name = "set", ns = "data.table")(x = x, i = i, j = j, value = if (nrow(x) == 0L) value[0] else value)
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
    if (!is.null(dots[["by.x"]]) & !is.null(dots[["by.y"]])) {
      by <- stats::setNames(dots[["by.y"]], dots[["by.x"]])
      dots[["by.x"]] <- NULL
      dots[["by.y"]] <- NULL
    } else if (!is.null(dots[["by"]])) {
      by <- dots[["by"]]
      dots[["by"]]   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots[["suffixes"]])) {
      suffix <- dots[["suffixes"]]
      dots[["suffixes"]] <- NULL
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
    if (!is.null(dots[["by.x"]]) & !is.null(dots[["by.y"]])) {
      by <- stats::setNames(dots[["by.y"]], dots[["by.x"]])
      dots[["by.x"]] <- NULL
      dots[["by.y"]] <- NULL
    } else if (!is.null(dots[["by"]])) {
      by <- dots[["by"]]
      dots[["by"]]   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots[["suffixes"]])) {
      suffix <- dots[["suffixes"]]
      dots[["suffixes"]] <- NULL
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
    if (!is.null(dots[["by.x"]]) & !is.null(dots[["by.y"]])) {
      by <- stats::setNames(dots[["by.y"]], dots[["by.x"]])
      dots[["by.x"]] <- NULL
      dots[["by.y"]] <- NULL
    } else if (!is.null(dots[["by"]])) {
      by <- dots[["by"]]
      dots[["by"]]   <- NULL
    } else {
      by <- NULL
    }
    if (!is.null(dots[["suffixes"]])) {
      suffix <- dots[["suffixes"]]
      dots[["suffixes"]] <- NULL
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
phxdft_rbindlist <- function(x) {
  if (!(is.list(x) && all(sapply(x, inherits, "data.frame")))) {
    stop("input is expected to be a list of data.frames, data.tables, or tibbles")
  }
  if (inherits(x[[1]], "data.table") && requireNamespace("data.table", quietly = TRUE)) {
    rtn <- getExportedValue(name = "rbindlist", ns = "data.table")(x, use.names = TRUE, fill = TRUE)
  } else if (inherits(x[[1]], "tbl_df") && requireNamespace("dplyr", quietly = TRUE)) {
    rtn <- getExportedValue(name = "bind_rows", ns = "dplyr")(x)
  } else {
    rtn <- do.call(rbind, x)
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

  vars <- phxdft_dcast_vars(formula = formula, data = data, value.var = value.var)
  id.vars <- vars[["id.vars"]]
  names_from <- vars[["names_from"]]

  if (inherits(data, "data.table") && requireNamespace("data.table", quietly = TRUE)) {
    rtn <- getExportedValue(name = "dcast", ns = "data.table")(data = data, formula = formula, value.var = value.var)
  } else if (inherits(data, "tbl_df") &&
             phxdft_namespace_available("dplyr", "1.1.0") &&
             phxdft_namespace_available("tidyr", "1.0.0")) {
    # tidyr::pivot_wider() is the tidyverse analogue to data.table::dcast().
    # Pass column names as character vectors so this wrapper can call tidyr
    # without importing or attaching tidyverse namespaces.
    rtn <-
      do.call(
        what = getExportedValue(name = "pivot_wider", ns = "tidyr"),
        args = list(
          data = data,
          id_cols = id.vars,
          names_from = names_from,
          values_from = value.var
        )
      )
  } else {
    # Base reshape() uses the older "v.name.time" naming convention.  Strip
    # the value-var prefix afterward to match data.table::dcast() and
    # tidyr::pivot_wider().
    rtn <-
      stats::reshape(
        data = as.data.frame(data, stringsAsFactors = FALSE),
        idvar = id.vars,
        timevar = names_from,
        v.names = value.var,
        direction = "wide"
    )
    names(rtn) <- sub(sprintf("^%s\\.", value.var), "", names(rtn))
    attr(rtn, "reshapeWide") <- NULL
    rownames(rtn) <- NULL
  }
  rtn
}

phxdft_namespace_available <- function(package, version = NULL) {
  if (!requireNamespace(package = package, quietly = TRUE)) {
    return(FALSE)
  }
  if (!is.null(version) && utils::packageVersion(package) < version) {
    return(FALSE)
  }
  TRUE
}

phxdft_dcast_vars <- function(formula, data, value.var) {
  if (is.character(formula)) {
    formula <- stats::as.formula(formula)
  }
  stopifnot(inherits(formula, "formula"))
  stopifnot(length(formula) == 3L)
  stopifnot(is.character(value.var), length(value.var) == 1L)

  id.vars <- all.vars(formula[[2L]])
  names_from <- all.vars(formula[[3L]])

  if (length(id.vars) < 1L) {
    stop("The left side of `formula` must identify at least one id column.", call. = FALSE)
  }
  if (length(names_from) != 1L) {
    stop("The right side of `formula` must identify exactly one names-from column.", call. = FALSE)
  }

  missing <- setdiff(c(id.vars, names_from, value.var), names(data))
  if (length(missing)) {
    stop(sprintf("Column(s) not found in `data`: %s", paste(missing, collapse = ", ")), call. = FALSE)
  }

  list(id.vars = id.vars, names_from = names_from)
}

#'
#' @rdname phxdft_data_frame_tools
#' @family data.frame tools
#' @noRd
#' @keywords internal
phxdft_aggregate <- function(data, y, by, FUN) {
  stopifnot(inherits(data, "data.frame"))
  if (inherits(data, "data.table") && requireNamespace(package = "data.table", quietly = TRUE)) {
    .datatable.aware <- TRUE
    e <- expression({data[, lapply(.SD, FUN), by = mget(by), .SDcols = y]})
    eval(e)
  } else if (inherits(data, "tbl_df") && requireNamespace(package = "dplyr", quietly = TRUE) && requireNamespace(package = "tidyselect", quietly = TRUE)) {
    gb <- utils::getFromNamespace(x = "group_by", ns = "dplyr")
    sm <- utils::getFromNamespace(x = "summarise", ns = "dplyr")
    across <- utils::getFromNamespace(x = "across", ns = "dplyr")
    allof <- utils::getFromNamespace(x = "all_of", ns = "tidyselect")
    sm(
      .data = data,
      across(allof(y), FUN),
      .by = allof(by)
    )
  } else {
    stats::aggregate(
      x = phxdft_select(data, y),
      by = phxdft_select(data, by),
      FUN = FUN
      )
  }
}
