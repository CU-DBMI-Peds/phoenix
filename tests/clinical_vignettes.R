library(phoenix)

#' # Clinical Vignettes
#'
#' These are taken from the supplemental material of
#' [@sanchez_2024_development](https://doi.org/10.1001/jama.2024.0196)
#'
#' ## Clinical Vignette 1
#'
#' A previously healthy 3-year-old girl presents to an emergency department in
#' Lima, Peru, with a temperature of 39&deg;C, tachycardia, and irritability. Blood
#' pressure with an oscillometric device is 67/32 mmHg (mean arterial pressure
#' of 43 mmHg). She is given fluid resuscitation per local best practice
#' guidelines, is started on broad spectrum antibiotics, and blood and urine
#' cultures are sent. After an hour, she becomes hypotensive again and she is
#' started on a norepinephrine drip. A complete blood count reveals
#' leukocytosis, mild anemia, and a platelet count of 95 K/&mu;L.
#'
#' _Phoenix Sepsis Score:_
#'
#' * 0 respiratory points (no hypoxemia or respiratory support)
#' * 2 cardiovascular points (1 for low mean arterial pressure for age, 1 for use of a vasoactive medication)
#' * 1 coagulation points (for low platelet count)
#' * 0 neurologic points (irritability would result in a Glasgow
#' Coma Scale of approximately 14)
#' * total = 3 points.
#'
#' _Phoenix Sepsis Criteria:_
#' The patient has suspected infection, &geq; 2 points of the Phoenix Sepsis Score, and
#' &geq;1 cardiovascular points, so she meets criteria for septic shock.
#'
cv1 <-
  phoenix(
    vasoactives = 1,  # norepinephrine drip
    map = 32 + (67 - 32) / 3, # 43.667 mmHg
    platelets = 95,
    gcs = 14, # irritability
    age = 3 * 12 # expected input for age is in months
    )

expected_cv1 <-
  structure(list(phoenix_respiratory_score = 0L,
                 phoenix_cardiovascular_score = 2L,
                 phoenix_coagulation_score = 1L,
                 phoenix_neurologic_score = 0L,
                 phoenix_sepsis_score = 3L,
                 phoenix_sepsis = 1L,
                 phoenix_septic_shock = 1L),
            class = "data.frame",
            row.names = c(NA, -1L)
  )

stopifnot("Clinical Vignette 1" = identical(cv1, expected_cv1))

#'
#' ## Clinical Vignette 2
#'
#' A 6-year-old boy with a history of prematurity presents with respiratory
#' distress to his pediatrician’s office in Tucson, Arizona. He is noted to have
#' a temperature of 38.7&deg;C, tachypnea, crackles in the left lower quadrant on
#' chest auscultation, and an oxygen saturation of 89% on room air. He is
#' started on supplemental oxygen and is transported to the local emergency
#' department via ambulance. In the emergency department, a chest X-ray shows a
#' consolidation in the left lower lobe and hazy bilateral lung opacities, so he
#' is started on antibiotics for a suspected bacterial pneumonia. His
#' respiratory status worsens, and he is started on non-invasive positive
#' pressure ventilation. While awaiting to be admitted, his level of
#' consciousness deteriorates rapidly: with nailbed pressure he only opens his
#' eyes briefly, moans in pain, and withdraws his hand (Glasgow Coma Scale: 2
#' for eye response + 2 for verbal response + 4 for motor response = 8). He is
#' intubated using rapid sequence induction and placed on a conventional
#' ventilator. During this time, his lowest mean arterial pressure using a
#' non-invasive oscillometric device is 52 mmHg and he receives a fluid bolus.
#' He is then transferred to the pediatric intensive care unit where he requires
#' a high positive end expiratory pressure and an FiO<sub>2</sub> of 0.45 to achieve an
#' oxygen saturation of 92% (S/F ratio: 204). Complete blood count and lactate
#' level reveal a platelet count of 120 K/&mu;L and a serum lactate of 2.9 mmol/L.
#' Given his platelet count below the normal reference range, a coagulation
#' panel is sent, which reveals an INR of 1.7, a D-Dimer of 4.4 mg/L, and a
#' fibrinogen of 120 mg/dL.
#'
#' _Phoenix Sepsis Score:_
#'
#' * 2 respiratory points (for an S/F ratio &lt;292 on invasive mechanical ventilator)
#' * 0 cardiovascular points (mean arterial pressure &gt;48 mmHg and Lactate level &lt;5 mmol/L)
#' * 2 coagulation points (for high INR and D-Dimer)
#' * 1 neurologic point (Glasgow Coma Scale &leq;10)
#' * total = 5 points.
#'
#' _Phoenix Sepsis Criteria:_ The patient has a suspected
#' infection, &geq;2 points of the Phoenix Sepsis Score, and 0 cardiovascular
#' points, so he meets criteria for sepsis.
#'
cv2 <-
  phoenix(
    gcs = 2 + 2 + 4, # eye + verbal + motor
    map = 52,
    imv = 1,
    sf_ratio = 92 / 0.45,
    platelets = 120,
    lactate = 2.9,
    inr = 1.7,
    d_dimer = 4.4,
    fibrinogen = 120)

expected_cv2 <-
  structure(list(phoenix_respiratory_score = 2L,
                 phoenix_cardiovascular_score = 0L,
                 phoenix_coagulation_score = 2L,
                 phoenix_neurologic_score = 1L,
                 phoenix_sepsis_score = 5L,
                 phoenix_sepsis = 1L,
                 phoenix_septic_shock = 0L),
            class = "data.frame",
            row.names = c(NA, -1L)
  )

stopifnot("Clinical Vignette 2" = identical(cv2, expected_cv2))

################################################################################
#                                 End of File                                  #
################################################################################
