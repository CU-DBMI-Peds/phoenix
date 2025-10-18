# __init__.py
"""
Phoenix Pediatric Sepsis and Septic Shock Criteria and Scoring

Methods:

    Organ Dysfunction Scoring: Eight organ systems, each function returns a
    numpy array.

        1. phoenix_respiratory
        2. phoenix_cardiovascular
        3. phoenix_coagulation
        4. phoenix_neurologic
        5. phoenix_endocrine
        6. phoenix_immunologic
        7. phoenix_renal
        8. phoenix_hepatic

    Phoenix Scoring: Two functions. Both return a pandas DataFrame.  phoenix
    returns a DataFrame with columns for the four component scores (respiratory,
    cardiovascular, coagulation, and neurologic), a total score (the sum of the
    components), an indicator column for sepsis (total score of at least two
    points), and an indicator column for septic shock (sepsis with at least one
    cardiovascular point).  phoenix8 returns the same as phoenix but with
    additional columns for the other four organ systems and a phoenix8 sepsis
    score.

        1. phoenix
        2. phoenix8

References:

    Sanchez-Pinto LN, Bennett TD, DeWitt PE, et al. Development and Validation
    of the Phoenix Criteria for Pediatric Sepsis and Septic Shock. JAMA.
    2024;331(8):675–686. doi:10.1001/jama.2024.0196

    Schlapbach LJ, Watson RS, Sorce LR, et al. International Consensus Criteria
    for Pediatric Sepsis and Septic Shock. JAMA. 2024;331(8):665–674.
    doi:10.1001/jama.2024.0179
"""

from .phoenix import *
