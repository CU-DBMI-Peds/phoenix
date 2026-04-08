#' Prepare Phoenix Data
#'
#' Take the outputs from the \code{prepare_*()} and create the longitudinal data
#' set needed for assessing Phoenix Sepsis.
#'
#' @param fio2 an object returned from \code{\link{prepare_fio2}}
#' @param spo2 an object returned from \code{\link{prepare_spo2}}
#' @param pao2 an object returned from \code{\link{prepare_pao2}}
#' @param vent an object returned from \code{\link{prepare_vent}}
#' @param hfov an object returned from \code{\link{prepare_hfov}}
#' @param peep an object returned from \code{\link{prepare_peep}}
#' @param imv an object returned from \code{\link{prepare_imv}}
#' @param o2support an object returned from \code{\link{prepare_o2support}}
#' @param dobutamine an object returned from \code{\link{prepare_dobutamine}}
#' @param dopamine an object returned from \code{\link{prepare_dopamine}}
#' @param epinepherine an object returned from \code{\link{prepare_epinephrine}}
#' @param milronine an object returned from \code{\link{prepare_milronine}}
#' @param norepinephrine an object returned from \code{\link{prepare_norepinephrine}}
#' @param vasopressin an object returned from \code{\link{prepare_vaospressin}}
#' @param lactate an object returned from \code{\link{prepare_lactate}}
#' @param mapc an object returned from \code{\link{prepare_mapc}}
#' @param mapa an object returned from \code{\link{prepare_mapa}}
#' @param sbpc an object returned from \code{\link{prepare_sbpc}}
#' @param sbpa an object returned from \code{\link{prepare_sbpa}}
#' @param dbpa an object returned from \code{\link{prepare_dbpa}}
#' @param dbpc an object returned from \code{\link{prepare_dbpc}}
#' @param gcse an object returned from \code{\link{prepare_gcse}}
#' @param gcsm an object returned from \code{\link{prepare_gcsm}}
#' @param gcsv an object returned from \code{\link{prepare_gcsv}}
#' @param gcst an object returned from \code{\link{prepare_gcst}}
#' @param pupill an object returned from \code{\link{prepare_pupilr}}
#' @param pupilr an object returned from \code{\link{prepare_pupilr}}
#' @param pupils an object returned from \code{\link{prepare_pupils}}
#' @param platellets an object returned from \code{\link{prepare_platellets}}
#' @param fibrinogen an object returned from \code{\link{prepare_fibrinogen}}
#' @param inr an object returned from \code{\link{prepare_inr}}
#' @param ddimer an object returned from \code{\link{prepare_ddimer}}
#' @param glucose an object returned from \code{\link{prepare_glucose}}
#' @param alc an object returned from \code{\link{prepare_alc}}
#' @param anc an object returned from \code{\link{prepare_anc}}
#' @param billirburin an object returned from \code{\link{prepare_billirubin}}
#' @param alt an object returned from \code{\link{prepare_alt}}
#' @param creatine an object returned from \code{\link{prepare_creatine}}
#' @param age an object returned from \code{\link{prepare_age}}
#' @param antimicrobials an object returned from \code{\link{prepare_antimicrobials}}.
#' @param antiinfecioustests an object returned from \code{\link{prepare_antiinfecioustest}}.
#' @param resp.lookback The number of minutes to look back in an encounter for carry-forward respiratory values, e.g., FIO2, SPO2, IMV, ...
#' @param vaso.lookback The number of minutes to look back in an encounter for carry-forward vasocactive medication status
#' @param map.lookback The number of minutes to look back in an encounter for carry-forward blood pressure values
#' @param lac.lookback The number of minutes to look back in an encounter for carry-forward of lactate values
#' @param gcs.lookback The number of minutes to look back in an encounter for carry-forward of GCS (Eye, Verbal, Motor, and Total).
#' @param pupil.lookback The number of minutes to look back in an encounter for carry-forwared of pupil status (fixed or unfixed)
#' @param coag.lookback The number of minutes to look back in an encounter for carry-forward of coagulation variables: fibrinogen, platteles, INR, and D-Dimer.
#' @param endocrine.lookback The number of minutes to look back in an encounter for carry-forward of endocrine variables: glucose
#' @param immunologic.lookback The number of minutes to look back in an encounter for carry-forward of immunologic variables: ALC, ANC
#' @param hepatic.lookback The number of minutes to look back in an encounter for carry-forward of hepatic variables: billirubin (total), ALT
#' @param renal.lookback The number of minutes to look back in an encounter for carry-forward of renal variables: creatine
#'
#' @param verbose when \code{TRUE} print messages showing the progress
#'
#' @export
prepare_phoenix_data <-
  function(
    fio2 = NULL,
    spo2 = NULL,
    pao2 = NULL,
    vent = NULL,
    hfov = NULL,
    peep = NULL,
    imv  = NULL,
    o2support = NULL,
    dobutamine = NULL,
    dopamine = NULL,
    epinepherine = NULL,
    milronine = NULL,
    norepinephrine = NULL,
    vasopressin = NULL,
    lactate = NULL,
    mapc = NULL,
    mapa = NULL,
    sbpc = NULL,
    sbpa = NULL,
    dbpa = NULL,
    dbpc = NULL,
    gcse = NULL,
    gcsm = NULL,
    gcsv = NULL,
    gcst = NULL,
    pupill = NULL,
    pupilr = NULL,
    pupils = NULL,
    platellets = NULL,
    fibrinogen = NULL,
    inr = NULL,
    ddimer = NULL,
    glucose = NULL,
    alc = NULL,
    anc = NULL,
    billirburin = NULL,
    alt = NULL,
    creatine = NULL,
    age  = NULL,
    antimicrobials = NULL,
    antiinfecioustests = NULL,
    resp.lookback        =  360,
    vaso.lookback        =  720,
    map.lookback         =  360,
    lac.lookback         =  360,
    gcs.lookback         =  360,
    pupil.lookback       =  720,
    coag.lookback        = 1440,
    endocrine.lookback   =  720,
    immunologic.lookback = 1440,
    hepatic.lookback     = 1440,
    renal.lookback       = 1440,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  stopifnot(is.numeric(resp.lookback)        && length(resp.lookback) == 1        && resp.lookback >= 0)
  stopifnot(is.numeric(vaso.lookback)        && length(vaso.lookback) == 1        && vaso.lookback >= 0)
  stopifnot(is.numeric(map.lookback)         && length(map.lookback) == 1         && map.lookback >= 0)
  stopifnot(is.numeric(gcs.lookback)         && length(gcs.lookback) == 1         && gcs.lookback >= 0)
  stopifnot(is.numeric(pupil.lookback)       && length(pupil.lookback) == 1       && pupil.lookback >= 0)
  stopifnot(is.numeric(coag.lookback)        && length(coag.lookback) == 1        && coag.lookback >= 0)
  stopifnot(is.numeric(endocrine.lookback)   && length(endocrine.lookback) == 1   && endocrine.lookback >= 0)
  stopifnot(is.numeric(immunologic.lookback) && length(immunologic.lookback) == 1 && immunologic.lookback >= 0)
  stopifnot(is.numeric(hepatic.lookback)     && length(hepatic.lookback) == 1     && hepatic.lookback >= 0)
  stopifnot(is.numeric(renal.lookback)       && length(renal.lookback) == 1       && renal.lookback >= 0)

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
    msg <- paste0("The input to ", names(check)[!check], " needs to be processed through prepare_", names(check)[!check], "().  ")
    stop(msg, call. = FALSE)
  }

  # check that all the inputs have the same id.vars and eclocks
  id.vars <- unique(lapply(phxdata, attr, "id.vars"))
  if (length(id.vars) > 1L) {
    stop("All input data sets need to have the same id.vars", call. = FALSE)
  }
  id.vars <- unlist(id.vars)

  eclock <- unique(lapply(phxdata, attr, "eclock"))
  if (length(eclock) > 1L) {
    stop("All input data sets need to have the same eclock", call. = FALSE)
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
        idx <- which((phxdata[[eclock]] - phxdata[[paste0(j, "_eclock")]]) > resp.lookback)
        phxdata <- phxdft_set(phxdata, i = idx, j = j, value = NA)
        phxdata <- phxdft_set(phxdata, i = idx, j = paste0(j, "_eclock"), value = NA)
      }

    }
  }

  phxdata
}
