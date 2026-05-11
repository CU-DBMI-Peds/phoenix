import numpy as np
import pandas as pd
import phoenix as phx
from importlib.resources import files

sepsis = pd.read_csv(files("phoenix") / "data" / "sepsis.csv")

sepsis

#help("phoenix")
#help("phoenix8")
#help("phx.phoenix_respiratory")
#help("help")

# examples

print("Respiratory")
resp = phx.phoenix_respiratory(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = np.where(sepsis["spo2"] <= 97, sepsis["spo2"] / sepsis["fio2"], np.nan),
    invasive_mechanical_ventilation = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy()
)

print(type(resp))
print(resp)

print("Cardiovascular Score")
card = phx.phoenix_cardiovascular(
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    mean_arterial_pressure = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3
)
print(type(card))
print(card)

print("Coagulation Score")
coag = phx.phoenix_coagulation(
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen']
)
print(type(coag))
print(coag)

print("Neurologic Score")
neuro = phx.phoenix_neurologic(
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int)
)
print(type(neuro))
print(neuro)


print("Phoenix Sepsis Score")
phoenix = phx.phoenix(
    pf_ratio = sepsis["pao2"] / sepsis["fio2"],
    sf_ratio = sepsis["spo2"] / sepsis["fio2"],
    invasive_mechanical_ventilation = sepsis["vent"],
    other_respiratory_support = (sepsis["fio2"] > 0.21).astype(int).to_numpy(),
    vasoactives = sepsis["dobutamine"] + sepsis["dopamine"] + sepsis["epinephrine"] + sepsis["milrinone"] + sepsis["norepinephrine"] + sepsis["vasopressin"],
    lactate = sepsis["lactate"],
    age = sepsis["age"],
    mean_arterial_pressure = sepsis["dbp"] + (sepsis["sbp"] - sepsis["dbp"]) / 3,
    platelets = sepsis['platelets'],
    inr = sepsis['inr'],
    d_dimer = sepsis['d_dimer'],
    fibrinogen = sepsis['fibrinogen'],
    gcs = sepsis["gcs_total"],
    fixed_pupils = (sepsis["pupil"] == "both-fixed").astype(int),
    )

print(type(phoenix))
print(phoenix)
