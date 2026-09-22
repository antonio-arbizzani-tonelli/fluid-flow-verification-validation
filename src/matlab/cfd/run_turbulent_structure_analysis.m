function results = run_turbulent_structure_analysis()
%RUN_TURBULENT_STRUCTURE_ANALYSIS Extract wall-scaled and turbulence profiles.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataFile = fullfile(rootDir, 'data', 'processed', 'cfd', 'turbulent_pipe', 'standard_ke.mat');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');
data = load(dataFile);

diameter = 0.10;
radius = diameter / 2;
bulkVelocity = 0.75;
kinematicViscosity = 1.0e-6;
reynoldsNumber = bulkVelocity * diameter / kinematicViscosity;
analyticalEntryLength = 1.359 * diameter * reynoldsNumber^(1/4);

velocity = squeeze(data.W1);
pressure = squeeze(data.P1);
eddyViscosity = squeeze(data.ENUT);
turbulentKineticEnergy = squeeze(data.KE);
dissipationRate = squeeze(data.EP);
wallStressByDensity = squeeze(data.STRS);
radialCoordinate = data.Y_C(:);
axialCoordinate = data.Z_C(:);

referenceProfile = velocity(:, end-1);
profileError = max(abs(velocity(:, 1:end-1) - referenceProfile), [], 1) / max(abs(referenceProfile));
fullyDevelopedIndex = find(profileError <= 1e-3, 1, 'first');
if isempty(fullyDevelopedIndex)
    fullyDevelopedIndex = numel(axialCoordinate) - 1;
end
numericalEntryLength = axialCoordinate(fullyDevelopedIndex);
sectionIndex = numel(axialCoordinate) - 1;

frictionVelocity = sqrt(wallStressByDensity(end, sectionIndex));
wallDistance = radius - radialCoordinate;
yPlus = wallDistance * frictionVelocity / kinematicViscosity;
wPlus = velocity(:, sectionIndex) / frictionVelocity;
validWallCoordinates = yPlus > 0;
yPlusPlot = yPlus(validWallCoordinates);
wPlusPlot = wPlus(validWallCoordinates);
[yPlusPlot, order] = sort(yPlusPlot);
wPlusPlot = wPlusPlot(order);

figure('Color', 'w', 'Position', [80 80 1350 850]);
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(radialCoordinate / radius, velocity(:, sectionIndex) / bulkVelocity, 'LineWidth', 1.3);
grid on; box on; xlabel('r/R'); ylabel('W/W_b'); title('Mean axial velocity');
nexttile;
semilogy(radialCoordinate / radius, max(eddyViscosity(:, sectionIndex) / kinematicViscosity, eps), ...
    'LineWidth', 1.3);
grid on; box on; xlabel('r/R'); ylabel('\nu_t/\nu'); title('Eddy-viscosity ratio');
nexttile;
plot(radialCoordinate / radius, turbulentKineticEnergy(:, sectionIndex), 'LineWidth', 1.3);
grid on; box on; xlabel('r/R'); ylabel('k [m^2/s^2]'); title('Turbulent kinetic energy');
nexttile;
plot(radialCoordinate / radius, dissipationRate(:, sectionIndex), 'LineWidth', 1.3);
grid on; box on; xlabel('r/R'); ylabel('\epsilon [m^2/s^3]'); title('Dissipation rate');
sgtitle('Turbulent structure in the fully developed region');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_structure_profiles.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_structure_profiles.png'), 'Resolution', 300);
close(gcf);

figure('Color', 'w', 'Position', [100 100 850 540]);
loglog(yPlusPlot, wPlusPlot, 'o-', 'MarkerSize', 4, 'LineWidth', 1.2); hold on;
viscousY = logspace(-1, 1, 100);
logY = logspace(log10(30), log10(max(max(yPlusPlot), 31)), 100);
loglog(viscousY, viscousY, '--', 'LineWidth', 1.1);
loglog(logY, log(logY) / 0.41 + 5.2, '--', 'LineWidth', 1.1);
grid on; box on; xlabel('y^+'); ylabel('W^+');
legend('CFD', 'W^+=y^+', 'Log law', 'Location', 'best');
title('Wall-scaled axial velocity');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_wall_scaling.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_wall_scaling.png'), 'Resolution', 300);
close(gcf);

figure('Color', 'w', 'Position', [100 100 900 520]);
tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(axialCoordinate, velocity(1, :) / bulkVelocity, 'LineWidth', 1.3); hold on;
xline(analyticalEntryLength, '--', 'Correlation');
xline(numericalEntryLength, ':', '0.1% criterion');
grid on; box on; xlabel('z [m]'); ylabel('W_c/W_b'); title('Centreline development');
nexttile;
plot(axialCoordinate, pressure(round(end/2), :), 'LineWidth', 1.3);
grid on; box on; xlabel('z [m]'); ylabel('Pressure [Pa]'); title('Axial pressure decrease');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_flow_development.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_flow_development.png'), 'Resolution', 300);
close(gcf);

results = table(reynoldsNumber, analyticalEntryLength, numericalEntryLength, ...
    frictionVelocity, max(yPlusPlot), ...
    'VariableNames', {'ReynoldsNumber', 'CorrelationEntryLength_m', ...
    'NumericalDevelopedLocation_m', 'FrictionVelocity_mps', 'MaximumYPlus'});
writetable(results, fullfile(tableDir, 'turbulent_structure_summary.csv'));

fprintf('Turbulent flow: Re = %.0f, correlated entry length %.3f m, numerical developed location %.3f m.\n', ...
    reynoldsNumber, analyticalEntryLength, numericalEntryLength);
fprintf('Friction velocity %.5f m/s; maximum y+ %.2f.\n', frictionVelocity, max(yPlusPlot));

end
