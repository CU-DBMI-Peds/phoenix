library(phoenix)

# Verify the input data structure.  If these tests fail and need to be updated
# there is almost certainly documentation that will nedd to be updated too. See
# R/data-sets.R.
stopifnot(
  exists(x = "phx"),
  is.data.frame(phx),
  !inherits(x = phx, what = "data.table"),
  !inherits(x = phx, what = "tbl_df"),
  identical(names(phx), c("encounter_id", "encounter_clock", "variable", "value")),
  isTRUE(is.character(phx[["encounter_id"]])),
  isTRUE(is.integer(phx[["encounter_clock"]])),
  isTRUE(is.character(phx[["variable"]])),
  isTRUE(is.numeric(phx[["value"]])),
  identical(
    sort(unique(phx[["encounter_id"]])),
    c("19960610", "20010609", "20220626")
  )
)

expected_variables <-
  c(
    "absolute_lymphocyte_count", # ALC; 1e3 cells per mm³
    "absolute_neutrophil_count", # ANC; 1e3 cells per mm³
    "age_months",
    "alanine_aminotransferase",  #ALT; IU/L;
    "creatinine", # mg/dL
    "diastolic_blood_pressure_arterial_line",
    "diastolic_blood_pressure_cuff",
    "fibrin_degradation_fragment", # D-dimer; mg/L FEU
    "fibrinogen",
    "fraction_of_inspired_oxygen",
    "glasgow_coma_scale_eye",
    "glasgow_coma_scale_motor",
    "glasgow_coma_scale_total",
    "glasgow_coma_scale_verbal",
    "glucose",
    "infectious_test",
    "internation_normalized_ratio", #INR
    "lactate",
    "left_pupil_fixed",
    "mean_airway_pressure_ventilator",
    "mean_arterial_pressure_arterial_line",
    "mean_arterial_pressure_cuff",
    "oxygen_flow",
    "partial_pressure_of_arterial_oxygen",
    "peripheral_capillary_oxygen_saturation", #SpO2
    "platelets",
    "positive_end_expiratory_pressure",
    "right_pupil_fixed",
    "systemic_antimicrobial_medication", # indicator
    "systemic_vasoactive_epinephrine", # indicator
    "systemic_vasoactive_milrinone", # indicator
    "systolic_blood_pressure_arterial_line", # mmHg
    "systolic_blood_pressure_cuff", # mmHg
    "total_bilirubin" # BILIRUBIN_TOT; mg/dL
  )
stopifnot(identical(sort(unique(phx[["variable"]])), expected_variables))

################################################################################
# Test prepare, and score
# Prepare input data
common_args <-
  list(
    id.vars = "encounter_id",
    eclock = "encounter_clock",
    value.var = "value"
  )

prepared_input_data <-
  list(
    age = prepare_age(
      x = subset(phx, variable == "age_months"),
      id.vars = "encounter_id",
      value.var = "value"
    ),
    alc =
      do.call(
        what = prepare_alc,
        args = c(
          common_args,
          list(x = subset(phx, variable == "absolute_lymphocyte_count"))
        )
      ),
    alt =
      do.call(
        what = prepare_alt,
        args = c(
          common_args,
          list(x = subset(phx, variable == "alanine_aminotransferase"))
        )
      ),
    anc =
      do.call(
        what = prepare_anc,
        args = c(
          common_args,
          list(x = subset(phx, variable == "absolute_neutrophil_count"))
        )
      ),
    bilirubin =
      do.call(
        what = prepare_bilirubin,
        args = c(
          common_args,
          list(x = subset(phx, variable == "total_bilirubin"))
        )
      ),
    creatinine =
      do.call(
        what = prepare_creatinine,
        args = c(
          common_args,
          list(x = subset(phx, variable == "creatinine"))
        )
      ),
    ddimer =
      do.call(
        what = prepare_ddimer,
        args = c(
          common_args,
          list(x = subset(phx, variable == "fibrin_degradation_fragment"))
        )
      ),
    dbp_arterial =
      do.call(
        what = prepare_dbp_arterial,
        args = c(
          common_args,
          list(x = subset(phx, variable == "diastolic_blood_pressure_arterial_line"))
        )
      ),
    dbp_cuff =
      do.call(
        what = prepare_dbp_cuff,
        args = c(
          common_args,
          list(x = subset(phx, variable == "diastolic_blood_pressure_cuff"))
        )
      ),
    epinephrine =
      do.call(
        what = prepare_epinephrine,
        args = c(
          common_args,
          list(x = subset(phx, variable == "systemic_vasoactive_epinephrine"))
        )
      ),
    fibrinogen =
      do.call(
        what = prepare_fibrinogen,
        args = c(
          common_args,
          list(x = subset(phx, variable == "fibrinogen"))
        )
      ),
    fio2 =
      do.call(
        what = prepare_fio2,
        args = c(
          common_args,
          list(x = subset(phx, variable == "fraction_of_inspired_oxygen"))
        )
      ),
    gcseye =
      do.call(
        what = prepare_gcseye,
        args = c(
          common_args,
          list(x = subset(phx, variable == "glasgow_coma_scale_eye"))
        )
      ),
    gcsmotor =
      do.call(
        what = prepare_gcsmotor,
        args = c(
          common_args,
          list(x = subset(phx, variable == "glasgow_coma_scale_motor"))
        )
      ),
    gcstotal =
      do.call(
        what = prepare_gcstotal,
        args = c(
          common_args,
          list(x = subset(phx, variable == "glasgow_coma_scale_total"))
        )
      ),
    gcsverbal =
      do.call(
        what = prepare_gcsverbal,
        args = c(
          common_args,
          list(x = subset(phx, variable == "glasgow_coma_scale_verbal"))
        )
      ),
    glucose =
      do.call(
        what = prepare_glucose,
        args = c(
          common_args,
          list(x = subset(phx, variable == "glucose"))
        )
      ),
    inr =
      do.call(
        what = prepare_inr,
        args = c(
          common_args,
          list(x = subset(phx, variable == "internation_normalized_ratio"))
        )
      ),
    lactate =
      do.call(
        what = prepare_lactate,
        args = c(
          common_args,
          list(x = subset(phx, variable == "lactate"))
        )
      ),
    mean_arterial_pressure_arterial =
      do.call(
        what = prepare_mean_arterial_pressure_arterial,
        args = c(
          common_args,
          list(x = subset(phx, variable == "mean_arterial_pressure_arterial_line"))
        )
      ),
    mean_arterial_pressure_cuff =
      do.call(
        what = prepare_mean_arterial_pressure_cuff,
        args = c(
          common_args,
          list(x = subset(phx, variable == "mean_arterial_pressure_cuff"))
        )
      ),
    mean_airway_pressure_ventilator =
      do.call(
        what = prepare_mean_airway_pressure_ventilator,
        args = c(
          common_args,
          list(x = subset(phx, variable == "mean_airway_pressure_ventilator"))
        )
      ),
    milrinone =
      do.call(
        what = prepare_milrinone,
        args = c(
          common_args,
          list(x = subset(phx, variable == "systemic_vasoactive_milrinone"))
        )
      ),
    o2support =
      do.call(
        what = prepare_o2support,
        args = c(
          common_args,
          list(x = subset(phx, variable == "oxygen_flow"))
        )
      ),
    pao2 =
      do.call(
        what = prepare_pao2,
        args = c(
          common_args,
          list(x = subset(phx, variable == "partial_pressure_of_arterial_oxygen"))
        )
      ),
    positive_end_expiratory_pressure =
      do.call(
        what = prepare_positive_end_expiratory_pressure,
        args = c(
          common_args,
          list(x = subset(phx, variable == "positive_end_expiratory_pressure"))
        )
      ),
    platelets =
      do.call(
        what = prepare_platelets,
        args = c(
          common_args,
          list(x = subset(phx, variable == "platelets"))
        )
      ),
    pupilleft =
      do.call(
        what = prepare_pupilleft,
        args = c(
          common_args,
          list(x = subset(phx, variable == "left_pupil_fixed"))
        )
      ),
    pupilright =
      do.call(
        what = prepare_pupilright,
        args = c(
          common_args,
          list(x = subset(phx, variable == "right_pupil_fixed"))
        )
      ),
    sbp_arterial =
      do.call(
        what = prepare_sbp_arterial,
        args = c(
          common_args,
          list(x = subset(phx, variable == "systolic_blood_pressure_arterial_line"))
        )
      ),
    sbp_cuff =
      do.call(
        what = prepare_sbp_cuff,
        args = c(
          common_args,
          list(x = subset(phx, variable == "systolic_blood_pressure_cuff"))
        )
      ),
    spo2 =
      do.call(
        what = prepare_spo2,
        args = c(
          common_args,
          list(x = subset(phx, variable == "peripheral_capillary_oxygen_saturation"))
        )
      ),
    antimicrobials =
      do.call(
        what = prepare_antimicrobials,
        args = c(
          common_args,
          list(x = subset(phx, variable == "systemic_antimicrobial_medication"))
        )
      ),
    antiinfectioustests =
      do.call(
        what = phoenix::prepare_antiinfectioustests,
        args = c(
          common_args,
          list(x = subset(phx, variable == "infectious_test"))
        )
      )
  )

stopifnot(length(prepared_input_data) == length(expected_variables))

# prepare the phoenix data
prepared_phoenix_data <-
  do.call(
    what = phoenix::prepare_phoenix_data,
    args = prepared_input_data
  )

# score the phoenix data with the default settings
scored_phoenix_data <-
  list(
    score_prepared_phoenix_data(prepared_phoenix_data),
    score_prepared_phoenix_data(prepared_phoenix_data, aggregation = "olm"),
    score_prepared_phoenix_data(prepared_phoenix_data, aggregation = "ccd"),
    score_prepared_phoenix_data(prepared_phoenix_data, aggregation = "fcd")
  )
#scored_phoenix_data <-
#  lapply(
#    scored_phoenix_data,
#    function(x) {
#      x[, c("encounter_id", names(x)[startsWith(names(x), "pss_4")])]
#    }
#  )
scored_phoenix_data <-
  Reduce(
    f = function(x, y) merge(x, y, by = c("encounter_id", "suspected_infection")),
    x = scored_phoenix_data
  )

# score the phoenix data over the whole encounter
scored_phoenix_data_Inf <-
  list(
    score_prepared_phoenix_data(prepared_phoenix_data, T1 = Inf),
    score_prepared_phoenix_data(prepared_phoenix_data, T1 = Inf, aggregation = "olm"),
    score_prepared_phoenix_data(prepared_phoenix_data, T1 = Inf, aggregation = "ccd"),
    score_prepared_phoenix_data(prepared_phoenix_data, T1 = Inf, aggregation = "fcd")
  )
#scored_phoenix_data_Inf <-
#  lapply(
#    scored_phoenix_data_Inf,
#    function(x) {
#      x[, c("encounter_id", names(x)[startsWith(names(x), "pss_4")])]
#    }
#  )
scored_phoenix_data_Inf <-
  Reduce(
    f = function(x, y) merge(x, y, by = c("encounter_id", "suspected_infection")),
    x = scored_phoenix_data_Inf
  )

expected <-
  structure(
    list(
      encounter_id        = c("19960610", "20010609", "20220626"),
      suspected_infection = c(1L, 1L,  1L),
      odss_4              = c(1L, 1L,  5L),
      pss_4               = c(1L, 1L,  5L),
      sepsis              = c(0L, 0L,  1L),
      septic_shock        = c(0L, 0L,  1L),
      odss_8              = c(1L, 3L,  8L),
      pss_8               = c(1L, 3L,  8L),
      odss_4_olm          = c(3L, 1L,  7L),
      pss_4_olm           = c(3L, 1L,  7L),
      sepsis_olm          = c(1L, 0L,  1L),
      septic_shock_olm    = c(1L, 0L,  1L),
      odss_8_olm          = c(3L, 4L, 10L),
      pss_8_olm           = c(3L, 4L, 10L),
      odss_4_ccd          = c(3L, 1L,  9L),
      pss_4_ccd           = c(3L, 1L,  9L),
      sepsis_ccd          = c(1L, 0L,  1L),
      septic_shock_ccd    = c(1L, 0L,  1L),
      odss_8_ccd          = c(3L, 4L, 12L),
      pss_8_ccd           = c(3L, 4L, 12L),
      odss_4_fcd          = c(5L, 1L, 10L),
      pss_4_fcd           = c(5L, 1L, 10L),
      sepsis_fcd          = c(1L, 0L,  1L),
      septic_shock_fcd    = c(1L, 0L,  1L),
      odss_8_fcd          = c(5L, 4L, 13L),
      pss_8_fcd           = c(5L, 4L, 13L)
    ),
    row.names = c(NA, -3L),
    class = "data.frame"
  )

expected_Inf <-
  structure(
    list(
      encounter_id        = c("19960610", "20010609", "20220626"),
      suspected_infection = c(1L, 1L,  1L),
      odss_4              = c(3L, 1L,  7L),
      pss_4               = c(3L, 1L,  7L),
      sepsis              = c(1L, 0L,  1L),
      septic_shock        = c(0L, 0L,  1L),
      odss_8              = c(3L, 3L,  9L),
      pss_8               = c(3L, 3L,  9L),
      odss_4_olm          = c(5L, 2L,  8L),
      pss_4_olm           = c(5L, 2L,  8L),
      sepsis_olm          = c(1L, 1L,  1L),
      septic_shock_olm    = c(1L, 1L,  1L),
      odss_8_olm          = c(5L, 5L, 12L),
      pss_8_olm           = c(5L, 5L, 12L),
      odss_4_ccd          = c(5L, 4L,  9L),
      pss_4_ccd           = c(5L, 4L,  9L),
      sepsis_ccd          = c(1L, 1L,  1L),
      septic_shock_ccd    = c(1L, 1L,  1L),
      odss_8_ccd          = c(5L, 7L, 13L),
      pss_8_ccd           = c(5L, 7L, 13L),
      odss_4_fcd          = c(5L, 6L, 10L),
      pss_4_fcd           = c(5L, 6L, 10L),
      sepsis_fcd          = c(1L, 1L,  1L),
      septic_shock_fcd    = c(1L, 1L,  1L),
      odss_8_fcd          = c(5L, 9L, 14L),
      pss_8_fcd           = c(5L, 9L, 14L)
    ),
    row.names = c(NA, -3L),
    class = "data.frame"
  )

stopifnot(
  identical(scored_phoenix_data, expected),
  identical(scored_phoenix_data_Inf, expected_Inf)
)

################################################################################
#                                 End of File
################################################################################

