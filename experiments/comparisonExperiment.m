clc;
clear;
close all;

% ============================================================
% DCT vs ADAPTIVE DCT COMPARISON EXPERIMENT
% ============================================================

% Move to project root if this script is inside experiments
projectPath = fileparts(fileparts(mfilename('fullpath')));

% Add source folder
addpath(fullfile(projectPath, 'src'));

% Input image
imagePath = fullfile(projectPath, ...
    'test_images', 'peppers.png');

% Compression quality
quality = 50;

% ============================================================
% RUN STANDARD DCT COMPRESSION
% ============================================================

fprintf('\nRunning Standard DCT Compression...\n');

[standardImage, standardMetrics] = ...
    frequencyCompression(imagePath, quality);

% ============================================================
% RUN ADAPTIVE DCT COMPRESSION
% ============================================================

fprintf('Running Adaptive DCT Compression...\n');

[adaptiveImage, adaptiveMetrics] = ...
    adaptiveCompression(imagePath, quality);

% ============================================================
% READ ORIGINAL IMAGE
% ============================================================

original = imread(imagePath);

% ============================================================
% DISPLAY IMAGE COMPARISON
% ============================================================

figure('Name', ...
    'Standard DCT vs Adaptive DCT', ...
    'NumberTitle', 'off');

subplot(1,3,1);

image(original);
axis image off;

title('Original Image', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');


subplot(1,3,2);

image(standardImage);
axis image off;

title('Standard DCT', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');


subplot(1,3,3);

image(adaptiveImage);
axis image off;

title('Adaptive DCT', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

% ============================================================
% DISPLAY METRICS
% ============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('        STANDARD DCT vs ADAPTIVE DCT COMPARISON\n');
fprintf('============================================================\n');

fprintf('\nSTANDARD DCT\n');
fprintf('------------------------------------------------------------\n');

fprintf('MSE                    : %.4f\n', ...
    standardMetrics.MSE);

fprintf('PSNR                   : %.2f dB\n', ...
    standardMetrics.PSNR);

fprintf('Similarity             : %.4f\n', ...
    standardMetrics.SSIM);

fprintf('Coefficient Retention  : %.2f %%\n', ...
    standardMetrics.CoefficientRetention);


fprintf('\nADAPTIVE DCT\n');
fprintf('------------------------------------------------------------\n');

fprintf('MSE                    : %.4f\n', ...
    adaptiveMetrics.MSE);

fprintf('PSNR                   : %.2f dB\n', ...
    adaptiveMetrics.PSNR);

fprintf('Similarity             : %.4f\n', ...
    adaptiveMetrics.SSIM);

fprintf('Coefficient Retention  : %.2f %%\n', ...
    adaptiveMetrics.CoefficientRetention);

fprintf('High Detail Blocks     : %d\n', ...
    adaptiveMetrics.HighDetailBlocks);

fprintf('Medium Detail Blocks   : %d\n', ...
    adaptiveMetrics.MediumDetailBlocks);

fprintf('Low Detail Blocks      : %d\n', ...
    adaptiveMetrics.LowDetailBlocks);


% ============================================================
% CALCULATE IMPROVEMENT
% ============================================================

psnrImprovement = ...
    adaptiveMetrics.PSNR - standardMetrics.PSNR;

mseChange = ...
    standardMetrics.MSE - adaptiveMetrics.MSE;

coefficientChange = ...
    standardMetrics.CoefficientRetention - ...
    adaptiveMetrics.CoefficientRetention;

fprintf('\n');
fprintf('============================================================\n');
fprintf('                  PERFORMANCE CHANGE\n');
fprintf('============================================================\n');

fprintf('PSNR Improvement       : %.2f dB\n', ...
    psnrImprovement);

fprintf('MSE Reduction          : %.4f\n', ...
    mseChange);

fprintf('Coefficient Difference : %.2f %%\n', ...
    coefficientChange);

fprintf('============================================================\n');

% ============================================================
% CREATE COMPARISON BAR CHART
% ============================================================

figure('Name', ...
    'Compression Performance Comparison', ...
    'NumberTitle', 'off');

% PSNR comparison
subplot(1,2,1);

bar([standardMetrics.PSNR adaptiveMetrics.PSNR]);

set(gca, ...
    'XTickLabel', {'Standard DCT', 'Adaptive DCT'});

ylabel('PSNR (dB)');

title('PSNR Comparison');

grid on;


% Coefficient retention comparison
subplot(1,2,2);

bar([standardMetrics.CoefficientRetention ...
     adaptiveMetrics.CoefficientRetention]);

set(gca, ...
    'XTickLabel', {'Standard DCT', 'Adaptive DCT'});

ylabel('Coefficient Retention (%)');

title('Compression Comparison');

grid on;

% ============================================================
% SAVE RESULTS
% ============================================================

resultsFolder = fullfile(projectPath, 'results');

if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end

save(fullfile(resultsFolder, ...
    'comparisonResults.mat'), ...
    'standardMetrics', ...
    'adaptiveMetrics', ...
    'quality');

fprintf('\nComparison results saved to:\n');
fprintf('%s\n', resultsFolder);

fprintf('\nExperiment completed successfully!\n');