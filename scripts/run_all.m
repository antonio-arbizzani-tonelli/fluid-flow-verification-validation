%RUN_ALL Regenerate tables and figures used by the report.

clearvars;
close all;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(repoRoot, 'src', 'matlab')));

run_grid_independence_studies();
run_low_re_sensitivity_analysis();
run_laminar_development_analysis();
run_pipe_validation();
run_turbulent_structure_analysis();

run_load_cell_calibration();
run_cylinder_wake_analysis();
run_cylinder_force_analysis();
