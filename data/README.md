# Data inventory

`raw/load_cell/` contains the 16 calibration acquisitions used to estimate the force-voltage transfer function.

`raw/cylinder_forces/` contains still-water and flowing-water force signals for the circular cylinder.

`raw/cylinder_wake/` contains the PSV acquisition used to regenerate the mean field, wake profiles, probe spectrum, and vorticity sequence.

`processed/cfd/` contains MATLAB exports of selected PHOENICS solutions, including the retained laminar and turbulent cases and the radial, axial, and combined grid-refinement sequences. They enable post-processing without publishing proprietary solver dumps.

`external/` contains the velocity profiles used in the turbulent-pipe validation. Confirm redistribution rights before publishing the repository.
