function results = run_load_cell_calibration()
%RUN_LOAD_CELL_CALIBRATION Estimate transfer function, stability, and residual error.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataDir = fullfile(rootDir, 'data', 'raw', 'load_cell');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');

referenceForce = [0; -0.314; -0.411; -0.695; -0.891; -1.186; -1.676; ...
    -2.656; -5.598; -10.501; 0.126; 1.097; 2.078; 4.039; 8.942; 13.845];
samplingFrequency = 100;
testCount = numel(referenceForce);
steadyVoltage = zeros(testCount, 1);
stabilisationTime = zeros(testCount, 1);
voltageRecords = cell(testCount, 1);

for testId = 1:testCount
    acquisition = load(fullfile(dataDir, sprintf('calibr%02d.mat', testId)));
    voltage = acquisition.V(:);
    voltageRecords{testId} = voltage;
    firstSteadySample = max(1, ceil(0.70 * numel(voltage)));
    steadyVoltage(testId) = mean(voltage(firstSteadySample:end));

    cumulativeMean = cumsum(voltage) ./ (1:numel(voltage)).';
    voltageRange = max(voltage) - min(voltage);
    normalisationScale = max(abs(steadyVoltage(testId)), 0.05 * voltageRange);
    stableMask = abs(cumulativeMean - steadyVoltage(testId)) <= 0.02 * normalisationScale;
    stableFrom = flip(cumprod(flip(stableMask)));
    firstStableIndex = find(stableFrom, 1, 'first');
    if isempty(firstStableIndex)
        firstStableIndex = numel(voltage);
    end
    stabilisationTime(testId) = (firstStableIndex - 1) / samplingFrequency;
end

fitCoefficients = polyfit(referenceForce, steadyVoltage, 1);
estimatedVoltage = polyval(fitCoefficients, referenceForce);
residualVoltage = steadyVoltage - estimatedVoltage;
coefficientOfDetermination = 1 - sum(residualVoltage.^2) / ...
    sum((steadyVoltage - mean(steadyVoltage)).^2);
estimatedForce = (steadyVoltage - fitCoefficients(2)) / fitCoefficients(1);
forceResidual = estimatedForce - referenceForce;
forceRMSE = sqrt(mean(forceResidual.^2));
maximumAbsoluteError = max(abs(forceResidual));
expandedResidualEstimate = 2 * sqrt(sum(forceResidual.^2) / (testCount - 2));

results = table(referenceForce, steadyVoltage, estimatedForce, forceResidual, stabilisationTime, ...
    'VariableNames', {'ReferenceForce_N', 'SteadyVoltage_V', 'EstimatedForce_N', ...
    'ForceResidual_N', 'StabilisationTime_s'});
writetable(results, fullfile(tableDir, 'load_cell_calibration.csv'));

figure('Color', 'w', 'Position', [100 100 860 560]);
plot(referenceForce, steadyVoltage, 'o', 'MarkerSize', 6, ...
    'MarkerFaceColor', [0.10 0.32 0.52], 'MarkerEdgeColor', 'none'); hold on;
forceFit = linspace(min(referenceForce), max(referenceForce), 200);
plot(forceFit, polyval(fitCoefficients, forceFit), '-', ...
    'Color', [0.80 0.25 0.18], 'LineWidth', 1.8);
grid on; box on; xlabel('Reference force [N]'); ylabel('Steady voltage [V]');
legend('Measurements', 'Linear fit', 'Location', 'northwest');
title(sprintf('Load-cell calibration: R^2 = %.6f', coefficientOfDetermination));
exportgraphics(gcf, fullfile(figureDir, 'load_cell_calibration.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'load_cell_calibration.png'), 'Resolution', 300);
close(gcf);

selectedTests = [2, 8, 10, 16];
figure('Color', 'w', 'Position', [80 80 1100 700]);
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for plotIndex = 1:numel(selectedTests)
    testId = selectedTests(plotIndex);
    voltage = voltageRecords{testId};
    time = (0:numel(voltage)-1).' / samplingFrequency;
    cumulativeMean = cumsum(voltage) ./ (1:numel(voltage)).';
    nexttile;
    semilogx(time(2:end), cumulativeMean(2:end), 'LineWidth', 1.2); hold on;
    yline(steadyVoltage(testId), '--', 'Steady estimate');
    xline(max(stabilisationTime(testId), 1/samplingFrequency), ':', 'Stabilisation');
    grid on; box on; xlabel('Time [s]'); ylabel('Cumulative voltage [V]');
    title(sprintf('Test %d, F^* = %.3f N', testId, referenceForce(testId)));
end
sgtitle('Convergence of the cumulative voltage estimate');
exportgraphics(gcf, fullfile(figureDir, 'load_cell_stability.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'load_cell_stability.png'), 'Resolution', 300);
close(gcf);

figure('Color', 'w', 'Position', [100 100 860 500]);
stem(referenceForce, forceResidual, 'filled', 'Color', [0.10 0.32 0.52]); hold on;
yline(maximumAbsoluteError, '--', 'Color', [0.80 0.25 0.18]);
yline(-maximumAbsoluteError, '--', 'Color', [0.80 0.25 0.18]);
grid on; box on; xlabel('Reference force [N]'); ylabel('Force residual [N]');
title('Calibration residuals in force units');
exportgraphics(gcf, fullfile(figureDir, 'load_cell_residuals.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'load_cell_residuals.png'), 'Resolution', 300);
close(gcf);

summary = table(fitCoefficients(1), fitCoefficients(2), coefficientOfDetermination, ...
    forceRMSE, maximumAbsoluteError, expandedResidualEstimate, max(stabilisationTime), ...
    'VariableNames', {'Sensitivity_V_per_N', 'Offset_V', 'R2', 'ForceRMSE_N', ...
    'MaximumAbsoluteError_N', 'ExpandedResidualEstimate_N', 'MaximumStabilisationTime_s'});
writetable(summary, fullfile(tableDir, 'load_cell_summary.csv'));

fprintf('Load-cell sensitivity: %.6e V/N.\n', fitCoefficients(1));
fprintf('R^2: %.6f; force RMSE: %.6f N; maximum error: %.6f N.\n', ...
    coefficientOfDetermination, forceRMSE, maximumAbsoluteError);

end
