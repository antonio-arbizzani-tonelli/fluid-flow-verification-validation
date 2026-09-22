# Verification and validation of canonical fluid flows

This repository develops a reproducible verification and validation workflow for canonical internal and external flows. The numerical work covers mesh sensitivity, flow development, analytical verification, wall scaling, and RANS-model validation in circular pipes. The experimental work covers load-cell calibration, particle-shadow velocimetry, force coefficients, spectral identification, and first-order uncertainty propagation for a circular-cylinder wake.

## Scope

The repository contains only material required to reproduce the analyses and the report:

- PHOENICS case configurations and compact MATLAB exports;
- MATLAB routines for post-processing and figure generation;
- selected raw experimental acquisitions;
- generated figures, numerical tables, a LaTeX technical report, and a presentation draft.

The PHOENICS executable, licences, solver dump files, course handouts, recordings, and exam material are intentionally excluded.

## Main results

| Analysis | Result |
|---|---:|
| Laminar profile verification | relative \(L_\infty\) error \(=3.18\%\) |
| Laminar pressure gradient | relative error \(=1.24\%\) |
| Load-cell calibration | \(R^2 = 0.999999\), force RMSE \(= 0.00572\) N |
| Turbulent-pipe Reynolds number | \(Re_b = 75{,}000\) |
| Standard \(k\)-\(\varepsilon\) friction-factor error | \(0.082\%\) relative to the reference value |
| Cylinder drag coefficient | \(\overline{C_D} = 1.4987\) |
| PSV Strouhal number | \(St = 0.2041\) |
| Force-based Strouhal number | \(St = 0.1811\) |

## Reproduction

MATLAB R2024b or a compatible release is required. From the repository root, run:

```matlab
run('scripts/run_all.m')
```

The command regenerates all figures in `results/figures/` and all CSV tables in `results/tables/`. The workflow contains seven analysis modules and requires no absolute paths.

Compile the report from `docs/report/` with:

```text
pdflatex -jobname=fluid_flow_validation_report -output-directory ../../output/pdf main.tex
```

Run the command twice to resolve the table of contents and cross-references. The checked 25-page report and presentation draft are available in `output/pdf/` and `output/pptx/`.

## Repository map

```text
config/             PHOENICS case files used for the selected simulations
data/               Selected raw, processed, and external reference data
src/matlab/         Reproducible MATLAB post-processing routines
results/            Versioned figures and numerical tables
docs/report/        LaTeX technical report
docs/slides/        Presentation outline and detailed slide specification
scripts/            Entry points for the analysis workflow
tests/              Numerical utility tests
```

## Data note

The external turbulent-pipe velocity profiles remain attributed to their original source. Before making the repository public, confirm that redistribution of course-provided experimental data is permitted. If redistribution is not permitted, remove `data/external/` and provide a citation and instructions for obtaining the data instead.
