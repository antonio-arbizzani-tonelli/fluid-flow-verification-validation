function results = run_grid_independence_studies()
%RUN_GRID_INDEPENDENCE_STUDIES Compare the selected CFD mesh refinements.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataRoot = fullfile(rootDir, 'data', 'processed', 'cfd', 'grid_studies');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');

flowNames = ["Laminar", "Turbulent"];
bulkVelocity = [0.45, 0.75];
rowFlow = strings(0,1);
rowDirection = strings(0,1);
rowPair = strings(0,1);
rowError = zeros(0,1);

for flowIndex = 1:numel(flowNames)
    flowName = lower(flowNames(flowIndex));
    flowDir = fullfile(dataRoot, flowName);
    yFiles = {'y_10.mat', 'y_25.mat', 'y_50.mat'};
    zFiles = {'z_100.mat', 'z_150.mat', 'z_200.mat'};
    yzFiles = {'yz_10_100.mat', 'yz_15_150.mat', 'yz_25_250.mat'};
    yLabels = {'10 cells', '25 cells', '50 cells'};
    zLabels = {'100 cells', '150 cells', '200 cells'};
    yzLabels = {'10 x 100', '15 x 150', '25 x 250'};

    yCases = cellfun(@(name) load(fullfile(flowDir, name)), yFiles, 'UniformOutput', false);
    zCases = cellfun(@(name) load(fullfile(flowDir, name)), zFiles, 'UniformOutput', false);
    yzCases = cellfun(@(name) load(fullfile(flowDir, name)), yzFiles, 'UniformOutput', false);

    [etaY, velocityY] = radialProfiles(yCases, bulkVelocity(flowIndex));
    [zCoordinates, pressureZ] = axialPressure(zCases);
    [etaYZ, velocityYZ] = radialProfiles(yzCases, bulkVelocity(flowIndex));

    figure('Color', 'w', 'Position', [80 80 1420 440]);
    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    nexttile; hold on;
    for index = 1:3
        plot(etaY{index}, velocityY{index}, 'LineWidth', 1.2);
    end
    grid on; box on; xlabel('r/R'); ylabel('W/W_b');
    title('Radial refinement'); legend(yLabels, 'Location', 'best');

    nexttile; hold on;
    for index = 1:3
        plot(zCoordinates{index}, pressureZ{index}, 'LineWidth', 1.2);
    end
    grid on; box on; xlabel('z [m]'); ylabel('Section-mean pressure [Pa]');
    title('Axial refinement'); legend(zLabels, 'Location', 'best');

    nexttile; hold on;
    for index = 1:3
        plot(etaYZ{index}, velocityYZ{index}, 'LineWidth', 1.2);
    end
    grid on; box on; xlabel('r/R'); ylabel('W/W_b');
    title('Combined refinement'); legend(yzLabels, 'Location', 'best');
    sgtitle(sprintf('%s pipe flow: grid-independence assessment', flowNames(flowIndex)));

    outputBase = sprintf('%s_grid_independence', flowName);
    exportgraphics(gcf, fullfile(figureDir, outputBase + ".pdf"), 'ContentType', 'vector');
    exportgraphics(gcf, fullfile(figureDir, outputBase + ".png"), 'Resolution', 300);
    close(gcf);

    yErrors = consecutiveProfileErrors(etaY, velocityY);
    zErrors = consecutiveProfileErrors(zCoordinates, pressureZ);
    yzErrors = consecutiveProfileErrors(etaYZ, velocityYZ);
    directions = ["Radial", "Radial", "Axial", "Axial", "Combined", "Combined"];
    pairs = ["coarse-medium", "medium-fine", "coarse-medium", ...
        "medium-fine", "coarse-medium", "medium-fine"];
    errors = [yErrors(:); zErrors(:); yzErrors(:)];
    rowFlow = [rowFlow; repmat(flowNames(flowIndex), 6, 1)]; %#ok<AGROW>
    rowDirection = [rowDirection; directions(:)]; %#ok<AGROW>
    rowPair = [rowPair; pairs(:)]; %#ok<AGROW>
    rowError = [rowError; errors]; %#ok<AGROW>
end

results = table(rowFlow, rowDirection, rowPair, 100 * rowError, ...
    'VariableNames', {'FlowRegime', 'Refinement', 'GridPair', 'RelativeLinfError_percent'});
writetable(results, fullfile(tableDir, 'grid_independence_metrics.csv'));

fprintf('Grid-independence metrics [relative L-infinity error, %%]:\n');
disp(results);

end

function [coordinates, profiles] = radialProfiles(cases, bulkVelocity)
coordinates = cell(size(cases));
profiles = cell(size(cases));
for index = 1:numel(cases)
    data = cases{index};
    velocity = squeeze(data.W1);
    radialCoordinate = data.Y_C(:);
    axialCoordinate = data.Z_C(:);
    targetZ = 0.8 * max(axialCoordinate);
    [~, sectionIndex] = min(abs(axialCoordinate - targetZ));
    coordinates{index} = radialCoordinate / max(radialCoordinate);
    profiles{index} = velocity(:, sectionIndex) / bulkVelocity;
end
end

function [coordinates, profiles] = axialPressure(cases)
coordinates = cell(size(cases));
profiles = cell(size(cases));
for index = 1:numel(cases)
    data = cases{index};
    pressure = squeeze(data.P1);
    radialCoordinate = data.Y_C(:);
    axialCoordinate = data.Z_C(:);
    targetRadius = 0.5 * max(radialCoordinate);
    [~, radialIndex] = min(abs(radialCoordinate - targetRadius));
    coordinates{index} = axialCoordinate;
    profiles{index} = pressure(radialIndex, :).';
end
end

function errors = consecutiveProfileErrors(coordinates, profiles)
errors = zeros(2, 1);
for index = 1:2
    referenceCoordinate = coordinates{index + 1};
    referenceProfile = profiles{index + 1};
    comparison = interp1(coordinates{index}, profiles{index}, referenceCoordinate, 'linear', 'extrap');
    scale = max(abs(referenceProfile));
    errors(index) = max(abs(comparison - referenceProfile)) / max(scale, eps);
end
end
