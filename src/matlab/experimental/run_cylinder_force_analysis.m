function results = run_cylinder_force_analysis()
%RUN_CYLINDER_FORCE_ANALYSIS Analyse mean forces, uncertainty, and lift spectrum.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataDir = fullfile(rootDir, 'data', 'raw', 'cylinder_forces');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');

density = 998;
diameter = 0.06;
span = 0.185;
channelWidth = 0.5;
waterDepth = 0.45;
flowRate = 75e-3;
samplingFrequency = 200;
bulkVelocity = flowRate / (channelWidth * waterDepth);
dynamicPressure = 0.5 * density * bulkVelocity^2;

stillWater = load(fullfile(dataDir, 'FORCEdata_stillwater.mat'));
flow = load(fullfile(dataDir, 'FORCEdata_flow.mat'));
buoyancy = mean(stillWater.Fy(:));
drag = flow.Fx(:);
lift = flow.Fy(:) - buoyancy;
dragCoefficient = drag / (dynamicPressure * diameter * span);
liftCoefficient = lift / (dynamicPressure * diameter * span);
meanCD = mean(dragCoefficient);
meanCL = mean(liftCoefficient);

[frequency, amplitude] = fft_one_sided(lift, samplingFrequency);
amplitude(1) = 0;
[~, peakIndex] = max(amplitude);
sheddingFrequency = frequency(peakIndex);
strouhal = sheddingFrequency * diameter / bulkVelocity;

uForceX = 0.045;
uForceY = 0.025;
uDepth = 1e-3;
uDiameter = 0.05e-3;
uWidth = 1e-3;
uSpan = 1e-3;
meterPipeDiameter = 0.200;
meterArea = pi * meterPipeDiameter^2 / 4;
uFlowRate = hypot(0.005 * flowRate, meterArea * 1e-3);
uBulkVelocity = bulkVelocity * sqrt((uFlowRate / flowRate)^2 + ...
    (uWidth / channelWidth)^2 + (uDepth / waterDepth)^2);
uMeanDrag = uForceX;
uMeanLift = hypot(uForceY, uForceY);
uCDContributions = [uMeanDrag / (dynamicPressure * diameter * span), ...
    abs(2 * meanCD / bulkVelocity) * uBulkVelocity, ...
    abs(meanCD / diameter) * uDiameter, abs(meanCD / span) * uSpan];
uCLContributions = [uMeanLift / (dynamicPressure * diameter * span), ...
    abs(2 * meanCL / bulkVelocity) * uBulkVelocity, ...
    abs(meanCL / diameter) * uDiameter, abs(meanCL / span) * uSpan];
uCD = norm(uCDContributions);
uCL = norm(uCLContributions);

levelDifference = 2e-3;
endplateArea = 2 * (180e-3) * (2e-3);
buoyancyMismatch = density * 9.81 * endplateArea * levelDifference;
liftCoefficientLevelError = buoyancyMismatch / (dynamicPressure * diameter * span);

results = table(bulkVelocity, mean(drag), mean(lift), meanCD, meanCL, uCD, uCL, ...
    sheddingFrequency, strouhal, liftCoefficientLevelError, ...
    'VariableNames', {'BulkVelocity_mps', 'MeanDrag_N', 'MeanLift_N', ...
    'MeanCD', 'MeanCL', 'StandardUncertaintyCD', 'StandardUncertaintyCL', ...
    'SheddingFrequency_Hz', 'StrouhalNumber', 'LevelMismatchErrorCL'});
writetable(results, fullfile(tableDir, 'cylinder_force_summary.csv'));

time = (0:numel(drag)-1).' / samplingFrequency;
figure('Color', 'w', 'Position', [100 100 960 560]);
tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(time, drag, 'Color', [0.10 0.32 0.52], 'LineWidth', 0.8); hold on;
yline(mean(drag), '--', 'Color', [0.80 0.25 0.18], 'LineWidth', 1.2);
grid on; box on; ylabel('Drag [N]'); title('Force measurements in flowing water');
nexttile;
plot(time, lift, 'Color', [0.10 0.32 0.52], 'LineWidth', 0.8); hold on;
yline(mean(lift), '--', 'Color', [0.80 0.25 0.18], 'LineWidth', 1.2);
grid on; box on; xlabel('Time [s]'); ylabel('Lift corrected for buoyancy [N]');
exportgraphics(gcf, fullfile(figureDir, 'cylinder_forces.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'cylinder_forces.png'), 'Resolution', 300);
close(gcf);

figure('Color', 'w', 'Position', [100 100 860 500]);
plot(frequency, amplitude, 'Color', [0.10 0.32 0.52], 'LineWidth', 1.0); hold on;
xline(sheddingFrequency, '--', 'Color', [0.80 0.25 0.18], 'LineWidth', 1.2);
xlim([0, min(20, samplingFrequency / 2)]); grid on; box on;
xlabel('Frequency [Hz]'); ylabel('One-sided amplitude [N]');
title(sprintf('Lift spectrum: f_s = %.3f Hz, St = %.3f', sheddingFrequency, strouhal));
exportgraphics(gcf, fullfile(figureDir, 'cylinder_lift_spectrum.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'cylinder_lift_spectrum.png'), 'Resolution', 300);
close(gcf);

figure('Color', 'w', 'Position', [100 100 920 500]);
bar(100 * [uCDContributions.^2 / uCD^2; uCLContributions.^2 / uCL^2].');
set(gca, 'XTickLabel', {'Force', 'Velocity', 'Diameter', 'Span'});
ylabel('Contribution to variance [%]'); grid on; box on;
legend('C_D', 'C_L', 'Location', 'best');
title('Uncertainty-budget contributions');
exportgraphics(gcf, fullfile(figureDir, 'cylinder_force_uncertainty.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'cylinder_force_uncertainty.png'), 'Resolution', 300);
close(gcf);

fprintf('Cylinder forces: CD = %.4f +/- %.4f, CL = %.4f +/- %.4f, St = %.4f.\n', ...
    meanCD, uCD, meanCL, uCL, strouhal);

end
