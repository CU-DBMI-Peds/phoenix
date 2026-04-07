#' Prepare Phoenix Data
#'
#' Take the outputs from the \code{prepare_*()} and create the longitudinal data
#' set needed for assessing Phoenix Sepsis.
#'
#' @param fio2 an object returned from \code{prepare_fio2()}
#' @param spo2 an object returned from \code{prepare_spo2()}
#' @param pao2 an object returned from \code{prepare_pao2()}
#'
#' @param resp_lookback The number of minutes to look back in an encounter for carry-forward respiratory values, e.g., FIO2, SPO2, IMV, ...
#' @param vaso_lookback The number of minutes to look back in an encounter for carry-forward vasocactive medication status
#' @param map_lookback The number of minutes to look back in an encounter for carry-forward blood pressure values
#' @param lac_lookback The number of minutes to look back in an encounter for carry-forward of lactate values
#' @param gcs_lookback The number of minutes to look back in an encounter for carry-forward of GCS (Eye, Verbal, Motor, and Total).
#' @param pupil_lookback The number of minutes to look back in an encounter for carry-forwared of pupil status (fixed or unfixed)
#' @param coag_lookback The number of minutes to look back in an encounter for carry-forward of coagulation variables: fibrinogen, platteles, INR, and D-Dimer.
#'
#' @param verbose when \code{TRUE} print messages showing the progress
#'
#' @export
prepare_phoenix_data <-
  function(
    fio2 = NULL,
    spo2 = NULL,
    pao2 = NULL,
    resp_lookback  = 360,
    vaso_lookback  = 720,
    map_lookback   = 360,
    lac_lookback   = 360,
    gcs_lookback   = 360,
    pupil_lookback = 720,
    coag_lookback  = 1440,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  stopifnot(is.numeric(resp_lookback)  && length(resp_lookback)  == 1 && resp_lookback >= 0)
  stopifnot(is.numeric(vaso_lookback)  && length(vaso_lookback)  == 1 && vaso_lookback >= 0)
  stopifnot(is.numeric(map_lookback)   && length(map_lookback)   == 1 && map_lookback >= 0)
  stopifnot(is.numeric(gcs_lookback)   && length(gcs_lookback)   == 1 && gcs_lookback >= 0)
  stopifnot(is.numeric(pupil_lookback) && length(pupil_lookback) == 1 && pupil_lookback >= 0)
  stopifnot(is.numeric(coag_lookback)  && length(coag_lookback)  == 1 && coag_lookback >= 0)

  phxdata <-
    list(
      fio2 = fio2,
      spo2 = spo2,
      pao2 = pao2
    )
  phxdata <- Filter(f = Negate(is.null), phxdata)

  # verify that all the input data sets are either null or phoenix_prepared
  check <-
    Map(f = function(obj, cls) { is.null(obj) || inherits(obj, cls) },
      obj = phxdata,
      cls = paste0("phoenix_prepared_", tolower(names(phxdata)))
    )
  check <- unlist(check)

  if (!all(check)) {
    msg <- paste0("The input to ", names(check)[!check], " needs to be processed through prepare_", tolower(names(check)[!check]), "().  ")
    stop(msg)
  }

  # check that all the inputs have the same id.vars and eclocks
  id.vars <- unique(lapply(phxdata, attr, "id.vars"))
  if (length(id.vars) > 1L) {
    stop("All input data sets need to have the same id.vars")
  }
  id.vars <- unlist(id.vars)

  eclock <- unique(lapply(phxdata, attr, "eclock"))
  if (length(eclock) > 1L) {
    stop("All input data sets need to have the same eclock")
  }
  eclock <- unlist(eclock)

  # stack, cast, and sort
  f <- sprintf("%s ~ variable", paste(c(id.vars, eclock), collapse = "+"))
  if (verbose) message("stacking data...")
  phxdata <- phxdft_rbindlist(x = phxdata)
  if (verbose) message("casting data....")
  phxdata <- phxdft_dcast(data = phxdata, formula = f, value.var = "value")
  if (verbose) message("sorting data...")
  phxdata <- phxdft_setorder(phxdata, c(id.vars, eclock))

  # locf
  if (verbose) message("locf....")

  row <- seq_len(nrow(phxdata))
  id <- phxdft_select(phxdata, cols = id.vars)
  id <- do.call(paste, c(id, sep = "\r\r"))

  for (j in c("FIO2", "SPO2", "PAO2")) {
    if (j %in% names(phxdata)) {
      if (verbose) message(sprintf("   %s...", j))
      obs <- !is.na(phxdata[[j]])
      last_obs <- cummax(ifelse(obs, row, 0L))
      ok <- last_obs > 0L
      ok[ok] <- id[last_obs[ok]] == id[ok]
      out <- phxdata[[j]]
      out[ok] <- out[last_obs[ok]]

      outeclock <- NA
      outeclock[ok] <- phxdata[[eclock]][last_obs[ok]]

      phxdata <- phxdft_set(phxdata, j = j, value = out)
      phxdata <- phxdft_set(phxdata, j = paste0(j, "_eclock"), value = outeclock)

      if (j %in% c("FIO2", "SPO2", "PAO2")) {
        idx <- which((phxdata[[eclock]] - phxdata[[paste0(j, "_eclock")]]) > resp_lookback)
        phxdata <- phxdft_set(phxdata, i = idx, j = j, value = NA)
        phxdata <- phxdft_set(phxdata, i = idx, j = paste0(j, "_eclock"), value = NA)
      }

    }
  }

  phxdata
}
