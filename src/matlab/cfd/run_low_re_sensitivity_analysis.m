function [meshResults, iterationResults, stretchingResults] = run_low_re_sensitivity_analysis()
%RUN_LOW_RE_SENSITIVITY_ANALYSIS Assess low-Re mesh and solver sensitivity.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataRoot = fullfile(rootDir, 'data', 'processed', 'cfd');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');

meshFiles = {'ny_35.mat', 'ny_45.mat', 'ny_60.mat', 'ny_75.mat'};
meshLabels = {'N_y = 35', 'N_y = 45', 'N_y = 60', 'N_y = 75'};
meshCoordinates = cell(size(meshFiles));
meshProfiles = cell(size(meshFiles));
for index = 1:numel(meshFiles)
    meshCase = load(fullfile(dataRoot, 'low_re_grid', meshFiles{index}));
    [meshCoordinates{index}, meshProfiles{index}] = developedProfile(meshCase);
end

meshError = relativeProfileDifferences(meshCoordinates, meshProfiles);
meshResults = table([35; 45; 60; 75], [NaN; meshError], ...
    'VariableNames', {'RadialCells', 'RelativeLinfChange_percent'});
writetable(meshResults, fullfile(tableDir, 'low_re_grid_sensitivity.csv'));

figure('Color', 'w', 'Position', [100 100 900 560]); hold on;
for index = 1:numel(meshFiles)
    plot(meshCoordinates{index}, meshProfiles{index}, 'LineWidth', 1.3, ...
        'DisplayName', meshLabels{index});
end
grid on; box on; xlabel('r/R'); ylabel('W/W_b');
title('Low-Re pipe flow: radial-grid sensitivity');
legend('Location', 'best');
exportgraphics(gcf, fullfile(figureDir, 'low_re_grid_sensitivity.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'low_re_grid_sensitivity.png'), 'Resolution', 300);
close(gcf);

iterationCounts = [500, 750, 1000];
iterationFields = {'W1', 'P1', 'KE', 'EP', 'ENUT'};
iterationLabels = {'Axial velocity'; 'Pressure'; 'Turbulent kinetic energy'; ...
    'Dissipation rate'; 'Eddy viscosity'};
iterationChanges = zeros(numel(iterationFields), numel(iterationCounts)-1);
iterationCases = cell(size(iterationCounts));
for countIndex = 1:numel(iterationCounts)
    iterationCases{countIndex} = load(fullfile(dataRoot, 'turbulent_pipe', ...
        'low_re', sprintf('y_%d.mat', iterationCounts(countIndex))));
end
for fieldIndex = 1:numel(iterationFields)
    fieldName = iterationFields{fieldIndex};
    for countIndex = 1:numel(iterationCounts)-1
        coarse = iterationCases{countIndex}.(fieldName);
        fine = iterationCases{countIndex+1}.(fieldName);
        scale = max(abs(fine(:)), [], 'omitnan');
        iterationChanges(fieldIndex, countIndex) = ...
            100 * max(abs(coarse(:)-fine(:)), [], 'omitnan') / max(scale, eps);
    end
end
iterationResults = table(string(iterationLabels), iterationChanges(:,1), ...
    iterationChanges(:,2), 'VariableNames', ...
    {'Variable', 'Change_500_to_750_percent', 'Change_750_to_1000_percent'});
writetable(iterationResults, fullfile(tableDir, 'low_re_iteration_sensitivity.csv'));

figure('Color', 'w', 'Position', [100 100 920 540]);
bar(iterationChanges);
xticks(1:numel(iterationLabels)); xticklabels(iterationLabels); xtickangle(25);
grid on; box on; ylabel('Relative L_\infty change [%]');
legend({'500 to 750 iterations', '750 to 1000 iterations'}, 'Location', 'northwest');
title('Low-Re solution change across solver iterations');
exportgraphics(gcf, fullfile(figureDir, 'low_re_iteration_sensitivity.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'low_re_iteration_sensitivity.png'), 'Resolution', 300);
close(gcf);

stretchFiles = {'power_minus_1_5.mat', 'power_minus_1_8.mat', 'power_minus_2_0.mat'};
stretchLabels = {'p = -1.5', 'p = -1.8', 'p = -2.0'};
stretchCoordinates = cell(size(stretchFiles));
stretchProfiles = cell(size(stretchFiles));
for index = 1:numel(stretchFiles)
    stretchCase = load(fullfile(dataRoot, 'power_y_grid', stretchFiles{index}));
    [stretchCoordinates{index}, stretchProfiles{index}] = developedProfile(stretchCase);
end
stretchError = relativeProfileDifferences(stretchCoordinates, stretchProfiles);
stretchingResults = table([-1.5; -1.8; -2.0], [NaN; stretchError], ...
    'VariableNames', {'StretchingExponent', 'RelativeLinfChange_percent'});
writetable(stretchingResults, fullfile(tableDir, 'power_y_stretching_sensitivity.csv'));

figure('Color', 'w', 'Position', [100 100 900 560]); hold on;
for index = 1:numel(stretchFiles)
    plot(stretchCoordinates{index}, stretchProfiles{index}, 'LineWidth', 1.3, ...
        'DisplayName', stretchLabels{index});
end
grid on; box on; xlabel('r/R'); ylabel('W/W_b');
title('Low-Re pipe flow: radial-spacing sensitivity');
legend('Location', 'best');
exportgraphics(gcf, fullfile(figureDir, 'power_y_stretching_sensitivity.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'power_y_stretching_sensitivity.png'), 'Resolution', 300);
close(gcf);

fprintf('Low-Re radial-grid relative profile changes [%%]:\n');
disp(meshResults);
fprintf('Low-Re iteration relative L-infinity changes [%%]:\n');
disp(iterationResults);
fprintf('Power-law spacing relative profile changes [%%]:\n');
disp(stretchingResults);

end

function [coordinate, profile] = developedProfile(data)
velocity = squeeze(data.W1);
radialCoordinate = data.Y_C(:);
axialCoordinate = data.Z_C(:);
targetZ = 0.8 * max(axialCoordinate);
[~, sectionIndex] = min(abs(axialCoordinate-targetZ));
coordinate = radialCoordinate / max(radialCoordinate);
profile = velocity(:,sectionIndex) / 0.75;
end

function errors = relativeProfileDifferences(coordinates, profiles)
errors = zeros(numel(coordinates)-1, 1);
for index = 1:numel(errors)
    comparison = interp1(coordinates{index}, profiles{index}, ...
        coordinates{index+1}, 'linear', 'extrap');
    scale = max(abs(profiles{index+1}));
    errors(index) = 100 * max(abs(comparison-profiles{index+1})) / max(scale, eps);
end
end
