function experiments()

clc;
close all;

%% ============================================================
%       CONTENT-AWARE ADAPTIVE IMAGE COMPRESSION
%       COMPLETE PERFORMANCE EVALUATION
%
%       Standard DCT vs Adaptive DCT
%
%       Metrics:
%       - File Size
%       - Compression Ratio
%       - Space Saving
%       - MSE
%       - PSNR
%       - True SSIM
%
%       Quality Levels:
%       20, 30, 40, 50, 60, 70, 80
% ============================================================


%% ============================================================
% 1. PROJECT PATHS
% ============================================================

projectRoot = fileparts(fileparts(mfilename('fullpath')));

srcFolder = fullfile(projectRoot,'src');

imagePath = fullfile( ...
    projectRoot, ...
    'test_images', ...
    'peppers.png');

resultsFolder = fullfile( ...
    projectRoot, ...
    'results');

multiQualityFolder = fullfile( ...
    resultsFolder, ...
    'multi_quality');

addpath(srcFolder);

if ~isfolder(resultsFolder)
    mkdir(resultsFolder);
end

if ~isfolder(multiQualityFolder)
    mkdir(multiQualityFolder);
end


%% ============================================================
% 2. PARAMETERS
% ============================================================

qualityLevels = [20 30 40 50 60 70 80];

numQualities = length(qualityLevels);


%% ============================================================
% 3. LOAD ORIGINAL IMAGE
% ============================================================

originalImage = imread(imagePath);

if size(originalImage,3) ~= 3
    originalImage = repmat(originalImage,[1 1 3]);
end

originalDouble = double(originalImage);

imageInfo = dir(imagePath);

originalFileSizeKB = imageInfo.bytes / 1024;


%% ============================================================
% 4. DISPLAY EXPERIMENT INFORMATION
% ============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('       CONTENT-AWARE IMAGE COMPRESSION\n');
fprintf('       MULTI-QUALITY PERFORMANCE EVALUATION\n');
fprintf('============================================================\n');

fprintf('Image              : peppers.png\n');
fprintf('Original File Size : %.2f KB\n',originalFileSizeKB);

fprintf('Quality Levels     : ');

for i = 1:numQualities
    fprintf('%d ',qualityLevels(i));
end

fprintf('\n');

fprintf('============================================================\n');


%% ============================================================
% 5. PREALLOCATE RESULT ARRAYS
% ============================================================

standardSize = zeros(1,numQualities);
adaptiveSize = zeros(1,numQualities);

standardRatio = zeros(1,numQualities);
adaptiveRatio = zeros(1,numQualities);

standardSaving = zeros(1,numQualities);
adaptiveSaving = zeros(1,numQualities);

standardMSE = zeros(1,numQualities);
adaptiveMSE = zeros(1,numQualities);

standardPSNR = zeros(1,numQualities);
adaptivePSNR = zeros(1,numQualities);

standardSSIM = zeros(1,numQualities);
adaptiveSSIM = zeros(1,numQualities);

highBlocks = zeros(1,numQualities);
mediumBlocks = zeros(1,numQualities);
lowBlocks = zeros(1,numQualities);

totalBlocks = zeros(1,numQualities);


%% ============================================================
% 6. RUN EXPERIMENT FOR EACH QUALITY LEVEL
% ============================================================

for i = 1:numQualities

    quality = qualityLevels(i);

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('                  QUALITY LEVEL: %d\n',quality);
    fprintf('============================================================\n');


    %% ========================================================
    % STANDARD DCT COMPRESSION
    % =========================================================

    standardFile = fullfile( ...
        multiQualityFolder, ...
        sprintf('standard_quality_%d.mat',quality));

    fprintf('\nRunning Standard DCT Compression...\n');

    if ~isfile(standardFile)

        evalc('actualCompression(imagePath,quality,standardFile);');

    end

    [standardImage,standardMetrics] = ...
        decompressImage(standardFile);


    %% ========================================================
    % ADAPTIVE DCT COMPRESSION
    % =========================================================

    adaptiveFile = fullfile( ...
        multiQualityFolder, ...
        sprintf('adaptive_quality_%d.mat',quality));

    fprintf('Running Adaptive DCT Compression...\n');

    if ~isfile(adaptiveFile)

        evalc('actualAdaptiveCompression(imagePath,quality,adaptiveFile);');

    end

    [adaptiveImage,adaptiveMetrics] = ...
        decompressAdaptiveImage(adaptiveFile);


    %% ========================================================
    % FILE SIZE
    % =========================================================

    standardSize(i) = ...
        standardMetrics.CompressedFileSizeKB;

    adaptiveSize(i) = ...
        adaptiveMetrics.CompressedFileSizeKB;


    %% ========================================================
    % COMPRESSION RATIO
    % ========================================================

    standardRatio(i) = ...
        originalFileSizeKB / standardSize(i);

    adaptiveRatio(i) = ...
        originalFileSizeKB / adaptiveSize(i);


    %% ========================================================
    % SPACE SAVING
    % ========================================================

    standardSaving(i) = ...
        (1 - standardSize(i) / originalFileSizeKB) * 100;

    adaptiveSaving(i) = ...
        (1 - adaptiveSize(i) / originalFileSizeKB) * 100;


    %% ========================================================
    % MSE
    % ========================================================

    standardMSE(i) = ...
        standardMetrics.MSE;

    adaptiveMSE(i) = ...
        adaptiveMetrics.MSE;


    %% ========================================================
    % PSNR
    % ========================================================

    standardPSNR(i) = ...
        standardMetrics.PSNR;

    adaptivePSNR(i) = ...
        adaptiveMetrics.PSNR;


    %% ========================================================
    % TRUE SSIM
    % ========================================================

    standardSSIM(i) = ...
        calculateTrueSSIM(originalImage,standardImage);

    adaptiveSSIM(i) = ...
        calculateTrueSSIM(originalImage,adaptiveImage);


    %% ========================================================
    % ADAPTIVE BLOCK DISTRIBUTION
    % ========================================================

    highBlocks(i) = ...
        adaptiveMetrics.HighDetailBlocks;

    mediumBlocks(i) = ...
        adaptiveMetrics.MediumDetailBlocks;

    lowBlocks(i) = ...
        adaptiveMetrics.LowDetailBlocks;

    totalBlocks(i) = ...
        adaptiveMetrics.TotalBlocks;


    %% ========================================================
    % DISPLAY CURRENT RESULTS
    % ========================================================

    fprintf('\n');

    fprintf('STANDARD DCT\n');

    fprintf('File Size         : %.2f KB\n', ...
        standardSize(i));

    fprintf('Compression Ratio : %.2f : 1\n', ...
        standardRatio(i));

    fprintf('Space Saving      : %.2f %%\n', ...
        standardSaving(i));

    fprintf('MSE               : %.4f\n', ...
        standardMSE(i));

    fprintf('PSNR              : %.2f dB\n', ...
        standardPSNR(i));

    fprintf('True SSIM         : %.4f\n', ...
        standardSSIM(i));


    fprintf('\n');

    fprintf('ADAPTIVE DCT\n');

    fprintf('File Size         : %.2f KB\n', ...
        adaptiveSize(i));

    fprintf('Compression Ratio : %.2f : 1\n', ...
        adaptiveRatio(i));

    fprintf('Space Saving      : %.2f %%\n', ...
        adaptiveSaving(i));

    fprintf('MSE               : %.4f\n', ...
        adaptiveMSE(i));

    fprintf('PSNR              : %.2f dB\n', ...
        adaptivePSNR(i));

    fprintf('True SSIM         : %.4f\n', ...
        adaptiveSSIM(i));

    fprintf('\n');

    fprintf('Adaptive Blocks   : High=%d | Medium=%d | Low=%d\n', ...
        highBlocks(i), ...
        mediumBlocks(i), ...
        lowBlocks(i));

end


%% ============================================================
% 7. CALCULATE ADAPTIVE IMPROVEMENTS
% ============================================================

fileSizeReduction = ...
    standardSize - adaptiveSize;

compressionRatioGain = ...
    adaptiveRatio - standardRatio;

spaceSavingGain = ...
    adaptiveSaving - standardSaving;

psnrImprovement = ...
    adaptivePSNR - standardPSNR;

mseReduction = ...
    standardMSE - adaptiveMSE;

ssimImprovement = ...
    adaptiveSSIM - standardSSIM;


%% ============================================================
% 8. COMPLETE RESULTS TABLE
% ============================================================

fprintf('\n\n');

fprintf('============================================================\n');
fprintf('              COMPLETE PERFORMANCE RESULTS\n');
fprintf('============================================================\n');

fprintf('\n');

fprintf(['Quality   StdSize   AdaptSize   StdRatio   AdaptRatio   ' ...
         'StdPSNR   AdaptPSNR   StdSSIM   AdaptSSIM\n']);

fprintf(['-------   -------   ---------   --------   ----------   ' ...
         '-------   ---------   -------   ---------\n']);

for i = 1:numQualities

    fprintf(['%5d     %7.2f     %8.2f      %6.2f      %7.2f      ' ...
             '%6.2f      %7.2f      %6.4f      %7.4f\n'], ...
        qualityLevels(i), ...
        standardSize(i), ...
        adaptiveSize(i), ...
        standardRatio(i), ...
        adaptiveRatio(i), ...
        standardPSNR(i), ...
        adaptivePSNR(i), ...
        standardSSIM(i), ...
        adaptiveSSIM(i));

end


%% ============================================================
% 9. RATE-DISTORTION ANALYSIS
% ============================================================

figure( ...
    'Name','Rate-Distortion Analysis', ...
    'NumberTitle','off', ...
    'Position',[100 100 900 650]);

plot( ...
    standardSize, ...
    standardPSNR, ...
    '-o', ...
    'LineWidth',2);

hold on;

plot( ...
    adaptiveSize, ...
    adaptivePSNR, ...
    '-s', ...
    'LineWidth',2);

grid on;

xlabel('Compressed File Size (KB)');

ylabel('PSNR (dB)');

title('Rate-Distortion Performance');

legend( ...
    'Standard DCT', ...
    'Adaptive DCT', ...
    'Location','southeast');


rateDistortionPath = fullfile( ...
    resultsFolder, ...
    'rate_distortion_analysis.png');

exportgraphics( ...
    gcf, ...
    rateDistortionPath, ...
    'Resolution',150);


%% ============================================================
% 10. QUALITY VS PSNR
% ============================================================

figure( ...
    'Name','Quality vs PSNR', ...
    'NumberTitle','off', ...
    'Position',[120 120 900 650]);

plot( ...
    qualityLevels, ...
    standardPSNR, ...
    '-o', ...
    'LineWidth',2);

hold on;

plot( ...
    qualityLevels, ...
    adaptivePSNR, ...
    '-s', ...
    'LineWidth',2);

grid on;

xlabel('Compression Quality');

ylabel('PSNR (dB)');

title('Quality vs PSNR');

legend( ...
    'Standard DCT', ...
    'Adaptive DCT', ...
    'Location','southeast');


psnrGraphPath = fullfile( ...
    resultsFolder, ...
    'quality_vs_psnr.png');

exportgraphics( ...
    gcf, ...
    psnrGraphPath, ...
    'Resolution',150);


%% ============================================================
% 11. QUALITY VS TRUE SSIM
% ============================================================

figure( ...
    'Name','Quality vs True SSIM', ...
    'NumberTitle','off', ...
    'Position',[140 140 900 650]);

plot( ...
    qualityLevels, ...
    standardSSIM, ...
    '-o', ...
    'LineWidth',2);

hold on;

plot( ...
    qualityLevels, ...
    adaptiveSSIM, ...
    '-s', ...
    'LineWidth',2);

grid on;

xlabel('Compression Quality');

ylabel('SSIM');

title('Quality vs Structural Similarity');

legend( ...
    'Standard DCT', ...
    'Adaptive DCT', ...
    'Location','southeast');


ssimGraphPath = fullfile( ...
    resultsFolder, ...
    'quality_vs_ssim.png');

exportgraphics( ...
    gcf, ...
    ssimGraphPath, ...
    'Resolution',150);


%% ============================================================
% 12. QUALITY VS FILE SIZE
% ============================================================

figure( ...
    'Name','Quality vs File Size', ...
    'NumberTitle','off', ...
    'Position',[160 160 900 650]);

plot( ...
    qualityLevels, ...
    standardSize, ...
    '-o', ...
    'LineWidth',2);

hold on;

plot( ...
    qualityLevels, ...
    adaptiveSize, ...
    '-s', ...
    'LineWidth',2);

grid on;

xlabel('Compression Quality');

ylabel('Compressed File Size (KB)');

title('Quality vs Compressed File Size');

legend( ...
    'Standard DCT', ...
    'Adaptive DCT', ...
    'Location','northwest');


sizeGraphPath = fullfile( ...
    resultsFolder, ...
    'quality_vs_file_size.png');

exportgraphics( ...
    gcf, ...
    sizeGraphPath, ...
    'Resolution',150);


%% ============================================================
% 13. QUALITY VS COMPRESSION RATIO
% ============================================================

figure( ...
    'Name','Quality vs Compression Ratio', ...
    'NumberTitle','off', ...
    'Position',[180 180 900 650]);

plot( ...
    qualityLevels, ...
    standardRatio, ...
    '-o', ...
    'LineWidth',2);

hold on;

plot( ...
    qualityLevels, ...
    adaptiveRatio, ...
    '-s', ...
    'LineWidth',2);

grid on;

xlabel('Compression Quality');

ylabel('Compression Ratio');

title('Quality vs Compression Ratio');

legend( ...
    'Standard DCT', ...
    'Adaptive DCT', ...
    'Location','northeast');


ratioGraphPath = fullfile( ...
    resultsFolder, ...
    'quality_vs_compression_ratio.png');

exportgraphics( ...
    gcf, ...
    ratioGraphPath, ...
    'Resolution',150);


%% ============================================================
% 14. QUALITY VS MSE
% ============================================================

figure( ...
    'Name','Quality vs MSE', ...
    'NumberTitle','off', ...
    'Position',[200 200 900 650]);

plot( ...
    qualityLevels, ...
    standardMSE, ...
    '-o', ...
    'LineWidth',2);

hold on;

plot( ...
    qualityLevels, ...
    adaptiveMSE, ...
    '-s', ...
    'LineWidth',2);

grid on;

xlabel('Compression Quality');

ylabel('Mean Squared Error');

title('Quality vs MSE');

legend( ...
    'Standard DCT', ...
    'Adaptive DCT', ...
    'Location','northeast');


mseGraphPath = fullfile( ...
    resultsFolder, ...
    'quality_vs_mse.png');

exportgraphics( ...
    gcf, ...
    mseGraphPath, ...
    'Resolution',150);


%% ============================================================
% 15. ADAPTIVE BLOCK DISTRIBUTION
% ============================================================

figure( ...
    'Name','Adaptive Block Distribution', ...
    'NumberTitle','off', ...
    'Position',[220 220 900 650]);

bar( ...
    qualityLevels, ...
    [highBlocks' mediumBlocks' lowBlocks'], ...
    'stacked');

grid on;

xlabel('Compression Quality');

ylabel('Number of 8x8 Blocks');

title('Adaptive Block Classification');

legend( ...
    'High Detail', ...
    'Medium Detail', ...
    'Low Detail', ...
    'Location','northwest');


blockGraphPath = fullfile( ...
    resultsFolder, ...
    'adaptive_block_distribution.png');

exportgraphics( ...
    gcf, ...
    blockGraphPath, ...
    'Resolution',150);


%% ============================================================
% 16. SAVE RESULTS TO MATLAB FILE
% ============================================================

results.Quality = qualityLevels;

results.OriginalFileSizeKB = ...
    originalFileSizeKB;


% Standard DCT results

results.Standard.FileSizeKB = ...
    standardSize;

results.Standard.CompressionRatio = ...
    standardRatio;

results.Standard.SpaceSaving = ...
    standardSaving;

results.Standard.MSE = ...
    standardMSE;

results.Standard.PSNR = ...
    standardPSNR;

results.Standard.SSIM = ...
    standardSSIM;


% Adaptive DCT results

results.Adaptive.FileSizeKB = ...
    adaptiveSize;

results.Adaptive.CompressionRatio = ...
    adaptiveRatio;

results.Adaptive.SpaceSaving = ...
    adaptiveSaving;

results.Adaptive.MSE = ...
    adaptiveMSE;

results.Adaptive.PSNR = ...
    adaptivePSNR;

results.Adaptive.SSIM = ...
    adaptiveSSIM;

results.Adaptive.HighDetailBlocks = ...
    highBlocks;

results.Adaptive.MediumDetailBlocks = ...
    mediumBlocks;

results.Adaptive.LowDetailBlocks = ...
    lowBlocks;

results.Adaptive.TotalBlocks = ...
    totalBlocks;


% Improvement results

results.Improvement.FileSizeReductionKB = ...
    fileSizeReduction;

results.Improvement.CompressionRatioGain = ...
    compressionRatioGain;

results.Improvement.SpaceSavingGain = ...
    spaceSavingGain;

results.Improvement.PSNRImprovement = ...
    psnrImprovement;

results.Improvement.MSEReduction = ...
    mseReduction;

results.Improvement.SSIMImprovement = ...
    ssimImprovement;


matResultsPath = fullfile( ...
    resultsFolder, ...
    'complete_experiment_results.mat');

save( ...
    matResultsPath, ...
    'results');


%% ============================================================
% 17. SAVE RESULTS TO CSV
% ============================================================

ResultTable = table( ...
    qualityLevels', ...
    standardSize', ...
    adaptiveSize', ...
    standardRatio', ...
    adaptiveRatio', ...
    standardSaving', ...
    adaptiveSaving', ...
    standardMSE', ...
    adaptiveMSE', ...
    standardPSNR', ...
    adaptivePSNR', ...
    standardSSIM', ...
    adaptiveSSIM', ...
    'VariableNames', ...
    { ...
    'Quality', ...
    'StandardSizeKB', ...
    'AdaptiveSizeKB', ...
    'StandardCompressionRatio', ...
    'AdaptiveCompressionRatio', ...
    'StandardSpaceSaving', ...
    'AdaptiveSpaceSaving', ...
    'StandardMSE', ...
    'AdaptiveMSE', ...
    'StandardPSNR', ...
    'AdaptivePSNR', ...
    'StandardSSIM', ...
    'AdaptiveSSIM' ...
    });


csvPath = fullfile( ...
    resultsFolder, ...
    'complete_experiment_results.csv');

writetable( ...
    ResultTable, ...
    csvPath);


%% ============================================================
% 18. FINAL STATISTICAL SUMMARY
% ============================================================

fprintf('\n\n');

fprintf('============================================================\n');
fprintf('                  FINAL ANALYSIS\n');
fprintf('============================================================\n');

fprintf('\n');

fprintf('Adaptive method evaluated at %d quality levels.\n', ...
    numQualities);

fprintf('\n');

fprintf('Average File Size Reduction : %.2f KB\n', ...
    mean(fileSizeReduction));

fprintf('Average Compression Gain    : %.3f\n', ...
    mean(compressionRatioGain));

fprintf('Average Space Saving Gain   : %.3f %%\n', ...
    mean(spaceSavingGain));

fprintf('Average PSNR Improvement    : %.4f dB\n', ...
    mean(psnrImprovement));

fprintf('Average MSE Reduction       : %.4f\n', ...
    mean(mseReduction));

fprintf('Average SSIM Improvement    : %.5f\n', ...
    mean(ssimImprovement));


%% ============================================================
% 19. COUNT PERFORMANCE IMPROVEMENTS
% ============================================================

betterPSNR = sum( ...
    adaptivePSNR > standardPSNR);

lowerMSE = sum( ...
    adaptiveMSE < standardMSE);

smallerSize = sum( ...
    adaptiveSize < standardSize);

higherSSIM = sum( ...
    adaptiveSSIM > standardSSIM);


fprintf('\n');

fprintf('Adaptive PSNR better at     : %d / %d levels\n', ...
    betterPSNR, ...
    numQualities);

fprintf('Adaptive MSE lower at       : %d / %d levels\n', ...
    lowerMSE, ...
    numQualities);

fprintf('Adaptive file smaller at   : %d / %d levels\n', ...
    smallerSize, ...
    numQualities);

fprintf('Adaptive SSIM higher at    : %d / %d levels\n', ...
    higherSSIM, ...
    numQualities);


%% ============================================================
% 20. FILE LOCATIONS
% ============================================================

fprintf('\n');

fprintf('============================================================\n');
fprintf('                    FILES SAVED\n');
fprintf('============================================================\n');

fprintf('\nMATLAB Results:\n');
fprintf('%s\n',matResultsPath);

fprintf('\nCSV Results:\n');
fprintf('%s\n',csvPath);

fprintf('\nRate-Distortion Graph:\n');
fprintf('%s\n',rateDistortionPath);

fprintf('\nQuality vs PSNR:\n');
fprintf('%s\n',psnrGraphPath);

fprintf('\nQuality vs SSIM:\n');
fprintf('%s\n',ssimGraphPath);

fprintf('\nQuality vs File Size:\n');
fprintf('%s\n',sizeGraphPath);

fprintf('\nQuality vs Compression Ratio:\n');
fprintf('%s\n',ratioGraphPath);

fprintf('\nQuality vs MSE:\n');
fprintf('%s\n',mseGraphPath);

fprintf('\nAdaptive Block Distribution:\n');
fprintf('%s\n',blockGraphPath);


%% ============================================================
% 21. COMPLETE
% ============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('             COMPLETE EXPERIMENT FINISHED\n');
fprintf('============================================================\n');


end


%% ============================================================
% LOCAL FUNCTION
% TRUE STRUCTURAL SIMILARITY INDEX
%
% Manual SSIM implementation.
% Does not require MATLAB's ssim() function.
% ============================================================

function ssimValue = calculateTrueSSIM( ...
    originalImage, ...
    reconstructedImage)


%% ============================================================
% 1. CONVERT ORIGINAL IMAGE TO GRAYSCALE
% ============================================================

original = double(originalImage);

if size(original,3) == 3

    original = ...
        0.299 * original(:,:,1) + ...
        0.587 * original(:,:,2) + ...
        0.114 * original(:,:,3);

end


%% ============================================================
% 2. CONVERT RECONSTRUCTED IMAGE TO GRAYSCALE
% ============================================================

reconstructed = double(reconstructedImage);

if size(reconstructed,3) == 3

    reconstructed = ...
        0.299 * reconstructed(:,:,1) + ...
        0.587 * reconstructed(:,:,2) + ...
        0.114 * reconstructed(:,:,3);

end


%% ============================================================
% 3. CREATE GAUSSIAN WINDOW
% ============================================================

windowSize = 11;

sigma = 1.5;

center = floor(windowSize / 2);

[x,y] = meshgrid( ...
    -center:center, ...
    -center:center);

gaussianWindow = ...
    exp(-(x.^2 + y.^2) / (2 * sigma^2));

gaussianWindow = ...
    gaussianWindow / sum(gaussianWindow(:));


%% ============================================================
% 4. LOCAL MEANS
% ============================================================

muOriginal = ...
    conv2( ...
    original, ...
    gaussianWindow, ...
    'same');

muReconstructed = ...
    conv2( ...
    reconstructed, ...
    gaussianWindow, ...
    'same');


%% ============================================================
% 5. LOCAL VARIANCES
% ============================================================

originalSquared = ...
    original .^ 2;

reconstructedSquared = ...
    reconstructed .^ 2;

sigmaOriginalSquared = ...
    conv2( ...
    originalSquared, ...
    gaussianWindow, ...
    'same') ...
    - muOriginal .^ 2;

sigmaReconstructedSquared = ...
    conv2( ...
    reconstructedSquared, ...
    gaussianWindow, ...
    'same') ...
    - muReconstructed .^ 2;


%% ============================================================
% 6. LOCAL COVARIANCE
% ============================================================

crossProduct = ...
    original .* reconstructed;

sigmaCross = ...
    conv2( ...
    crossProduct, ...
    gaussianWindow, ...
    'same') ...
    - muOriginal .* muReconstructed;


%% ============================================================
% 7. SSIM CONSTANTS
% ============================================================

L = 255;

C1 = (0.01 * L)^2;

C2 = (0.03 * L)^2;


%% ============================================================
% 8. SSIM MAP
% ============================================================

numerator = ...
    (2 .* muOriginal .* muReconstructed + C1) .* ...
    (2 .* sigmaCross + C2);

denominator = ...
    (muOriginal.^2 + muReconstructed.^2 + C1) .* ...
    (sigmaOriginalSquared + ...
     sigmaReconstructedSquared + C2);

ssimMap = ...
    numerator ./ denominator;


%% ============================================================
% 9. REMOVE INVALID VALUES
% ============================================================

ssimMap(~isfinite(ssimMap)) = 0;


%% ============================================================
% 10. FINAL SSIM VALUE
% ============================================================

ssimValue = mean(ssimMap(:));


end