#' Prepare Phoenix Data
#'
#' Take the outputs from the \code{prepare_*()} and create the longitudinal data
#' set needed for assessing Phoenix Sepsis.
#'
#' @param fio2 an object returned from \code{\link{prepare_fio2}}
#' @param spo2 an object returned from \code{\link{prepare_spo2}}
#' @param pao2 an object returned from \code{\link{prepare_pao2}}
#' @param mean_airway_pressure_ventilator an object returned from \code{\link{prepare_mean_airway_pressure_ventilator}}
#' @param mean_airway_pressure_hfov an object returned from \code{\link{prepare_mean_airway_pressure_hfov}}
#' @param positive_end_expiratory_pressure an object returned from \code{\link{prepare_positive_end_expiratory_pressure}}
#' @param invasive_mechanical_ventilation_indicator an object returned from \code{\link{prepare_invasive_mechanical_ventilation_indicator}}
#' @param o2support an object returned from \code{\link{prepare_o2support}}
#' @param dobutamine an object returned from \code{\link{prepare_dobutamine}}
#' @param dopamine an object returned from \code{\link{prepare_dopamine}}
#' @param epinephrine an object returned from \code{\link{prepare_epinephrine}}
#' @param milrinone an object returned from \code{\link{prepare_milrinone}}
#' @param norepinephrine an object returned from \code{\link{prepare_norepinephrine}}
#' @param vasopressin an object returned from \code{\link{prepare_vasopressin}}
#' @param lactate an object returned from \code{\link{prepare_lactate}}
#' @param mean_arterial_pressure_cuff an object returned from \code{\link{prepare_mean_arterial_pressure_cuff}}
#' @param mean_arterial_pressure_arterial an object returned from \code{\link{prepare_mean_arterial_pressure_arterial}}
#' @param sbp_cuff an object returned from \code{\link{prepare_sbp_cuff}}
#' @param sbp_arterial an object returned from \code{\link{prepare_sbp_arterial}}
#' @param dbp_arterial an object returned from \code{\link{prepare_dbp_arterial}}
#' @param dbp_cuff an object returned from \code{\link{prepare_dbp_cuff}}
#' @param gcseye an object returned from \code{\link{prepare_gcseye}}
#' @param gcsmotor an object returned from \code{\link{prepare_gcsmotor}}
#' @param gcsverbal an object returned from \code{\link{prepare_gcsverbal}}
#' @param gcstotal an object returned from \code{\link{prepare_gcstotal}}
#' @param pupilleft an object returned from \code{\link{prepare_pupilleft}}
#' @param pupilright an object returned from \code{\link{prepare_pupilright}}
#' @param pupils an object returned from \code{\link{prepare_pupils}}
#' @param platelets an object returned from \code{\link{prepare_platelets}}
#' @param fibrinogen an object returned from \code{\link{prepare_fibrinogen}}
#' @param inr an object returned from \code{\link{prepare_inr}}
#' @param ddimer an object returned from \code{\link{prepare_ddimer}}
#' @param glucose an object returned from \code{\link{prepare_glucose}}
#' @param alc an object returned from \code{\link{prepare_alc}}
#' @param anc an object returned from \code{\link{prepare_anc}}
#' @param bilirubin an object returned from \code{\link{prepare_bilirubin}}
#' @param alt an object returned from \code{\link{prepare_alt}}
#' @param creatinine an object returned from \code{\link{prepare_creatinine}}
#' @param age an object returned from \code{\link{prepare_age}}
#' @param antimicrobials an object returned from \code{\link{prepare_antimicrobials}}.
#' @param antiinfectioustests an object returned from \code{\link{prepare_antiinfectioustests}}.
#' @param resp.lookback The number of minutes to look back in an encounter for carry-forward respiratory values, e.g., FIO2, SPO2, IMV, ...
#' @param vaso.lookback The number of minutes to look back in an encounter for carry-forward vasoactive medication status
#' @param bp.lookback The number of minutes to look back in an encounter for carry-forward blood pressure values
#' @param lac.lookback The number of minutes to look back in an encounter for carry-forward of lactate values
#' @param gcs.lookback The number of minutes to look back in an encounter for carry-forward of GCS (Eye, Verbal, Motor, and Total).
#' @param pupil.lookback The number of minutes to look back in an encounter for carry-forward of pupil status (fixed or unfixed)
#' @param coag.lookback The number of minutes to look back in an encounter for carry-forward of coagulation variables: fibrinogen, platelets, INR, and D-Dimer.
#' @param endocrine.lookback The number of minutes to look back in an encounter for carry-forward of endocrine variables: glucose
#' @param immunologic.lookback The number of minutes to look back in an encounter for carry-forward of immunologic variables: ALC, ANC
#' @param hepatic.lookback The number of minutes to look back in an encounter for carry-forward of hepatic variables: bilirubin (total), ALT
#' @param renal.lookback The number of minutes to look back in an encounter for carry-forward of renal variables: creatinine
#' @param si.lookback The number of minutes to look back in an encounter for carry-forward of suspected infection variables: antimicrobials medications, and anti-infectious tests.
#'
#' @param verbose when \code{TRUE} print messages showing the progress
#'
#' @export
prepare_phoenix_data <-
  function(
    fio2 = NULL,
    spo2 = NULL,
    pao2 = NULL,
    mean_airway_pressure_ventilator = NULL,
    mean_airway_pressure_hfov = NULL,
    positive_end_expiratory_pressure = NULL,
    invasive_mechanical_ventilation_indicator = NULL,
    o2support = NULL,
    dobutamine = NULL,
    dopamine = NULL,
    epinephrine = NULL,
    milrinone = NULL,
    norepinephrine = NULL,
    vasopressin = NULL,
    lactate = NULL,
    mean_arterial_pressure_cuff = NULL,
    mean_arterial_pressure_arterial = NULL,
    sbp_cuff = NULL,
    sbp_arterial = NULL,
    dbp_arterial = NULL,
    dbp_cuff = NULL,
    gcseye = NULL,
    gcsmotor = NULL,
    gcsverbal = NULL,
    gcstotal = NULL,
    pupilleft = NULL,
    pupilright = NULL,
    pupils = NULL,
    platelets = NULL,
    fibrinogen = NULL,
    inr = NULL,
    ddimer = NULL,
    glucose = NULL,
    alc = NULL,
    anc = NULL,
    bilirubin = NULL,
    alt = NULL,
    creatinine = NULL,
    age  = NULL,
    antimicrobials = NULL,
    antiinfectioustests = NULL,
    resp.lookback        =  360,
    vaso.lookback        =  720,
    bp.lookback          =  360,
    lac.lookback         =  360,
    gcs.lookback         =  360,
    pupil.lookback       =  720,
    coag.lookback        = 1440,
    endocrine.lookback   =  720,
    immunologic.lookback = 1440,
    hepatic.lookback     = 1440,
    renal.lookback       = 1440,
    si.lookback          = Inf,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  stopifnot(is.numeric(resp.lookback)        && length(resp.lookback) == 1        && resp.lookback >= 0)
  stopifnot(is.numeric(vaso.lookback)        && length(vaso.lookback) == 1        && vaso.lookback >= 0)
  stopifnot(is.numeric(bp.lookback)          && length(bp.lookback) == 1          && bp.lookback >= 0)
  stopifnot(is.numeric(gcs.lookback)         && length(gcs.lookback) == 1         && gcs.lookback >= 0)
  stopifnot(is.numeric(pupil.lookback)       && length(pupil.lookback) == 1       && pupil.lookback >= 0)
  stopifnot(is.numeric(coag.lookback)        && length(coag.lookback) == 1        && coag.lookback >= 0)
  stopifnot(is.numeric(endocrine.lookback)   && length(endocrine.lookback) == 1   && endocrine.lookback >= 0)
  stopifnot(is.numeric(immunologic.lookback) && length(immunologic.lookback) == 1 && immunologic.lookback >= 0)
  stopifnot(is.numeric(hepatic.lookback)     && length(hepatic.lookback) == 1     && hepatic.lookback >= 0)
  stopifnot(is.numeric(renal.lookback)       && length(renal.lookback) == 1       && renal.lookback >= 0)
  stopifnot(is.numeric(si.lookback)          && length(si.lookback) == 1          && si.lookback >= 0)

  phxdata <-
    list(
      fio2 = fio2,
      spo2 = spo2,
      pao2 = pao2,
      mean_airway_pressure_ventilator = mean_airway_pressure_ventilator,
      mean_airway_pressure_hfov = mean_airway_pressure_hfov,
      positive_end_expiratory_pressure = positive_end_expiratory_pressure,
      invasive_mechanical_ventilation_indicator = invasive_mechanical_ventilation_indicator,
      o2support = o2support,
      dobutamine = dobutamine,
      dopamine = dopamine,
      epinephrine = epinephrine,
      milrinone = milrinone,
      norepinephrine = norepinephrine,
      vasopressin = vasopressin,
      lactate = lactate,
      mean_arterial_pressure_cuff = mean_arterial_pressure_cuff,
      mean_arterial_pressure_arterial = mean_arterial_pressure_arterial,
      sbp_cuff = sbp_cuff,
      sbp_arterial = sbp_arterial,
      dbp_arterial = dbp_arterial,
      dbp_cuff = dbp_cuff,
      gcseye = gcseye,
      gcsmotor = gcsmotor,
      gcsverbal = gcsverbal,
      gcstotal = gcstotal,
      pupilleft = pupilleft,
      pupilright = pupilright,
      pupils = pupils,
      platelets = platelets,
      fibrinogen = fibrinogen,
      inr = inr,
      ddimer = ddimer,
      glucose = glucose,
      alc = alc,
      anc = anc,
      bilirubin = bilirubin,
      alt = alt,
      creatinine = creatinine,
      antimicrobials = antimicrobials,
      antiinfectioustests = antiinfectioustests
    )
  phxdata <- Filter(f = Negate(is.null), phxdata)

  # verify that all the input data sets are either null or phoenix_prepared
  input_names <- c(tolower(names(phxdata)), "age")
  input_classes <- paste0("phoenix_prepared_", input_names)

  check <-
    Map(f = function(obj, cls) { is.null(obj) || inherits(obj, cls) },
      obj = c(phxdata, list(age = age)),
      cls = input_classes
    )
  check <- unlist(check)

  if (!all(check)) {
    msg <- paste0("The input to ", names(check)[!check], " needs to be processed through prepare_", names(check)[!check], "().  ")
    stop(msg, call. = FALSE)
  }

  # check that all the inputs have the same id.vars and eclocks
  if (!is.null(age)) {
    id.vars <- unique(lapply(c(phxdata, list(age = age)), attr, "id.vars"))
  } else {
    id.vars <- unique(lapply(phxdata, attr, "id.vars"))
  }

  if (length(id.vars) > 1L) {
    stop("All input data sets need to have the same id.vars.  This check is aggressive, the order needs to be same too..  This check is aggressive, the order needs to be same too.", call. = FALSE)
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

  RESPVARS <- c("FIO2", "SPO2", "PAO2", "VENT", "PAW_VENT", "PAW_HFOV", "PAW_PEEP", "O2SUPPORT")
  VASOVARS <- c("DOBUTAMINE", "DOPAMINE", "EPINEPHRINE", "MILRINONE", "NOREPINEPHRINE", "VASOPRESSIN")
  MAPVARS  <- c("MAPC", "MAPA", "SBPA", "SBPC", "DBPA", "DBPC")
  CARDVARS <- c(VASOVARS, MAPVARS, "LACTATE")
  GCSVARS   <- c("GCSEYE", "GCSMOTOR", "GCSVERBAL", "GCSTOTAL")
  PUPILVARS <- c("PUPILLEFT", "PUPILRIGHT", "PUPILS")
  NEUROVARS <- c(GCSVARS, PUPILVARS)
  COAGVARS <- c("PLATELETS", "FIBRINOGEN", "INR", "DDIMER")
  ENDOVARS <- c("GLUCOSE")
  IMMUNOVARS <- c("ANC", "ALC")
  HEPATICVARS <- c("BILIRUBIN", "ALT")
  RENALVARS <- c("CREATININE")
  SIVARS <- c("ANTIINFECTIOUSTESTS", "ANTIMICROBIALS")

  for (j in c(RESPVARS, CARDVARS, NEUROVARS, COAGVARS, ENDOVARS, IMMUNOVARS, HEPATICVARS, RENALVARS, SIVARS)) {
    if (verbose) message(sprintf("   %s...", j))
    if (j %in% names(phxdata)) {
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

      if (j %in% RESPVARS) {
        lookback <- resp.lookback
      } else if (j %in% VASOVARS) {
        lookback <- vaso.lookback
      } else if (j %in% MAPVARS) {
        lookback <- bp.lookback
      } else if (j == "LACTATE") {
        lookback <- lac.lookback
      } else if (j %in% GCSVARS) {
        # infinite lookback for GCS variables at the moment, a more nuanced use
        # of the lookback follows when building the GCS varaible that will be
        # used in the scoring.
        lookback <- Inf
      } else if (j %in% PUPILVARS) {
        lookback <- pupil.lookback
      } else if (j %in% COAGVARS) {
        lookback <- coag.lookback
      } else if (j %in% ENDOVARS) {
        lookback <- endocrine.lookback
      } else if (j %in% IMMUNOVARS) {
        lookback <- immunologic.lookback
      } else if (j %in% HEPATICVARS) {
        lookback <- hepatic.lookback
      } else if (j %in% RENALVARS) {
        lookback <- renal.lookback
      } else if (j %in% SIVARS) {
        lookback <- si.lookback
      } else {
        stop(sprintf("lookback not defined for %s", j), call. = FALSE)
      }
      idx <- which((phxdata[[eclock]] - phxdata[[paste0(j, "_eclock")]]) > lookback)
      phxdata <- phxdft_set(phxdata, i = idx, j = j, value = NA)
      phxdata <- phxdft_set(phxdata, i = idx, j = paste0(j, "_eclock"), value = NA)
    } else {
      # the variable is not in the data set, create it and the _eclock column so
      # that the logic for the constructed variables will be simplier as all the
      # needed inputs will exist
      phxdata <- phxdft_set(x = phxdata, j = j, value = NA_real_)
      phxdata <- phxdft_set(x = phxdata, j = paste0(j, "_eclock"), value = NA_real_)
    }

    # for indicator variables, we will replace NA values with 0s for simplicity
    if (j %in% c(VASOVARS, PUPILVARS, SIVARS)) {
      idx <- which(is.na(phxdata[[j]]))
      phxdata <- phxdft_set(x = phxdata, i = idx, j = j, value = 0L)
    }

  }

  if (verbose) message("join age data to clinical data...")
  if (!is.null(age)) {
    phxdata <- phxdft_full_outer_join(phxdata, age, by = id.vars)
  } else {
    phxdata <- phxdft_set(phxdata, j = "AGE", value = NA_real_)
  }

  ##############################################################################
  ### Constructed variables

  # PFRatio: only valid if FIO2 is the same age, or older, than the PAO2 value.
  # TeX: eq:pfr-validity and eq:pfr.
  if (verbose) message("Constructing and combining variables...")

  if (verbose) message("  PaO2/FiO2...")
  idx <- which(phxdata[["FIO2_eclock"]] <= phxdata[["PAO2_eclock"]])
  phxdata <-
    phxdft_set(
      x = phxdata,
      i = idx,
      j = "PFR",
      value = (phxdata[["PAO2"]] / phxdata[["FIO2"]])[idx]
    )

  # SFRatio: only valid if FIO2 is the same age or, or older, than the SPO2
  # value and SPO2 <= 97.
  # TeX: eq:sfr-validity and eq:sfr.
  if (verbose) message("  SpO2/FiO2...")
  idx <- which((phxdata[["FIO2_eclock"]] <= phxdata[["SPO2_eclock"]]) & phxdata[["SPO2"]] <= 97)
  phxdata <-
    phxdft_set(
      x = phxdata,
      i = idx,
      j = "SFR",
      value = (phxdata[["SPO2"]] / phxdata[["FIO2"]])[idx]
    )

  # Invasive Mechanical Ventilation
  # TeX: eq:imv and eq:imv-conditions.
  # if the inputs are not in the data set set them to NA, this will simplify the
  # logic for flagging IMV overall.
  if (verbose) message("  Invasive Mechanical Ventilation...")
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "IMV",
      value = as.integer(
        (phxdata[["VENT"]] %in% 1) |
        ((phxdata[["PAW_VENT"]] > 0) %in% TRUE) |
        ((phxdata[["PAW_HFOV"]] > 0) %in% TRUE) |
        ((phxdata[["PAW_PEEP"]] > 3) %in% TRUE)
      )
    )

  # Other Respiratory Support
  # TeX: eq:ors.
  if (verbose) message("  Other Respiratory Support...")
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "ORS",
      value = as.integer((phxdata[["IMV"]] == 1) | (phxdata[["O2SUPPORT"]] %in% 1) | ((phxdata[["FIO2"]] > 0.21) %in% TRUE))
    )

  # Mean Arterial Pressure
  # TeX: eq:map-candidates and eq:map-priority.
  # if MAPA exists, use it, if not, then estimate from the sbp_arterial and dbp_arterial.  If
  # both of those are missing, then use MAPC, and lastly estimate from sbp_cuff
  # and dbp_cuff
  if (verbose) message("  Mean Arterial Pressure...")
  phxdata[["MAP"]] <-
    Reduce(function(a, b) ifelse(is.na(a), b, a),
      list(
        m1 = phxdata[["MAPA"]],
        m2 = 2/3 * phxdata[["DBPA"]] + 1/3 * phxdata[["SBPA"]],
        m3 = phxdata[["MAPC"]],
        m4 = 2/3 * phxdata[["DBPC"]] + 1/3 * phxdata[["SBPC"]]
      )
    )

  # GCS
  # TeX: eq:gcs and eq:gcs-components.
  # if the GSCTOTAL_eclock > max compoent eclock, use GCSTOTAL
  # if any of the components are younger than the total, use the sum of the
  # compoents
  if (verbose) message("  GCS....")
  gcs_components <- phxdft_select(phxdata, c("GCSEYE", "GCSVERBAL", "GCSMOTOR"))
  gcstotal2 <- rowSums(gcs_components)
  gcstotal2_complete <- rowSums(!is.na(gcs_components)) == 3L
  gcstotal2_deltas <-
    phxdata[[eclock]] -
    phxdft_select(phxdata, c("GCSEYE_eclock", "GCSVERBAL_eclock", "GCSMOTOR_eclock"))
  gcstotal2_delta <- apply(gcstotal2_deltas, MARGIN = 1, FUN = min)

  deltatotal <- phxdata[[eclock]] - phxdata[["GCSTOTAL_eclock"]]

  # use gcstotal2
  idx2 <-
    which(
      gcstotal2_complete &
      gcstotal2_delta <= gcs.lookback &
      (is.na(deltatotal) | gcstotal2_delta <= deltatotal)
    )
  # use gcstotal
  idx <-
    which(
      !is.na(deltatotal) &
      deltatotal <= gcs.lookback &
      (!gcstotal2_complete | deltatotal < gcstotal2_delta)
    )

  phxdata <- phxdft_set(phxdata, i = idx2, j = "GCS", value = gcstotal2[idx2])
  phxdata <- phxdft_set(phxdata, i = idx,  j = "GCS", value = phxdata[["GCSTOTAL"]][idx])

  # FIXEDPUPILS
  # TeX: eq:pupils.
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "FIXEDPUPILS",
      value =
        as.integer(
          (phxdata[["PUPILS"]] > 0) | ((phxdata[["PUPILLEFT"]] + phxdata[["PUPILRIGHT"]]) == 2)
        )
    )

  # Suspected infection
  # TeX: eq:suspected-infection.
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "SUSPECTED_INFECTION",
      value = as.integer(phxdata[["ANTIMICROBIALS"]] * phxdata[["ANTIINFECTIOUSTESTS"]])
    )

  ##############################################################################
  ### return the data set
  if (verbose) message("returning the prepared data...")
  class(phxdata) <- c("prepared_phoenix_data", class(phxdata))
  attr(phxdata, "id.vars") <- id.vars
  attr(phxdata, "eclock") <- eclock
  phxdata

}
