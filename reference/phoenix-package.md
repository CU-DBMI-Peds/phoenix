# phoenix: Phoenix and Phoenix-8 Sepsis Criteria

Implementation of the Phoenix and Phoenix-8 Sepsis Criteria as described
in "Development and Validation of the Phoenix Criteria for Pediatric
Sepsis and Septic Shock" by Sanchez-Pinto, Bennett, DeWitt, Russell et
al. (2024)
[doi:10.1001/jama.2024.0196](https://doi.org/10.1001/jama.2024.0196) and
"International Consensus Criteria for Pediatric Sepsis and Septic Shock"
by Schlapbach, Watson, Sorce, et al. (2024)
[doi:10.1001/jama.2024.0179](https://doi.org/10.1001/jama.2024.0179) .

## How To Cite

When using this R package in your research please cite the Phoenix
criteria and the package. You can get details more information via

`citation('phoenix')`

You can get bibtex entries for all the citations via

`print(citation('phoenix'), bibtex = TRUE)`

And you can get the up-to-date version and year information for the
phoenix package via

`print(citation('phoenix', auto = TRUE))` and
`print(citation('phoenix', auto = TRUE), bibtex = TRUE)`.

## References

There are two major publications to reference with respect to the
development of the Phoenix criteria.

- L. Nelson Sanchez-Pinto, MD, MBI\*; Tellen D. Bennett, MD, MS\*;
  Peter E. DeWitt, PhD\*\*; Seth Russell, MS\*\*; Margaret N. Rebull,
  MA; Blake Martin, MD; Samuel Akech, MBChB, MMED; David J. Albers, PhD;
  Elizabeth R. Alpern, MD, MSCE; Fran Balamuth, MD, PhD, MSCE; Melania
  Bembea, MD, MPH, PhD; Mohammod Jobayer Chisti, MBBS, MMed, PhD; Idris
  Evans, MD, MSc; Christopher M. Horvat, MD, MHA; Juan Camilo
  Jaramillo-Bustamante, MD; Niranjan Kissoon, MD; Kusum Menon, MD, MSc;
  Halden F. Scott, MD, MSCS; Scott L. Weiss, MD; Matthew O. Wiens,
  PharmD, PhD; Jerry J. Zimmerman, MD, PhD; Andrew C. Argent, MD, MBBCh,
  MMed\*\*\*; Lauren R. Sorce, PhD, RN, CPNP-AC/PC\*\*\*; Luregn J.
  Schlapbach, MD, PhD\*\*\*; R. Scott Watson, MD, MPH\*\*\*; and the
  Society of Critical Care Medicine Pediatric Sepsis Definition Task
  Force **Development and Validation of the Phoenix Criteria for
  Pediatric Sepsis and Septic Shock.** JAMA. 2024;331(8):675–686.
  Published online January 21, 2024.
  [doi:10.1001/jama.2024.0196](https://doi.org/10.1001/jama.2024.0196)

  \*Drs Sanchez-Pinto and Bennett contributed equally. \*\*Dr DeWitt and
  Mr Russell contributed equally. \*\*\*Drs Argent, Sorce, Schlapbach,
  and Watson contributed equally.

- Luregn J. Schlapbach, MD, PhD; R. Scott Watson, MD, MPH; Lauren R.
  Sorce, PhD, RN; Andrew C. Argent, MD, MBBCh, MMed; Kusum Menon, MD,
  MSc; Mark W. Hall, MD; Samuel Akech, MBChB, MMED, PhD; David J.
  Albers, PhD; Elizabeth R. Alpern, MD, MSCE; Fran Balamuth, MD, PhD,
  MSCE; Melania Bembea, MD, PhD; Paolo Biban, MD; Enitan D. Carrol,
  MBChB, MD; Kathleen Chiotos, MD; Mohammod Jobayer Chisti, MBBS, MMed,
  PhD; Peter E. DeWitt, PhD; Idris Evans, MD, MSc; Cláudio Flauzino de
  Oliveira, MD, PhD; Christopher M. Horvat, MD, MHA; David Inwald, MB,
  PhD; Paul Ishimine, MD; Juan Camilo Jaramillo-Bustamante, MD; Michael
  Levin, MD, PhD; Rakesh Lodha, MD; Blake Martin, MD; Simon Nadel, MBBS;
  Satoshi Nakagawa, MD; Mark J. Peters, PhD; Adrienne G. Randolph, MD,
  MS; Suchitra Ranjit, MD; Margaret N. Rebull, MA; Seth Russell, MS;
  Halden F. Scott, MD; Daniela Carla de Souza, MD, PhD; Pierre
  Tissieres, MD, DSc; Scott L. Weiss, MD, MSCE; Matthew O. Wiens,
  PharmD, PhD; James L. Wynn, MD; Niranjan Kissoon, MD; Jerry J.
  Zimmerman, MD, PhD; L. Nelson Sanchez-Pinto, MD; Tellen D. Bennett,
  MD, MS; for the Society of Critical Care Medicine Pediatric Sepsis
  Definition Task Force **International Consensus Criteria for Pediatric
  Sepsis and Septic Shock.** JAMA. 2024;331(8):665–674.
  [doi:10.1001/jama.2024.0179](https://doi.org/10.1001/jama.2024.0179)

  \*Drs Schlapbach, Watson, Sorce, and Argent contributed equally.
  \*\*Drs Sanchez-Pinto and Bennett contributed equally.

## See also

- [`phoenix`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix.md)
  for generating the diagnostic Phoenix Sepsis score based on the four
  organ systems:

  - [`phoenix_cardiovascular`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_cardiovascular.md),

  - [`phoenix_coagulation`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_coagulation.md),

  - [`phoenix_neurologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_neurologic.md),

  - [`phoenix_respiratory`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_respiratory.md),

- [`phoenix8`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix8.md)
  for generating the diagnostic Phoenix 8 Sepsis criteria based on the
  four organ systems noted above and

  - [`phoenix_endocrine`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_endocrine.md),

  - [`phoenix_immunologic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_immunologic.md),

  - [`phoenix_renal`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_renal.md),

  - [`phoenix_hepatic`](https://cu-dbmi-peds.github.io/phoenix/reference/phoenix_hepatic.md),

[`vignette('phoenix')`](https://cu-dbmi-peds.github.io/phoenix/articles/phoenix.md)
for more details and examples.

## Author

**Maintainer**: Peter DeWitt <peter.dewitt@cuanschutz.edu>
([ORCID](https://orcid.org/0000-0002-6391-0795)) \[cover designer\]

Other contributors:

- Seth Russell <seth.russell@cuanschutz.edu>
  ([ORCID](https://orcid.org/0000-0002-2436-1367)) \[contributor\]

- Meg Rebull <meg.rebull@cuanschutz.edu>
  ([ORCID](https://orcid.org/0000-0003-0334-4223)) \[contributor\]

- Tell Bennett <tell.bennett@cuanschutz.edu>
  ([ORCID](https://orcid.org/0000-0003-1483-4236)) \[contributor\]

- L. Nelson Sanchez-Pinto <lsanchezpinto@luriechildrens.org>
  ([ORCID](https://orcid.org/0000-0002-7434-6747)) \[contributor\]

- Vincent Rubinetti <vincent.rubinetti@cuanschutz.edu>
  ([ORCID](https://orcid.org/0000-0002-4655-3773)) \[cover designer\]
