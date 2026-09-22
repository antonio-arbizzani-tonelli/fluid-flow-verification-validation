function results = run_laminar_development_analysis()
%RUN_LAMINAR_DEVELOPMENT_ANALYSIS Characterise pipe-flow development and pressure loss.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataFile = fullfile(rootDir, 'data', 'processed', 'cfd', 'laminar_pipe', 'base_case.mat');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');
data = load(dataFile);

density = 910;                 % kg/m^3
kinematicViscosity = 3.5e-4;   % m^2/s
dynamicViscosity = density * kinematicViscosity;
diameter = 0.15;               % m
bulkVelocity = 0.45;           % m/s
reynoldsNumber = bulkVelocity * diameter / kinematicViscosity;
analyticalEntryLength = 0.0575 * reynoldsNumber * diameter;

velocity = squeeze(data.W1);
pressure = squeeze(data.P1);
radialCoordinate = data.Y_C(:);
axialCoordinate = data.Z_C(:);
referenceProfile = velocity(:, end-1);
profileError = max(abs(velocity(:, 1:end-1) - referenceProfile), [], 1) / max(abs(referenceProfile));
fullyDevelopedIndex = find(profileError <= 1e-3, 1, 'first');
if isempty(fullyDevelopedIndex)
    fullyDevelopedIndex = numel(axialCoordinate) - 1;
end
numericalEntryLength = axialCoordinate(fullyDevelopedIndex);

radius = max(radialCoordinate);
sectionMeanPressure = zeros(size(axialCoordinate));
for section = 1:numel(axialCoordinate)
    sectionMeanPressure(section) = 2 / radius^2 * trapz(radialCoordinate, ...
        pressure(:, section) .* radialCoordinate);
end
fitIndices = max(1, numel(axialCoordinate)-11):numel(axialCoordinate)-1;
pressureFit = polyfit(axialCoordinate(fitIndices), sectionMeanPressure(fitIndices), 1);
numericalPressureGradient = pressureFit(1);
analyticalPressureGradient = -32 * dynamicViscosity * bulkVelocity / diameter^2;
pressureGradientError = abs(numericalPressureGradient - analyticalPressureGradient) / ...
    abs(analyticalPressureGradient);

centerlineVelocity = velocity(1, :);
figure('Color', 'w', 'Position', [80 80 1050 720]);
tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(axialCoordinate, centerlineVelocity / bulkVelocity, 'LineWidth', 1.3); hold on;
xline(analyticalEntryLength, '--', 'Analytical L_e', 'LineWidth', 1.1);
xline(numericalEntryLength, ':', '0.1% criterion', 'LineWidth', 1.3);
yline(2, '--k', 'Fully developed limit');
grid on; box on; ylabel('W_c/W_b'); title('Development of the centreline velocity');
nexttile;
semilogy(axialCoordinate(1:end-1), max(profileError, eps), 'LineWidth', 1.3); hold on;
yline(1e-3, '--', '0.1% threshold');
xline(numericalEntryLength, ':', 'Selected location', 'LineWidth', 1.3);
grid on; box on; xlabel('z [m]'); ylabel('Relative profile difference');
title('Distance from the fully developed profile');
exportgraphics(gcf, fullfile(figureDir, 'laminar_flow_development.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'laminar_flow_development.png'), 'Resolution', 300);
close(gcf);

figure('Color', 'w', 'Position', [100 100 860 500]);
plot(axialCoordinate, sectionMeanPressure, 'Color', [0.10 0.32 0.52], 'LineWidth', 1.2); hold on;
plot(axialCoordinate(fitIndices), polyval(pressureFit, axialCoordinate(fitIndices)), '--', ...
    'Color', [0.80 0.25 0.18], 'LineWidth', 1.6);
grid on; box on; xlabel('z [m]'); ylabel('Area-weighted section pressure [Pa]');
legend('CFD', 'Linear fit in the developed region', 'Location', 'best');
title('Laminar pressure decrease along the pipe');
exportgraphics(gcf, fullfile(figureDir, 'laminar_pressure_gradient.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'laminar_pressure_gradient.png'), 'Resolution', 300);
close(gcf);

results = table(reynoldsNumber, analyticalEntryLength, numericalEntryLength, ...
    analyticalPressureGradient, numericalPressureGradient, 100 * pressureGradientError, ...
    'VariableNames', {'ReynoldsNumber', 'AnalyticalEntryLength_m', ...
    'NumericalEntryLength_m', 'AnalyticalPressureGradient_Pa_per_m', ...
    'NumericalPressureGradient_Pa_per_m', 'PressureGradientError_percent'});
writetable(results, fullfile(tableDir, 'laminar_development_summary.csv'));

fprintf('Laminar flow: Re = %.1f, L_e = %.4f m, numerical developed location = %.4f m.\n', ...
    reynoldsNumber, analyticalEntryLength, numericalEntryLength);
fprintf('Pressure gradients: analytical %.4f Pa/m, CFD %.4f Pa/m, error %.3f%%.\n', ...
    analyticalPressureGradient, numericalPressureGradient, 100 * pressureGradientError);

end
