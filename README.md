# Verification and validation of canonical fluid flows

This repository collects a numerical study of laminar and turbulent pipe flow and an experimental study of a circular-cylinder wake. The workflow links CFD verification and validation with calibration, velocity-field analysis, force measurements and uncertainty estimates.

## Project files

- `src/matlab/` contains the CFD and experimental post-processing routines.
- `scripts/run_all.m` runs the complete MATLAB workflow.
- `config/cfd/` contains the PHOENICS case configurations.
- `data/` contains selected CFD exports and experimental measurements used by the scripts.
- `results/tables/` contains numerical summaries in CSV and LaTeX formats.
- `results/figures/` contains the vector figures used by the technical report.
- `docs/report/` contains the LaTeX source and chapter files.
- `presentation/` contains the project deck in PowerPoint and PDF formats.
- `tests/` contains a test for the shared one-sided FFT utility.

## Presentation

- [PDF deck](presentation/fluid_flow_verification_validation.pdf)
- [Editable PowerPoint deck](presentation/fluid_flow_verification_validation.pptx)

## Main results

| Analysis | Result |
|---|---:|
| Laminar pipe velocity profile | Relative L-infinity error: 3.18% |
| Laminar pipe pressure gradient | Relative error: 1.24% |
| Load-cell calibration | R² = 0.999999; force RMSE: 5.72 mN |
| Turbulent pipe | Re_b = 75,000 |
| Standard k-epsilon friction factor | Relative error: 0.082% against the selected reference |
| Cylinder drag coefficient | Mean C_D = 1.499 |
| Wake Strouhal numbers | 0.204 from PSV; 0.181 from force measurements |

The two Strouhal estimates come from different operating conditions and are not repeated measurements of the same point.

## Reproduce the analyses

MATLAB R2024b or a compatible release is required. From the repository root, run:

```matlab
run('scripts/run_all.m')
```

The scripts regenerate the figures and numerical tables from the included data. PNG figure exports are useful for local inspection and are excluded from the repository; the vector PDF figures remain available for the LaTeX report.

To compile the report, create `build/report/` and run `pdflatex` twice from `docs/report/`:

```text
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../../build/report main.tex
```

The report source and its chapter files are in `docs/report/`. Compilation requires a LaTeX distribution with the packages listed in `main.tex`.

## Data and software

PHOENICS itself, its license, solver dump files, course handouts, recordings and exam material are not included. The MATLAB files and case configurations use the MIT License. Dataset provenance and organization are described in [`data/README.md`](data/README.md); the external reference data retain their attribution.
