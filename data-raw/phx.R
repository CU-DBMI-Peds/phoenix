################################################################################
# file:
#   phx.R
#
# objective:
#   create an example data set for the phoenix R package
#
# inputs:
#   phx.csv
#
# outputs:
#   <project_root>/data/phx.rda
#
# Assumptions:
#   This script is evaluated from the working directory
#   <project_root>/data-raw/ via the Makefile therein.
#
# Notes:
#   The input csv file was built by perturbing the data from three subjects in
#   the R01 data set.  This data is intended only for examples and tests, not
#   for analysis or validation.
################################################################################
phx <- read.csv(
  file = "phx.csv",
  colClasses = c("character", "integer", "character", "numeric")
)
names(phx) <- c("encounter_id", "encounter_clock", "variable", "value")

ages <-
  data.frame(
    encounter_id = c("19960610", "20010609", "20220626"),
    encounter_clock = NA_integer_,
    variable = "age_months",
    value = c(13.6, 193.2, 20.0),
    stringsAsFactors = FALSE
  )
phx <- rbind(ages, phx)

# rename variables to make it clear what each variable is:
variable_name_mapping <-
  c(
    "ALC" = "absolute_lymphocyte_count",
    "ALT" = "alanine_aminotransferase",
    "ANC" = "absolute_neutrophil_count",
    "BILIRUBIN_TOT" = "total_bilirubin",
    "CREATININE" = "creatinine",
    "D_DIMER" = "fibrin_degradation_fragment",
    "DBP_ART" = "diastolic_blood_pressure_arterial_line",
    "DBP_CUFF" = "diastolic_blood_pressure_cuff",
    "SBP_ART" = "systolic_blood_pressure_arterial_line",
    "SBP_CUFF" = "systolic_blood_pressure_cuff",
    "ANTIMICROBIAL_MEDICATION" = "systemic_antimicrobial_medication",
    "EPINEPHRINE" = "systemic_vasoactive_epinephrine",
    "FIBRINOGEN" = "fibrinogen",
    "FIO2" = "fraction_of_inspired_oxygen",
    "GCS_EYE" = "glasgow_coma_scale_eye",
    "GCS_MOTOR" = "glasgow_coma_scale_motor",
    "GCS_TOTAL" = "glasgow_coma_scale_total",
    "GCS_VERBAL" = "glasgow_coma_scale_verbal",
    "GLUCOSE" = "glucose",
    "INR" = "international_normalized_ratio",
    "LACTATE" = "lactate",
    "MILRINONE" = "systemic_vasoactive_milrinone",
    "INFECTIOUS_TEST" = "infectious_test",
    "MAP_ART" = "mean_arterial_pressure_arterial_line",
    "MAP_CUFF" = "mean_arterial_pressure_cuff",
    "MAP_VENT" = "mean_airway_pressure_ventilator",
    "O2_FLOW"  = "oxygen_flow",
    "PAO2" = "partial_pressure_of_arterial_oxygen",
    "PEEP_VENT" = "positive_end_expiratory_pressure",
    "PLTS" = "platelets",
    "PUPIL_RESP_L" = "left_pupil_fixed",
    "PUPIL_RESP_R" = "right_pupil_fixed",
    "SPO2" = "peripheral_capillary_oxygen_saturation"
  )

for (i in seq_len(length(variable_name_mapping))) {
  from <- names(variable_name_mapping)[i]
  to   <- variable_name_mapping[i]
  idx <- which(phx[["variable"]] == from)
  phx[["variable"]][idx] <- to
}


save(phx, file = file.path("..", "data", "phx.rda"))

################################################################################
#                                 End of File
################################################################################
