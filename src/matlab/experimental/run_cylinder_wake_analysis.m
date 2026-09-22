function results = run_cylinder_wake_analysis()
%RUN_CYLINDER_WAKE_ANALYSIS Process PSV fields and estimate shedding frequency.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataFile = fullfile(rootDir, 'data', 'raw', 'cylinder_wake', 'PSVdata.mat');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');
data = load(dataFile);

channelWidth = 0.5;
waterDepth = 0.42;
cylinderDiameter = 0.06;
flowRate = 35e-3;
density = 998;
dynamicViscosity = 1e-3;
spatialResolution = 3040;
samplingFrequency = 50;
originXPixel = 463;
originYPixel = 286;

bulkVelocity = flowRate / (channelWidth * waterDepth);
kinematicViscosity = dynamicViscosity / density;
reynoldsNumber = cylinderDiameter * bulkVelocity / kinematicViscosity;

xOverD = (originXPixel - data.Grid_Xpx) / spatialResolution / cylinderDiameter;
yOverD = (originYPixel - data.Grid_Ypx) / spatialResolution / cylinderDiameter;
uOverUb = (-data.SXpx / spatialResolution * samplingFrequency) / bulkVelocity;
vOverUb = (-data.SYpx / spatialResolution * samplingFrequency) / bulkVelocity;

cylinderCentreX = -0.5;
cylinderCentreY = 0;
cylinderRadius = 0.5;
cylinderMask = (xOverD - cylinderCentreX).^2 + ...
    (yOverD - cylinderCentreY).^2 <= cylinderRadius^2;

meanU = mean(uOverUb, 3, 'omitnan');
meanV = mean(vOverUb, 3, 'omitnan');
meanU(cylinderMask) = NaN;
meanV(cylinderMask) = NaN;
meanSpeed = hypot(meanU, meanV);

figure('Color', 'w', 'Position', [80 80 980 620]);
contourf(xOverD, yOverD, meanSpeed, 24, 'LineColor', 'none'); hold on;
step = 2;
quiver(xOverD(1:step:end, 1:step:end), yOverD(1:step:end, 1:step:end), ...
    meanU(1:step:end, 1:step:end), meanV(1:step:end, 1:step:end), ...
    1.3, 'k', 'LineWidth', 0.7);
rectangle('Position', [-1 -0.5 1 1], 'Curvature', [1 1], ...
    'FaceColor', [1 1 1], 'EdgeColor', 'k', 'LineWidth', 1.2);
axis equal tight; colorbar; xlabel('x/D'); ylabel('y/D');
title('Reynolds-averaged velocity magnitude and vectors');
exportgraphics(gcf, fullfile(figureDir, 'wake_mean_velocity_field.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'wake_mean_velocity_field.png'), 'Resolution', 300);
close(gcf);

targetX = [0, 0.5, 1.5, 2.5];
figure('Color', 'w', 'Position', [100 100 860 540]); hold on;
for index = 1:numel(targetX)
    columnDistance = mean(abs(xOverD - targetX(index)), 1, 'omitnan');
    [~, columnIndex] = min(columnDistance);
    plot(meanU(:, columnIndex), yOverD(:, columnIndex), 'LineWidth', 1.3, ...
        'DisplayName', sprintf('x/D = %.1f', targetX(index)));
end
grid on; box on; xlabel('U/U_b'); ylabel('y/D');
legend('Location', 'best'); title('Streamwise-velocity recovery in the wake');
exportgraphics(gcf, fullfile(figureDir, 'wake_velocity_profiles.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'wake_velocity_profiles.png'), 'Resolution', 300);
close(gcf);

requestedProbeX = 0.25;
requestedProbeY = 0;
distanceToProbe = (xOverD - requestedProbeX).^2 + (yOverD - requestedProbeY).^2;
distanceToProbe(cylinderMask) = Inf;
[~, linearProbeIndex] = min(distanceToProbe(:));
[probeRow, probeColumn] = ind2sub(size(xOverD), linearProbeIndex);
probeX = xOverD(probeRow, probeColumn);
probeY = yOverD(probeRow, probeColumn);
probeSignal = squeeze(vOverUb(probeRow, probeColumn, :));
time = (0:numel(probeSignal)-1).' / samplingFrequency;
valid = isfinite(probeSignal);
probeSignal = interp1(time(valid), probeSignal(valid), time, 'linear', 'extrap');

[frequency, amplitude] = fft_one_sided(probeSignal, samplingFrequency);
amplitude(1) = 0;
frequencyBand = frequency >= 0.2 & frequency <= 10;
bandIndices = find(frequencyBand);
[~, localPeakIndex] = max(amplitude(frequencyBand));
peakIndex = bandIndices(localPeakIndex);
sheddingFrequency = frequency(peakIndex);
strouhal = sheddingFrequency * cylinderDiameter / bulkVelocity;

figure('Color', 'w', 'Position', [80 80 1050 650]);
tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(time, probeSignal, 'Color', [0.10 0.32 0.52], 'LineWidth', 0.8);
grid on; box on; xlabel('Time [s]'); ylabel('v/U_b');
title(sprintf('Wake probe at x/D = %.2f, y/D = %.2f', probeX, probeY));
nexttile;
plot(frequency, amplitude, 'Color', [0.10 0.32 0.52], 'LineWidth', 1.0); hold on;
xline(sheddingFrequency, '--', 'Color', [0.80 0.25 0.18], 'LineWidth', 1.2);
xlim([0 10]); grid on; box on; xlabel('Frequency [Hz]'); ylabel('One-sided amplitude');
title(sprintf('Dominant frequency %.3f Hz, St = %.3f', sheddingFrequency, strouhal));
exportgraphics(gcf, fullfile(figureDir, 'wake_probe_spectrum.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'wake_probe_spectrum.png'), 'Resolution', 300);
close(gcf);

periodSamples = max(4, round(samplingFrequency / sheddingFrequency));
filterWindow = max(3, round(0.2 * periodSamples));
filteredU = movmean(uOverUb, filterWindow, 3, 'omitnan');
filteredV = movmean(vOverUb, filterWindow, 3, 'omitnan');
startIndex = min(200, size(filteredU, 3) - periodSamples);
phaseIndices = startIndex + round((0:3) * periodSamples / 4);
dx = abs(mean(diff(xOverD(1,:)), 'omitnan'));
dy = abs(mean(diff(yOverD(:,1)), 'omitnan'));

figure('Color', 'w', 'Position', [80 80 1120 760]);
tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for phase = 1:4
    uSnapshot = filteredU(:,:,phaseIndices(phase));
    vSnapshot = filteredV(:,:,phaseIndices(phase));
    [~, duDy] = gradient(uSnapshot, dx, dy);
    [dvDx, ~] = gradient(vSnapshot, dx, dy);
    vorticity = dvDx - duDy;
    vorticity(cylinderMask) = NaN;
    nexttile;
    contourf(xOverD, yOverD, vorticity, 24, 'LineColor', 'none'); hold on;
    rectangle('Position', [-1 -0.5 1 1], 'Curvature', [1 1], ...
        'FaceColor', [1 1 1], 'EdgeColor', 'k');
    axis equal tight; colorbar; xlabel('x/D'); ylabel('y/D');
    title(sprintf('Phase %.0f degrees', (phase-1) * 90));
end
sgtitle('Dimensionless vorticity over one shedding period');
exportgraphics(gcf, fullfile(figureDir, 'wake_vorticity_phases.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'wake_vorticity_phases.png'), 'Resolution', 300);
close(gcf);

results = table(bulkVelocity, reynoldsNumber, probeX, probeY, sheddingFrequency, strouhal, ...
    'VariableNames', {'BulkVelocity_mps', 'ReynoldsNumber', 'ProbeX_over_D', ...
    'ProbeY_over_D', 'SheddingFrequency_Hz', 'StrouhalNumber'});
writetable(results, fullfile(tableDir, 'cylinder_wake_summary.csv'));
save(fullfile(rootDir, 'data', 'processed', 'cylinder_wake_summary.mat'), ...
    'xOverD', 'yOverD', 'meanU', 'meanV', 'meanSpeed', 'cylinderMask', ...
    'probeSignal', 'frequency', 'amplitude', 'results');

fprintf('PSV wake: Re_D = %.0f, probe frequency = %.4f Hz, St = %.4f.\n', ...
    reynoldsNumber, sheddingFrequency, strouhal);

end
