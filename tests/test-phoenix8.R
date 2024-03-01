library(phoenix)
set.seed(1874)

################################################################################
# respiratory

respiratory <- expand.grid(
  pfr  = c(80, 100, 152, 200, 250, 400, 500, NA),
  sfr  = c(79, 148, 210, 220, 272, 292, 500, NA),
  vent = c(0:1, NA),
  o2   = c(0:1, NA)
)
respiratory$expected_score <- 0L
respiratory$expected_score[respiratory$vent == 0 & respiratory$o2 == 0] <- 0L
respiratory$expected_score[(respiratory$vent == 1 | respiratory$o2 == 1) & (respiratory$pfr < 400 | respiratory$sfr < 292)] <- 1L
respiratory$expected_score[(respiratory$vent == 1) & ((respiratory$pfr >= 100 & respiratory$pfr < 200) | (respiratory$sfr >= 148 & respiratory$sfr < 220))] <- 2L
respiratory$expected_score[(respiratory$vent == 1) & (respiratory$pfr < 100 | respiratory$sfr < 148)] <- 3L

stopifnot(!any(is.na(respiratory$expected_score)))
stopifnot(all(respiratory$expected_score %in% 0:3))

################################################################################
# cardiovascular
cardiovascular <-
  expand.grid(vasos = c(NA, 0:6),
              lactate = c(NA, 3.2, 5, 7.8, 11, 14),
              age = c(NA, 0.4, 1, 3, 12, 18, 24, 45, 60, 61, 144, 145),
              map = c(NA, 16:52))

cardiovascular$vaso_score <- (cardiovascular$vasos > 0) + (cardiovascular$vasos > 1)
cardiovascular$lact_score <- (cardiovascular$lactate >= 5) + (cardiovascular$lactate >= 11)
cardiovascular$map_score  <- with(cardiovascular, {
      (             age <   1) * ((map < 17) + (map < 31)) +
      (age >=   1 & age <  12) * ((map < 25) + (map < 39)) +
      (age >=  12 & age <  24) * ((map < 31) + (map < 44)) +
      (age >=  24 & age <  60) * ((map < 32) + (map < 45)) +
      (age >=  60 & age < 144) * ((map < 36) + (map < 49)) +
      (age >= 144            ) * ((map < 38) + (map < 52))
              })

cardiovascular$vaso_score[is.na(cardiovascular$vaso_score)] <- 0
cardiovascular$lact_score[is.na(cardiovascular$lact_score)] <- 0
cardiovascular$map_score[is.na(cardiovascular$map_score)] <- 0

cardiovascular$expected_score <-
  with(cardiovascular, {
    as.integer(vaso_score + lact_score + map_score)
  })

stopifnot(!any(is.na(cardiovascular$expected_score)))
stopifnot(all(cardiovascular$expected_score %in% 0:6))

################################################################################
# coagulation

coagulation <-
  expand.grid(plts = c(NA, 20, 100, 150),
              inr  = c(NA, 0.2, 1.3, 1.8),
              ddmr = c(NA, 1.7, 2.0, 2.8),
              fib  = c(NA, 88, 100, 120))

coagulation$expected_score <- 0L
coagulation$expected_score[which(coagulation$plts < 100)] <-
  coagulation$expected_score[which(coagulation$plts < 100)] + 1L
coagulation$expected_score[which(coagulation$inr > 1.3)] <-
  coagulation$expected_score[which(coagulation$inr > 1.3)] + 1L
coagulation$expected_score[which(coagulation$ddmr > 2)] <-
  coagulation$expected_score[which(coagulation$ddmr > 2)] + 1L
coagulation$expected_score[which(coagulation$fib < 100)] <-
  coagulation$expected_score[which(coagulation$fib < 100)] + 1L
coagulation$expected_score <- pmin(coagulation$expected_score, 2L)

stopifnot(!any(is.na(coagulation$expected_score)))
stopifnot(all(coagulation$expected_score %in% 0:2))

################################################################################
# neurologic
neurologic <- expand.grid(gcs = c(3:15, NA), pupils = c(0, 1, NA))
neurologic$expected_score <- 0L
neurologic$expected_score[which(neurologic$gcs <= 10)] <- 1L
neurologic$expected_score[which(neurologic$pupils == 1)] <- 2L

stopifnot(!any(is.na(neurologic$expected_score)))
stopifnot(all(neurologic$expected_score %in% 0:2))

################################################################################
# endocrine
endocrine <- data.frame(glc = c(NA, 12, 50, 55, 100, 150, 178))
endocrine$expected_score <- 0L
endocrine$expected_score[which(endocrine$glc > 150)] <- 1L
endocrine$expected_score[which(endocrine$glc <  50)] <- 1L

stopifnot(!any(is.na(endocrine$expected_score)))
stopifnot(all(endocrine$expected_score %in% 0:1))

################################################################################
# immunolgic
immunolgic <- expand.grid(anc = c(NA, 200, 500, 600),
                          alc = c(NA, 500, 1000, 2000))
immunolgic$expected_score <- 0L
immunolgic$expected_score[which(immunolgic$anc < 500)] <- 1L
immunolgic$expected_score[which(immunolgic$alc < 1000)] <- 1L

stopifnot(!any(is.na(immunolgic$expected_score)))
stopifnot(all(immunolgic$expected_score %in% 0:1))

################################################################################
# renal
renal <- expand.grid(
              age = cardiovascular$age,
              creatinine = c(NA, seq(0.0, 1.1, by = 0.1)))
renal$expected_score <- 0L
renal$expected_score[which(                   renal$age <   1 & renal$creatinine >= 0.8)] <- 1L
renal$expected_score[which(  1 <= renal$age & renal$age <  12 & renal$creatinine >= 0.3)] <- 1L
renal$expected_score[which( 12 <= renal$age & renal$age <  24 & renal$creatinine >= 0.4)] <- 1L
renal$expected_score[which( 24 <= renal$age & renal$age <  60 & renal$creatinine >= 0.6)] <- 1L
renal$expected_score[which( 60 <= renal$age & renal$age < 144 & renal$creatinine >= 0.7)] <- 1L
renal$expected_score[which(144 <= renal$age                   & renal$creatinine >= 1.0)] <- 1L

stopifnot(!any(is.na(renal$expected_score)))
stopifnot(all(renal$expected_score %in% 0:1))

################################################################################
# hepatic
hepatic <- expand.grid(bil = c(NA, 3.2, 4.0, 4.3), alt = c(NA, 99, 102, 106))
hepatic$expected_score <- 0L
hepatic$expected_score[which(hepatic$bil >= 4)] <- 1L
hepatic$expected_score[which(hepatic$alt > 102)] <- 1L

stopifnot(!any(is.na(hepatic$expected_score)))
stopifnot(all(hepatic$expected_score %in% 0:1))

################################################################################
# Verify each component score
respiratory$phoenix_resp <-
  phoenix_respiratory(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2, data = respiratory)

cardiovascular$phoenix_card <-
  phoenix_cardiovascular(vasoactives = vasos, lactate = lactate, age = age, map = map, data = cardiovascular)

coagulation$phoenix_coag <-
  phoenix_coagulation(platelets = plts, inr = inr, d_dimer = ddmr, fibrinogen = fib, data = coagulation)

neurologic$phoenix_neur <-
  phoenix_neurologic(gcs = gcs, fixed_pupils = pupils, data = neurologic)

endocrine$phoenix_endo <-
  phoenix_endocrine(glucose = glc, data = endocrine)

immunolgic$phoenix_immu <-
  phoenix_immunologic(anc = anc, alc = alc, data = immunolgic)

renal$phoenix_renal <-
  phoenix_renal(creatinine = creatinine, age = age, data = renal)

hepatic$phoenix_hep <-
  phoenix_hepatic(bilirubin = bil, alt = alt, data = hepatic)

stopifnot(identical(respiratory$expected_score, respiratory$phoenix_resp))
stopifnot(identical(cardiovascular$expected_score, cardiovascular$phoenix_card))
stopifnot(identical(coagulation$expected_score, coagulation$phoenix_coag))
stopifnot(identical(neurologic$expected_score, neurologic$phoenix_neur))
stopifnot(identical(endocrine$expected_score, endocrine$phoenix_endo))
stopifnot(identical(immunolgic$expected_score, immunolgic$phoenix_immu))
stopifnot(identical(renal$expected_score, renal$phoenix_renal))
stopifnot(identical(hepatic$expected_score, hepatic$phoenix_hep))

################################################################################
# test the total score
#
# NOTE: because age is part of both cardiovascular and renal scoring make sure
# to get rows with the same age from both sets:

N <- 1e5
DF <-
  list(respiratory, cardiovascular, coagulation, neurologic, endocrine, immunolgic, hepatic)
DF <-
  lapply(DF,
         function(x) {
           idx <- sample(1:nrow(x), size = N, replace = TRUE)
           rtn <- x[idx, ]
           rtn <- rtn[, -which(names(rtn) == "expected_score")]
           rtn
         })
DF <- do.call(cbind, args = DF)

DF$creatinine <- NA
DF$phoenix_renal <- NA

for (a in unique(DF$age)) {
  temp_renal <- renal[renal$age %in% a, c("creatinine", "phoenix_renal")]
  temp_renal <- temp_renal[sample(1:nrow(temp_renal), size = sum(a %in% DF$age), replace = TRUE), ]
  DF$creatinine[DF$age %in% a] <- temp_renal$creatinine
  DF$phoenix_renal[DF$age %in% a] <- temp_renal$phoenix_renal
}

expected_phoenix8 <-
  data.frame(phoenix_respiratory_score = DF$phoenix_resp,
             phoenix_cardiovascular_score = DF$phoenix_card,
             phoenix_coagulation_score = DF$phoenix_coag,
             phoenix_neurologic_score = DF$phoenix_neur,
             phoenix_sepsis_score = DF$phoenix_resp + DF$phoenix_card + DF$phoenix_coag + DF$phoenix_neur,
             phoenix_sepsis = as.integer(DF$phoenix_resp + DF$phoenix_card + DF$phoenix_coag + DF$phoenix_neur > 1),
             phoenix_septic_shock = as.integer((DF$phoenix_card > 0) & (DF$phoenix_resp + DF$phoenix_card + DF$phoenix_coag + DF$phoenix_neur > 1)),
             phoenix_endocrine_score = DF$phoenix_endo,
             phoenix_immunologic_score = DF$phoenix_immu,
             phoenix_renal_score = DF$phoenix_renal,
             phoenix_hepatic_score = DF$phoenix_hep,
             phoenix8_sepsis_score = DF$phoenix_resp + DF$phoenix_card + DF$phoenix_coag + DF$phoenix_neur +
                                     DF$phoenix_endo + DF$phoenix_immu + DF$phoenix_renal + DF$phoenix_hep
  )

realized_phoenix <-
  phoenix(pf_ratio = pfr,
           sf_ratio = sfr,
           imv = vent,
           other_respiratory_support = o2,
           vasoactives = vasos,
           lactate = lactate,
           map = map,
           platelets = plts,
           inr = inr,
           d_dimer = ddmr,
           fibrinogen = fib,
           gcs = gcs,
           fixed_pupils = pupils,
           age = age,
           data = DF)

stopifnot(identical(ncol(realized_phoenix), 7L))
stopifnot(identical(names(realized_phoenix),
          c("phoenix_respiratory_score", "phoenix_cardiovascular_score",
            "phoenix_coagulation_score", "phoenix_neurologic_score",
            "phoenix_sepsis_score", "phoenix_sepsis", "phoenix_septic_shock")))

stopifnot(
  all.equal(
            expected_phoenix8[, 1:7]
            ,
            realized_phoenix
  )
)

realized_phoenix8 <-
  phoenix8(pf_ratio = pfr,
           sf_ratio = sfr,
           imv = vent,
           other_respiratory_support = o2,
           vasoactives = vasos,
           lactate = lactate,
           map = map,
           platelets = plts,
           inr = inr,
           d_dimer = ddmr,
           fibrinogen = fib,
           gcs = gcs,
           fixed_pupils = pupils,
           glucose = glc,
           anc = anc,
           alc = alc,
           creatinine = creatinine,
           bilirubin = bil,
           alt = alt,
           age = age,
           data = DF)

stopifnot(identical(ncol(realized_phoenix8), 12L))
stopifnot(identical(names(realized_phoenix8),
          c("phoenix_respiratory_score", "phoenix_cardiovascular_score",
            "phoenix_coagulation_score", "phoenix_neurologic_score",
            "phoenix_sepsis_score", "phoenix_sepsis", "phoenix_septic_shock",
            "phoenix_endocrine_score", "phoenix_immunologic_score",
            "phoenix_renal_score", "phoenix_hepatic_score",
            "phoenix8_sepsis_score")))

stopifnot(
  all.equal(
            expected_phoenix8
            ,
            realized_phoenix8
  )
)

# verify that the result are the same when called differently
resp_a <- phoenix_respiratory(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2, data = DF)
resp_b <- with(DF, phoenix_respiratory(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2))
x1 <- DF$pfr; x2 <- DF$sfr; x3 <- DF$vent; x4 <- DF$o2
resp_c <- phoenix_respiratory(x1, x2, x3, x4)
stopifnot(identical(resp_a, resp_b))
stopifnot(identical(resp_a, resp_c))

# phoenix
p_a <- phoenix(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2, vasoactives = vasos, lactate = lactate, map = map, platelets = plts, inr = inr, d_dimer = ddmr, fibrinogen = fib, gcs = gcs, fixed_pupils = pupils, glucose = glc, anc = anc, alc = alc, creatinine = creatinine, bilirubin = bil, alt = alt, age = age, data = DF)
p8_a <- phoenix8(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2, vasoactives = vasos, lactate = lactate, map = map, platelets = plts, inr = inr, d_dimer = ddmr, fibrinogen = fib, gcs = gcs, fixed_pupils = pupils, glucose = glc, anc = anc, alc = alc, creatinine = creatinine, bilirubin = bil, alt = alt, age = age, data = DF)

p_b <- with(DF, phoenix(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2, vasoactives = vasos, lactate = lactate, map = map, platelets = plts, inr = inr, d_dimer = ddmr, fibrinogen = fib, gcs = gcs, fixed_pupils = pupils, glucose = glc, anc = anc, alc = alc, creatinine = creatinine, bilirubin = bil, alt = alt, age = age))
p8_b <- with(DF, phoenix8(pf_ratio = pfr, sf_ratio = sfr, imv = vent, other_respiratory_support = o2, vasoactives = vasos, lactate = lactate, map = map, platelets = plts, inr = inr, d_dimer = ddmr, fibrinogen = fib, gcs = gcs, fixed_pupils = pupils, glucose = glc, anc = anc, alc = alc, creatinine = creatinine, bilirubin = bil, alt = alt, age = age))

x1 <- DF$pfr; x2 <- DF$sfr; x3 <- DF$vent; x4 <- DF$o2
x5 <- DF$vasos; x6 <- DF$lactate; x7 <- DF$map
x8 <- DF$plts; x9 <- DF$inr; x10 <- DF$ddmr; x11 <- DF$fib;
x12 <- DF$gcs; x13 <- DF$pupils;
x14 <- DF$glc; x15 <- DF$anc; x16 <- DF$alc; x17 <- DF$creatinine;
x18 <- DF$bil; x19 <- DF$alt; x20 <- DF$age

p_c <- phoenix(x1, x2, x3, x4,
               x5, x6, x7,
               x8, x9, x10, x11,
               x12, x13, x20)
p8_c <- phoenix8(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20)

stopifnot(identical(p_a, p_b))
stopifnot(identical(p_a, p_c))
stopifnot(identical(p8_a, p8_b))
stopifnot(identical(p8_a, p8_c))

stopifnot(identical(p_a, p8_a[, 1:7]))
stopifnot(identical(p_a, p8_b[, 1:7]))
stopifnot(identical(p_a, p8_c[, 1:7]))

################################################################################
#                                 End of File                                  #
################################################################################
