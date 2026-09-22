function results = run_pipe_validation()
%RUN_PIPE_VALIDATION Verify the laminar case and validate turbulent closures.

addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'common'));
rootDir = repo_root();
dataDir = fullfile(rootDir, 'data');
figureDir = fullfile(rootDir, 'results', 'figures');
tableDir = fullfile(rootDir, 'results', 'tables');

laminar = load(fullfile(dataDir, 'processed', 'cfd', 'laminar_pipe', 'base_case.mat'));
laminarVelocity = squeeze(laminar.W1);
radialCoordinate = laminar.Y_C(:);
profile = laminarVelocity(:, end-1);
radius = max(radialCoordinate);
bulkVelocityLaminar = trapz(radialCoordinate, profile .* radialCoordinate) * 2 / radius^2;
eta = radialCoordinate / radius;
poiseuille = 2 * (1 - eta.^2);
laminarRelativeLinfError = max(abs(profile / bulkVelocityLaminar - poiseuille)) / max(abs(poiseuille));

figure('Color', 'w', 'Position', [100 100 820 520]);
plot(eta, profile / bulkVelocityLaminar, 'o-', 'Color', [0.10 0.32 0.52], ...
    'MarkerSize', 4, 'LineWidth', 1.0); hold on;
plot(eta, poiseuille, '--', 'Color', [0.80 0.25 0.18], 'LineWidth', 1.5);
grid on; box on; xlabel('r/R'); ylabel('w/W_b');
legend('CFD', 'Poiseuille solution', 'Location', 'best');
title('Laminar pipe flow: fully developed velocity profile');
exportgraphics(gcf, fullfile(figureDir, 'laminar_pipe_verification.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'laminar_pipe_verification.png'), 'Resolution', 300);
close(gcf);

modelFiles = {'standard_ke.mat', 'rng_ke.mat', 'realisable_ke.mat', fullfile('low_re', 'base_case.mat')};
modelNames = {'Standard k-e', 'RNG k-e', 'Realisable k-e', 'Low-Re k-e'};
lineColors = [0.10 0.32 0.52; 0.80 0.25 0.18; 0.22 0.55 0.32; 0.20 0.20 0.20];
diameter = 0.10;
bulkVelocity = 0.75;
kinematicViscosity = 1.0e-6;
frictionFactor = zeros(numel(modelFiles), 1);
velocityProfileRMSE = zeros(numel(modelFiles), 1);

experimental = load(fullfile(dataDir, 'external', 'torbergsen_velocity_profiles.mat'));
figure('Color', 'w', 'Position', [100 100 820 520]); hold on;
for index = 1:numel(modelFiles)
    simulation = load(fullfile(dataDir, 'processed', 'cfd', 'turbulent_pipe', modelFiles{index}));
    velocity = squeeze(simulation.W1);
    radialCoordinate = simulation.Y_C(:);
    numericalRadius = radialCoordinate / (diameter / 2);
    numericalProfile = velocity(:, end-1) / bulkVelocity;
    plot(numericalRadius, numericalProfile, '-', 'Color', lineColors(index, :), ...
        'LineWidth', 1.4, 'DisplayName', modelNames{index});
    wallStressByDensity = squeeze(simulation.STRS);
    frictionFactor(index) = 8 * wallStressByDensity(end, end-1) / bulkVelocity^2;
    errorSeries1 = profileRMSE(numericalRadius, numericalProfile, experimental.W_profile_series1);
    errorSeries2 = profileRMSE(numericalRadius, numericalProfile, experimental.W_profile_series2);
    velocityProfileRMSE(index) = mean([errorSeries1, errorSeries2]);
end
plot(experimental.W_profile_series1(:,1), experimental.W_profile_series1(:,2), 'ko', ...
    'MarkerSize', 5, 'DisplayName', 'Experimental series 1');
plot(experimental.W_profile_series2(:,1), experimental.W_profile_series2(:,2), 'ks', ...
    'MarkerSize', 5, 'DisplayName', 'Experimental series 2');
grid on; box on; xlabel('r/R'); ylabel('W/W_b');
title('Turbulent pipe flow: model comparison against experimental profiles');
legend('Location', 'best');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_pipe_validation.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_pipe_validation.png'), 'Resolution', 300);
close(gcf);

experimentalFrictionFactor = 0.0190;
reynoldsNumber = bulkVelocity * diameter / kinematicViscosity;
prandtlEquation = @(factor) 1 / sqrt(factor) + ...
    2 * log10(2.51 / (reynoldsNumber * sqrt(factor)));
prandtlFrictionFactor = fzero(prandtlEquation, 0.02);
haalandFrictionFactor = (-1.8 * log10(6.9 / reynoldsNumber))^(-2);

results = table(modelNames.', frictionFactor, ...
    100 * abs(frictionFactor - experimentalFrictionFactor) / experimentalFrictionFactor, ...
    velocityProfileRMSE, ...
    'VariableNames', {'TurbulenceModel', 'FrictionFactor', 'RelativeError_percent', ...
    'VelocityProfileRMSE'});
writetable(results, fullfile(tableDir, 'turbulent_pipe_models.csv'));

figure('Color', 'w', 'Position', [100 100 980 520]);
comparisonValues = [frictionFactor; experimentalFrictionFactor; ...
    prandtlFrictionFactor; haalandFrictionFactor];
bar(comparisonValues, 'FaceColor', [0.18 0.43 0.62]);
set(gca, 'XTick', 1:numel(comparisonValues), 'XTickLabel', ...
    [modelNames, {'Experiment', 'Prandtl', 'Haaland'}], 'XTickLabelRotation', 25);
ylabel('Darcy friction factor'); grid on; box on;
title('Turbulent-pipe friction-factor validation');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_friction_factor_comparison.pdf'), 'ContentType', 'vector');
exportgraphics(gcf, fullfile(figureDir, 'turbulent_friction_factor_comparison.png'), 'Resolution', 300);
close(gcf);

summary = table(bulkVelocityLaminar, 100 * laminarRelativeLinfError, reynoldsNumber, ...
    experimentalFrictionFactor, prandtlFrictionFactor, haalandFrictionFactor, ...
    'VariableNames', {'LaminarBulkVelocity_mps', 'LaminarProfileLinfError_percent', ...
    'TurbulentReynoldsNumber', 'ExperimentalFrictionFactor', ...
    'PrandtlFrictionFactor', 'HaalandFrictionFactor'});
writetable(summary, fullfile(tableDir, 'cfd_validation_summary.csv'));

fprintf('Laminar profile relative L-infinity error: %.3f%%.\n', 100 * laminarRelativeLinfError);
fprintf('Turbulent-pipe Re_b: %.0f.\n', reynoldsNumber);
disp(results);

end

function errorValue = profileRMSE(numericalRadius, numericalProfile, experimentalProfile)
[numericalRadius, uniqueIndices] = unique(numericalRadius);
numericalProfile = numericalProfile(uniqueIndices);
interpolated = interp1(numericalRadius, numericalProfile, experimentalProfile(:,1), ...
    'linear', NaN);
valid = isfinite(interpolated) & isfinite(experimentalProfile(:,2));
errorValue = sqrt(mean((interpolated(valid) - experimentalProfile(valid,2)).^2));
end
