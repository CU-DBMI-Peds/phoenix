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
#' @param map.sdbp.delta The maximum allowed difference, in minutes, between the source times for systolic and diastolic blood pressures used to estimate MAP. The default, \code{Inf}, allows any SBP/DBP pair that has already passed the blood-pressure look-back rule.
#' @param map.delta The MAP candidate freshness value, in minutes. Candidate MAP sources with effective staleness within \code{map.delta} are treated as having similar freshness, and the MAP source hierarchy breaks the tie. The default, \code{Inf}, preserves the original source-priority behavior.
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
    gcs.lookback         =  720,
    pupil.lookback       =  720,
    coag.lookback        = 1440,
    endocrine.lookback   =  720,
    immunologic.lookback = 1440,
    hepatic.lookback     = 1440,
    renal.lookback       = 1440,
    si.lookback          = Inf,
    map.sdbp.delta       = Inf,
    map.delta            = Inf,
    verbose = getOption("phoenix_verbose", interactive())
  ) {

  # Contributor notes:
  #
  # The `prepare_*()` functions each return one clinical input in a standard
  # long format:
  #   identifier columns + encounter clock + value + variable name.
  #
  # `prepare_phoenix_data()` is the step that combines those separate inputs
  # into one longitudinal data set.  The output has one row per encounter/time
  # point and one column per Phoenix input or constructed variable.  Later,
  # `score_prepared_phoenix_data()` scores this prepared data over a time
  # window such as the first 24 hours.
  #
  # The function is intentionally strict about class, identifier, and time-column
  # attributes.  If two inputs were prepared using different ID columns or
  # different encounter-clock columns, their rows cannot be safely aligned.

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
  stopifnot(is.numeric(map.sdbp.delta)       && length(map.sdbp.delta) == 1       && map.sdbp.delta >= 0)
  stopifnot(is.numeric(map.delta)            && length(map.delta) == 1            && map.delta >= 0)

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

  # Verify that every supplied input came from the matching `prepare_*()`
  # function.  This protects the rest of this function from raw data with
  # unexpected column names, missing attributes, duplicate rows, or unvalidated
  # values.
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

  # All prepared inputs must use the same encounter identifiers.  For example,
  # a caller can use c("site", "encounter_id"), but every prepared input must
  # use that same vector in the same order.
  if (!is.null(age)) {
    id.vars <- unique(lapply(c(phxdata, list(age = age)), attr, "id.vars"))
  } else {
    id.vars <- unique(lapply(phxdata, attr, "id.vars"))
  }

  if (length(id.vars) > 1L) {
    stop("All input data sets need to have the same id.vars.  This check is aggressive, the order needs to be same too..  This check is aggressive, the order needs to be same too.", call. = FALSE)
  }
  id.vars <- unlist(id.vars)

  # Every time-varying input must also use the same encounter-clock column.  The
  # exception is age: age is static for the encounter and therefore has no
  # encounter-clock attribute.
  eclock <- unique(lapply(phxdata, attr, "eclock"))
  if (length(eclock) > 1L) {
    stop("All input data sets need to have the same eclock", call. = FALSE)
  }
  eclock <- unlist(eclock)

  # Stack, cast, and sort:
  #
  # 1. Stack all prepared inputs into one long data set.
  # 2. Cast the long data set to wide form so each Phoenix variable has its own
  #    column.
  # 3. Sort by encounter ID and time.  The carry-forward code below depends on
  #    observations for the same encounter appearing together and in time order.
  f <- sprintf("%s ~ variable", paste(c(id.vars, eclock), collapse = "+"))
  if (verbose) message("stacking data...")
  phxdata <- phxdft_rbindlist(x = phxdata)
  if (verbose) message("casting data....")
  phxdata <- phxdft_dcast(data = phxdata, formula = f, value.var = "value")
  if (verbose) message("sorting data...")
  phxdata <- phxdft_setorder(phxdata, c(id.vars, eclock))

  # Last observation carried forward (LOCF).
  #
  # Clinical inputs are recorded irregularly.  At any row/time point, Phoenix
  # scoring needs the most recent value for each input, as long as the value is
  # not older than that input's look-back window.  This loop performs that
  # carry-forward and also creates `<VARIABLE>_eclock` columns so later code can
  # tell when the carried-forward value was originally observed.
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
      # `last_obs` stores the row number of the most recent non-missing value
      # seen so far.  The ID check prevents values from one encounter carrying
      # into the next encounter after the data have been sorted.
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
      # After carrying values forward, remove values that are too old for this
      # variable's look-back window.  Clearing both the value and its source time
      # keeps downstream constructed-variable checks from using stale data.
      idx <- which((phxdata[[eclock]] - phxdata[[paste0(j, "_eclock")]]) > lookback)
      phxdata <- phxdft_set(phxdata, i = idx, j = j, value = NA)
      phxdata <- phxdft_set(phxdata, i = idx, j = paste0(j, "_eclock"), value = NA)
    } else {
      # If a caller did not provide a Phoenix input, create an all-missing value
      # column and an all-missing source-time column.  This lets the constructed
      # variable code below use the same column names for every data set instead
      # of branching on which inputs were supplied.
      phxdata <- phxdft_set(x = phxdata, j = j, value = NA_real_)
      phxdata <- phxdft_set(x = phxdata, j = paste0(j, "_eclock"), value = NA_real_)
    }

    # For binary indicator inputs, missing means "no evidence of this condition"
    # for the purpose of constructed variables.  Convert those NAs to 0 so sums
    # and products behave like the indicator convention in the TeX definition.
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

  # Constructed-variable source clocks.
  #
  # The LOCF block above creates `<VARIABLE>_eclock` columns for observed EHR
  # inputs.  The variables below are different: they are derived from one or
  # more observed inputs.  For those derived values we still need a source clock
  # so downstream sanity checks can distinguish "this variable was constructed
  # from observed inputs" from "this variable has no supporting observations."
  #
  # The convention mirrors the original BigQuery timecourse SQL:
  #
  # * For a one-of-many constructed indicator, such as IMV, use the latest source
  #   clock among the positive source conditions.  A row can satisfy IMV because
  #   of a direct VENT indicator, mean airway pressure, HFOV pressure, or PEEP.
  #   If more than one source supports IMV, the most recent supporting source is
  #   the most specific statement of what is known at the current row.
  #
  # * For an all-required construction, such as bilateral fixed pupils inferred
  #   from left and right pupil inputs, use the latest source clock among the
  #   required components.  The bilateral state is only known once both sides
  #   have been observed.
  #
  # The helper below applies that convention row-wise while preserving NA when a
  # row has no supporting source clocks.  `pmax(..., na.rm = TRUE)` returns -Inf
  # for rows where every candidate is NA, so those rows are converted back to NA.
  latest_source_eclock <- function(...) {
    x <- pmax(..., na.rm = TRUE)
    x[is.infinite(x)] <- NA_real_
    x
  }

  # PaO2/FiO2 ratio.
  #
  # The oxygen value is only paired with an FiO2 that is at least as old as the
  # blood gas value.  That avoids using a ventilator setting that was recorded
  # after the oxygen measurement.
  # TeX: eq:pfr-validity and eq:pfr. `PFR_eclock` is used later by
  # `phoenix_respiratory(..., pao2.spo2.delta)` for eq:pfr-sfr-selector.
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
  phxdata <-
    phxdft_set(
      x = phxdata,
      i = idx,
      j = "PFR_eclock",
      value = phxdata[["PAO2_eclock"]][idx]
    )

  # SpO2/FiO2 ratio.
  #
  # This uses the same timing rule as the PF ratio.  It also requires SpO2 <= 97
  # because the SF ratio is less informative at high oxygen saturations.
  # TeX: eq:sfr-validity and eq:sfr. `SFR_eclock` is used later by
  # `phoenix_respiratory(..., pao2.spo2.delta)` for eq:pfr-sfr-selector.
  if (verbose) message("  SpO2/FiO2...")
  idx <- which((phxdata[["FIO2_eclock"]] <= phxdata[["SPO2_eclock"]]) & phxdata[["SPO2"]] <= 97)
  phxdata <-
    phxdft_set(
      x = phxdata,
      i = idx,
      j = "SFR",
      value = (phxdata[["SPO2"]] / phxdata[["FIO2"]])[idx]
    )
  phxdata <-
    phxdft_set(
      x = phxdata,
      i = idx,
      j = "SFR_eclock",
      value = phxdata[["SPO2_eclock"]][idx]
    )

  # Invasive Mechanical Ventilation (IMV).
  #
  # IMV is true if the EHR directly says the patient was invasively ventilated,
  # or if ventilator/airway-pressure settings imply invasive ventilation.  The
  # `VENT` column is an indicator.  `PAW_VENT`, `PAW_HFOV`, and `PAW_PEEP` are
  # airway-pressure measurements, not ventilation indicators.
  #
  # `IMV_eclock` records the latest source time among the positive source
  # conditions.  If a data set does not provide direct VENT observations, the
  # direct `VENT_eclock` column may be all missing, but IMV can still have a
  # source clock from PAW_VENT, PAW_HFOV, or PAW_PEEP.
  # TeX: eq:imv and eq:imv-conditions.
  if (verbose) message("  Invasive Mechanical Ventilation...")
  imv_vent <-
    ifelse(phxdata[["VENT"]] %in% 1, phxdata[["VENT_eclock"]], NA_real_)
  imv_paw_vent <-
    ifelse((phxdata[["PAW_VENT"]] > 0) %in% TRUE,
           phxdata[["PAW_VENT_eclock"]],
           NA_real_)
  imv_paw_hfov <-
    ifelse((phxdata[["PAW_HFOV"]] > 0) %in% TRUE,
           phxdata[["PAW_HFOV_eclock"]],
           NA_real_)
  imv_paw_peep <-
    ifelse((phxdata[["PAW_PEEP"]] > 3) %in% TRUE,
           phxdata[["PAW_PEEP_eclock"]],
           NA_real_)

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
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "IMV_eclock",
      value = latest_source_eclock(
        imv_vent,
        imv_paw_vent,
        imv_paw_hfov,
        imv_paw_peep
      )
    )

  # Other respiratory support is broader than IMV.  It is true when IMV is true,
  # when a non-invasive oxygen-support indicator is present, or when FiO2 is
  # above room air.
  #
  # `ORS_eclock` follows the same one-of-many rule as IMV.  A positive ORS value
  # can be supported by IMV, a direct oxygen-support indicator, or FiO2 above
  # room air.
  # TeX: eq:ors.
  if (verbose) message("  Other Respiratory Support...")
  ors_imv <-
    ifelse(phxdata[["IMV"]] %in% 1, phxdata[["IMV_eclock"]], NA_real_)
  ors_o2support <-
    ifelse(phxdata[["O2SUPPORT"]] %in% 1,
           phxdata[["O2SUPPORT_eclock"]],
           NA_real_)
  ors_fio2 <-
    ifelse((phxdata[["FIO2"]] > 0.21) %in% TRUE,
           phxdata[["FIO2_eclock"]],
           NA_real_)

  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "ORS",
      value =
        as.integer(
          (phxdata[["IMV"]] == 1) |
          (phxdata[["O2SUPPORT"]] %in% 1) |
          ((phxdata[["FIO2"]] > 0.21) %in% TRUE)
        )
    )
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "ORS_eclock",
      value = latest_source_eclock(ors_imv, ors_o2support, ors_fio2)
    )

  # Mean arterial pressure (MAP).
  #
  # Build the four MAP candidates described in the TeX supplement, then choose
  # the usable candidate with the MAP freshness rule.  The default
  # `map.sdbp.delta = Inf` and `map.delta = Inf` preserves the original
  # implementation: calculate MAP from any carried-forward SBP/DBP pair and
  # prefer arterial sources over cuff sources whenever available.
  #
  # TeX: eq:map-current-candidates, eq:map-current-candidate-staleness, and
  # eq:map-current-priority.
  if (verbose) message("  Mean Arterial Pressure...")
  map_selection <-
    select_map_candidate(
      mean_arterial_pressure_arterial = phxdata[["MAPA"]],
      mean_arterial_pressure_arterial_eclock = phxdata[["MAPA_eclock"]],
      sbp_arterial = phxdata[["SBPA"]],
      sbp_arterial_eclock = phxdata[["SBPA_eclock"]],
      dbp_arterial = phxdata[["DBPA"]],
      dbp_arterial_eclock = phxdata[["DBPA_eclock"]],
      mean_arterial_pressure_cuff = phxdata[["MAPC"]],
      mean_arterial_pressure_cuff_eclock = phxdata[["MAPC_eclock"]],
      sbp_cuff = phxdata[["SBPC"]],
      sbp_cuff_eclock = phxdata[["SBPC_eclock"]],
      dbp_cuff = phxdata[["DBPC"]],
      dbp_cuff_eclock = phxdata[["DBPC_eclock"]],
      eclock = phxdata[[eclock]],
      map.sdbp.delta = map.sdbp.delta,
      map.delta = map.delta
    )
  phxdata <- phxdft_set(phxdata, j = "MAP", value = map_selection[["MAP"]])
  phxdata <-
    phxdft_set(
      phxdata,
      j = "MAP_eclock",
      value = map_selection[["MAP_eclock"]]
    )
  phxdata <-
    phxdft_set(
      phxdata,
      j = "MAP_source",
      value = map_selection[["MAP_source"]]
    )

  # Glasgow Coma Scale (GCS).
  #
  # The EHR may contain either a total GCS or the three component scores.  When
  # the component scores are more recent than the total score, use the component
  # sum.  This handles common data where one component is updated while the
  # total is not.  If no total GCS has been observed, use the component sum once
  # all three components have been observed.  Ties favor the component sum to
  # match the TeX definition.
  # TeX: eq:gcs and eq:gcs-components.
  if (verbose) message("  GCS....")
  gcs_components <- phxdft_select(phxdata, c("GCSEYE", "GCSVERBAL", "GCSMOTOR"))
  gcstotal2 <- rowSums(gcs_components)
  gcstotal2_complete <- rowSums(!is.na(gcs_components)) == 3L
  gcstotal2_deltas <-
    phxdata[[eclock]] -
    phxdft_select(phxdata, c("GCSEYE_eclock", "GCSVERBAL_eclock", "GCSMOTOR_eclock"))
  gcstotal2_delta <- apply(gcstotal2_deltas, MARGIN = 1, FUN = min)

  deltatotal <- phxdata[[eclock]] - phxdata[["GCSTOTAL_eclock"]]

  # Use the reconstructed component sum when it is complete, within the GCS
  # look-back window, and at least as recent as the reported total.
  idx2 <-
    which(
      gcstotal2_complete &
      gcstotal2_delta <= gcs.lookback &
      (is.na(deltatotal) | gcstotal2_delta <= deltatotal)
    )
  # Use the reported total when it is within the GCS look-back window and newer
  # than the reconstructed component sum, or when a component sum is unavailable.
  idx <-
    which(
      !is.na(deltatotal) &
      deltatotal <= gcs.lookback &
      (!gcstotal2_complete | deltatotal < gcstotal2_delta)
    )

  phxdata <- phxdft_set(phxdata, i = idx2, j = "GCS", value = gcstotal2[idx2])
  phxdata <- phxdft_set(phxdata, i = idx,  j = "GCS", value = phxdata[["GCSTOTAL"]][idx])
  phxdata <- phxdft_set(phxdata, j = "GCS_eclock", value = NA_real_)
  phxdata <-
    phxdft_set(
      phxdata,
      i = idx2,
      j = "GCS_eclock",
      value = latest_source_eclock(
        phxdata[["GCSEYE_eclock"]][idx2],
        phxdata[["GCSVERBAL_eclock"]][idx2],
        phxdata[["GCSMOTOR_eclock"]][idx2]
      )
    )
  phxdata <-
    phxdft_set(
      phxdata,
      i = idx,
      j = "GCS_eclock",
      value = phxdata[["GCSTOTAL_eclock"]][idx]
    )

  # Fixed pupils.
  #
  # Some data sets report one combined pupil indicator.  Others report left and
  # right pupils separately.  A patient is treated as having fixed pupils if the
  # combined indicator is positive or both side-specific indicators are positive.
  #
  # `FIXEDPUPILS_eclock` uses the latest source time needed to support the
  # constructed value.  For a positive combined PUPILS input, that is simply
  # PUPILS_eclock.  For left/right inputs, bilateral fixed pupils are only known
  # after both sides have been observed, so the source clock is the later of the
  # left and right source clocks.  This follows the same reasoning as the old SQL
  # GCS construction, where a component-derived total used the greatest component
  # time.
  # TeX: eq:pupils.
  fixed_pupils_combined <-
    ifelse((phxdata[["PUPILS"]] > 0) %in% TRUE,
           phxdata[["PUPILS_eclock"]],
           NA_real_)
  fixed_pupils_sides <-
    ifelse(
      (phxdata[["PUPILLEFT"]] + phxdata[["PUPILRIGHT"]]) == 2,
      latest_source_eclock(
        phxdata[["PUPILLEFT_eclock"]],
        phxdata[["PUPILRIGHT_eclock"]]
      ),
      NA_real_
    )

  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "FIXEDPUPILS",
      value =
        as.integer(
          (phxdata[["PUPILS"]] > 0) |
          ((phxdata[["PUPILLEFT"]] + phxdata[["PUPILRIGHT"]]) == 2)
        )
    )
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "FIXEDPUPILS_eclock",
      value = latest_source_eclock(fixed_pupils_combined, fixed_pupils_sides)
    )

  # Suspected infection.
  #
  # The prepared longitudinal data keep suspected infection as a row-level
  # constructed variable.  The scoring step later collapses this to one
  # window-level indicator for each encounter.
  #
  # Suspected infection requires both antimicrobials and anti-infectious tests.
  # Use the later of the two source clocks because the constructed state is only
  # known once both pieces are available.
  # TeX: eq:suspected-infection.
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "SUSPECTED_INFECTION",
      value =
        as.integer(
          phxdata[["ANTIMICROBIALS"]] *
          phxdata[["ANTIINFECTIOUSTESTS"]]
        )
    )
  phxdata <-
    phxdft_set(
      x = phxdata,
      j = "SUSPECTED_INFECTION_eclock",
      value =
        ifelse(
          phxdata[["SUSPECTED_INFECTION"]] == 1,
          latest_source_eclock(
            phxdata[["ANTIMICROBIALS_eclock"]],
            phxdata[["ANTIINFECTIOUSTESTS_eclock"]]
          ),
          NA_real_
        )
    )

  ##############################################################################
  ### return the data set
  if (verbose) message("returning the prepared data...")
  class(phxdata) <- c("prepared_phoenix_data", class(phxdata))
  attr(phxdata, "id.vars") <- id.vars
  attr(phxdata, "eclock") <- eclock
  phxdata

}
