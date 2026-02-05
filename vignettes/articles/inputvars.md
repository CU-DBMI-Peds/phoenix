Column           | Description                                                     | Units   | Expected Values   | Caveats | Look Back
`enc_id`         | Encounter ID                                                    |         |                   |         | 
`eclock`         | Encounter Clock, time, in minutes from start of admission       | Minutes | Integers [0, Inf) |         | 
`fio2`           | FiO~2~, Percent inspired oxygen                                 |         | [0.21, 1.0]       |         | 6 hours
`pao2`           | PaO~2~, Partial pressure of oxygen in arterial blood            | mmHg    | [0, Inf)          |         | 6 hours
`spo2`           | SpO~2~, Peripheral oxygen saturation (pulse ox)                 |         | Integers [0, 100] | Yes     | 6 hours
`vent`           | Indicator for invasive mechanical ventilation                   |         | {0, 1}            |         | 12 hours
`dobutamine`     | Indicator, 1 if patient is receiving systemic dobutamine        |         | {0, 1}            |         | 12 hours
`dopamine`       | Indicator, 1 if patient is receiving systemic dopamine          |         | {0, 1}            |         | 12 hours
`epinephrine`    | Indicator, 1 if patient is receiving systemic epinephrine       |         | {0, 1}            |         | 12 hours
`milrinone`      | Indicator, 1 if patient is receiving systemic milrinone         |         | {0, 1}            |         | 12 hours
`norepinephrine` | Indicator, 1 if patient is receiving systemic norepinephrine    |         | {0, 1}            |         | 12 hours
`vasopressin`    | Indicator, 1 if patient is receiving systemic vasopressin       |         | {0, 1}            |         | 12 hours
`lactate`        | Lactate                                                         | mmol/L  | [0, 50]           |         | 6 hours
`sbp_art`        | Arterial systolic blood pressure                                | mmHg    | [1, 300]          |         | 6 hours
`dbp_art`        | Arterial diastolic blood pressure                               | mmHg    | [1, 200]          |         | 6 hours
`map_art`        | Mean Arterial Pressure as reported by a-line directly           | mmHg    | [1, 300]          |         | 6 hours
`sbp_cuff`       | Systolic blood pressure from a cuff                             | mmHg    | [1, 300]          |         | 6 hours
`dbp_cuff`       | Diastolic blood pressure from a cuff                            | mmHg    | [1, 200]          |         | 6 hours
`map_cuff`       | Mean Arterial Pressure as reported directly from automated cuff | mmHg    | [1, 300]          |         | 6 hours
`platelets`      | Platelets                                                       | 1000/μL | [0, Inf)          |         | 24 hours
`inr`            | INR                                                             |         | [0, Inf)          |         | 24 hours
`fibrinogen`     | Fibrinogen                                                      | mg/dL   | [0, Inf)          |         | 24 hours
`d_dimer`        | D-Dimer                                                         | mg/L FEU| [0, 500]          |         | 24 hours
`gcs_motor`      | Glasgow Coma Motor Score                                        |         | {1, 2, 3, 4, 5, 6}|         | 12 hours
`gcs_verbal`     | Glasgow Coma Verbal Score                                       |         | {1, 2, 3, 4, 5}   |         | 12 hours
`gcs_eye`        | Glasgow Coma Eye Score                                          |         | {1, 2, 3, 4}      |         | 12 hours
`pupil`          | Indicator for pupil reactivity, 1 = both fixed, 0 otherwise     |         | {0, 1}            |         |  6 hours
