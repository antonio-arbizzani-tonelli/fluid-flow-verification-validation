# Technical report

`technical_report.pdf` is the compiled report. `main.tex` and `chapters/` are the editable source.

## Rebuild

From the repository root, run `scripts/run_all.m` in MATLAB to regenerate the numerical tables and figure files. Then create `build/report/` and, from this directory, run `pdflatex` twice:

```text
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../../build/report main.tex
pdflatex -interaction=nonstopmode -halt-on-error -output-directory=../../build/report main.tex
```

Copy `build/report/main.pdf` to `docs/report/technical_report.pdf` to update the published copy. The generated figure files in `results/figures/` are local build products and are not tracked by Git.
