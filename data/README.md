# Data inventory

The repository contains selected inputs and processed exports required by the MATLAB analyses.

- `raw/load_cell/` contains 16 calibration acquisitions used to estimate the force-voltage transfer function.
- `raw/cylinder_forces/` contains still-water and flowing-water force signals for the cylinder experiment.
- `raw/cylinder_wake/` contains the PSV measurement used for the mean wake, velocity profiles, spectrum and vorticity analysis.
- `processed/cfd/` contains selected MATLAB exports of PHOENICS solutions, including laminar and turbulent cases and grid-refinement sequences.
- `processed/cylinder_wake_summary.mat` contains summary quantities shared by the wake and force analyses.
- `external/` contains the attributed velocity profiles used to compare turbulent-pipe simulations with measurements.

PHOENICS solver dumps and software are not included. The files in `external/` retain their source attribution; the MIT License applies to repository code and does not replace the terms attached to third-party data.
