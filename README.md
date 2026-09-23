# Verification and validation of canonical fluid flows

This repository collects a numerical study of laminar and turbulent pipe flow and an experimental study of a circular-cylinder wake. The workflow links CFD verification and validation with calibration, velocity-field analysis, force measurements and uncertainty estimates. Additional sensitivity checks assess the low-Reynolds-number solution and the spatial support for the PSV shedding frequency.

## Project files

- `src/matlab/` contains the CFD and experimental post-processing routines.
- `scripts/run_all.m` runs the complete MATLAB workflow.
- `config/cfd/` contains the PHOENICS case configurations.
- `data/` contains selected CFD exports and experimental measurements used by the scripts.
- `results/tables/` contains numerical summaries in CSV and LaTeX formats.
- [Complete technical report (PDF)](docs/report/technical_report.pdf).
- `docs/report/` contains the report's LaTeX source and chapter files.
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
| Low-Reynolds-number closure | Radial profile changes are non-monotonic; grid independence is not established |
| Cylinder drag coefficient | Mean C_D = 1.499 |
| Wake Strouhal numbers | 0.204 from PSV; 0.181 from force measurements |
| PSV spatial spectral check | 59 of 690 grid points meet the 95% data-availability criterion; median St = 0.204 |
| Calibration leave-one-out check | Fitted sensitivity changes by less than 0.04% when one load is omitted |

The two Strouhal estimates come from different operating conditions and are not repeated measurements of the same point. The spatial PSV values are limited by the finite-record frequency resolution; isolated higher bins are not interpreted as a spatial gradient.

## Reproduce the analyses

MATLAB R2024b or a compatible release is required. From the repository root, run:

```matlab
run('scripts/run_all.m')
```

The scripts regenerate the figures and numerical tables from the included data. Figure exports (PDF and PNG) are local build products and are excluded from the repository. The complete report PDF is included so it can be read without MATLAB.

To rebuild the report, first run the MATLAB workflow above so it recreates the figure PDFs under `results/figures/`. Then create `build/report/` at the repository root and run `pdflatex` twice from `docs/report/`:

```text
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../../build/report main.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../../build/report main.tex
```

The regenerated PDF will be `build/report/main.pdf`; copy it to `docs/report/technical_report.pdf` to update the published report. Compilation requires a LaTeX distribution with the packages listed in `docs/report/main.tex`. See [`docs/report/README.md`](docs/report/README.md) for the full procedure.

## Data and software

PHOENICS itself, its license, solver dump files, course handouts, recordings and exam material are not included. The MATLAB files and case configurations use the MIT License. Dataset provenance and organization are described in [`data/README.md`](data/README.md); the external reference data retain their attribution.
