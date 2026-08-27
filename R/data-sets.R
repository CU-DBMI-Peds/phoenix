#' sepsis
#'
#' A fully synthetic dataset with variables needed for examples and documentation
#' of the Phoenix Sepsis Criteria.
#'
#' @format a data.frame with 20 rows and 27 columns
#'
#' \tabular{rll}{
#' [,  1] \tab pid            \tab patient identification number                               \cr
#' [,  2] \tab age            \tab age in months                                               \cr
#' [,  3] \tab fio2           \tab fraction of inspired oxygen                                 \cr
#' [,  4] \tab pao2           \tab partial pressure of oxygen in arterial blood (mmHg)         \cr
#' [,  5] \tab spo2           \tab pulse oximetry                                              \cr
#' [,  6] \tab vent           \tab indicator for invasive mechanical ventilation               \cr
#' [,  7] \tab gcs_total      \tab total Glasgow Coma Scale                                    \cr
#' [,  8] \tab pupil          \tab character vector reporting if pupils are reactive or fixed. \cr
#' [,  9] \tab platelets      \tab platelets measured in 1,000 / microliter                    \cr
#' [, 10] \tab inr            \tab international normalized ratio                              \cr
#' [, 11] \tab d_dimer        \tab D-dimer; units of mg/L FEU                                  \cr
#' [, 12] \tab fibrinogen     \tab units of mg/dL                                              \cr
#' [, 13] \tab dbp            \tab diastolic blood pressure (mmHg)                             \cr
#' [, 14] \tab sbp            \tab systolic blood pressure (mmHg)                              \cr
#' [, 15] \tab lactate        \tab units of mmol/L                                             \cr
#' [, 16] \tab dobutamine     \tab indicator for receiving systemic dobutamine                 \cr
#' [, 17] \tab dopamine       \tab indicator for receiving systemic dopamine                   \cr
#' [, 18] \tab epinephrine    \tab indicator for receiving systemic epinephrine                \cr
#' [, 19] \tab milrinone      \tab indicator for receiving systemic milrinone                  \cr
#' [, 20] \tab norepinephrine \tab indicator for receiving systemic norepinephrine             \cr
#' [, 21] \tab vasopressin    \tab indicator for receiving systemic vasopressin                \cr
#' [, 22] \tab glucose        \tab units of mg/dL                                              \cr
#' [, 23] \tab anc            \tab units of 1,000 cells per cubic millimeter                   \cr
#' [, 24] \tab alc            \tab units of 1,000 cells per cubic millimeter                   \cr
#' [, 25] \tab creatinine     \tab units of mg/dL                                              \cr
#' [, 26] \tab bilirubin      \tab units of mg/dL                                              \cr
#' [, 27] \tab alt            \tab units of IU/L                                               \cr
#' }
"sepsis"

#' phx
#'
#' A synthetic dataset for three subjects' electronic health record related to
#' a full encounter.
#'
#' @format a data.frame with four columns:
#'
#' \tabular{rll}{
#' [, 1] \tab encounter_id    \tab a character string identifying the encounter. Each encounter is for a distinct patient. \cr
#' [, 2] \tab encounter_clock \tab an integer value for the running clock of the encounter in minutes.  Time 0 is the start of the encounter, time 12 is twelve minutes into the encounter. \cr
#' [, 3] \tab variable        \tab a character vector denoting the demographic, laboratory, observation, or event. \cr
#' [, 4] \tab value           \tab numeric value for the variable at the encounter_clock. \cr
#' }
#'
#' The variables reported in this dataset are as follows.  Since the value
#' column is numeric, when the following table says the value type is an
#' integer, that denotes the practical use of the variable, not the storage
#' mode.
#' \tabular{llll}{
#'  \strong{Name}                          \tab \strong{Common Abbreviation(s)} \tab \strong{Value type} \tab \strong{Units}    \cr
#'  absolute_lymphocyte_count              \tab ALC                             \tab numeric             \tab 1e3 cells per mm³ \cr
#'  absolute_neutrophil_count              \tab ANC                             \tab numeric             \tab 1e3 cells per mm³ \cr
#'  age_months                             \tab                                 \tab numeric             \tab months            \cr
#'  alanine_aminotransferase               \tab ALT                             \tab numeric             \tab IU/L              \cr
#'  creatinine                             \tab                                 \tab numeric             \tab mg/dL             \cr
#'  diastolic_blood_pressure_arterial_line \tab MAP_ART                         \tab numeric             \tab mmHg              \cr
#'  diastolic_blood_pressure_cuff          \tab MAP_CUFF                        \tab numeric             \tab mmHg              \cr
#'  fibrin_degradation_fragment            \tab D-Dimer; ddimer                 \tab numeric             \tab mg/L FEU          \cr
#'  fibrinogen                             \tab                                 \tab numeric             \tab mg/dL             \cr
#'  fraction_of_inspired_oxygen            \tab FiO2                            \tab numeric             \tab                   \cr
#'  glasgow_coma_scale_eye                 \tab GCS_EYE                         \tab integer             \tab                   \cr
#'  glasgow_coma_scale_motor               \tab GCS_MOTOR                       \tab integer             \tab                   \cr
#'  glasgow_coma_scale_total               \tab GCS_TOTAL                       \tab integer             \tab                   \cr
#'  glasgow_coma_scale_verbal              \tab GCS_VERBAL                      \tab integer             \tab                   \cr
#'  glucose                                \tab                                 \tab numeric             \tab mg/dL             \cr
#'  infectious_test                        \tab                                 \tab integer (indicator) \tab                   \cr
#'  internation_normalized_ratio           \tab INR                             \tab numeric             \tab                   \cr
#'  lactate                                \tab                                 \tab numeric             \tab mmol/L            \cr
#'  left_pupil_fixed                       \tab                                 \tab integer (indicator) \tab                   \cr
#'  mean_airway_pressure_ventilator        \tab MAP_VENT                        \tab numeric             \tab cmH2O             \cr
#'  mean_arterial_pressure_arterial_line   \tab MAP_ART                         \tab numeric             \tab mmHg              \cr
#'  mean_arterial_pressure_cuff            \tab MAP_CUFF                        \tab numeric             \tab mmHg              \cr
#'  oxygen_flow                            \tab                                 \tab numeric             \tab L/min             \cr
#'  partial_pressure_of_arterial_oxygen    \tab PaO2                            \tab numeric             \tab mmHg              \cr
#'  peripheral_capillary_oxygen_saturation \tab SpO2                            \tab numeric             \tab mmHg              \cr
#'  platelets                              \tab PLTS                            \tab numeric             \tab 1000/uL (1000 per micro-liter) \cr
#'  positive_end_expiratory_pressure       \tab PEEP; PEEP_VENT                 \tab numeric             \tab cm H2O            \cr
#'  right_pupil_fixed                      \tab                                 \tab integer (indicator) \tab                   \cr
#'  systemic_antimicrobial_medication      \tab                                 \tab integer (indicator) \tab                   \cr
#'  systemic_vasoactive_epinephrine        \tab                                 \tab integer (indicator) \tab                   \cr
#'  systemic_vasoactive_milrinone          \tab                                 \tab integer (indicator) \tab                   \cr
#'  systolic_blood_pressure_arterial_line  \tab                                 \tab mmHg                \tab                   \cr
#'  systolic_blood_pressure_cuff           \tab                                 \tab mmHg                \tab                   \cr
#'  total_bilirubin                        \tab BILIRUBIN_TOT                   \tab numeric             \tab mg/dL             \cr
#' }
"phx"
