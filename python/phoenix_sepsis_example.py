import numpy as np
import pandas as pd
import phoenix as phx

# examples
sepsis = pd.read_csv("sepsis.csv")
sepsis

print("Respiratory")
resp = phx.phoenix_respiratory(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy()
)

print(type(resp))
print(resp)

print("Cardiovascular")
card = phx.phoenix_cardiovascular(
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3
)
print(type(card))
print(card)

print("Coagulation")
coag = phx.phoenix_coagulation(
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen']
)
print(type(coag))
print(coag)

print("Neurologic")
neuro = phx.phoenix_neurologic(
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int)
)
print(type(neuro))
print(neuro)


print("Phoenix")
phoenix = phx.phoenix(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = sepsis["spo2"] / sepsis["fio2"],
    imv      = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy(),
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    map = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3,
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen'],
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int),
    )

print(type(phoenix))
print(phoenix)
