function finalComparison()

    % ============================================================
    % FINAL STANDARD DCT vs ADAPTIVE DCT COMPARISON
    % ============================================================

    clc;
    close all;

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('       FINAL IMAGE COMPRESSION COMPARISON\n');
    fprintf('============================================================\n');

    % ------------------------------------------------------------
    % PROJECT PATHS
    % ------------------------------------------------------------

    projectRoot = fileparts(fileparts(mfilename('fullpath')));

    addpath(fullfile(projectRoot, 'src'));

    originalPath = fullfile( ...
        projectRoot, ...
        'test_images', ...
        'peppers.png');

    standardCompressedPath = fullfile( ...
        projectRoot, ...
        'results', ...
        'peppers_compressed.mat');

    adaptiveCompressedPath = fullfile( ...
        projectRoot, ...
        'results', ...
        'peppers_adaptive_compressed.mat');

    % ------------------------------------------------------------
    % CHECK FILES
    % ------------------------------------------------------------

    if ~isfile(originalPath)
        error('Original image not found.');
    end

    if ~isfile(standardCompressedPath)
        error('Standard compressed file not found.');
    end

    if ~isfile(adaptiveCompressedPath)
        error('Adaptive compressed file not found.');
    end

    % ------------------------------------------------------------
    % LOAD ORIGINAL IMAGE
    % ------------------------------------------------------------

    originalImage = imread(originalPath);

    % ------------------------------------------------------------
    % DECOMPRESS STANDARD DCT
    % ------------------------------------------------------------

    fprintf('\nDecompressing Standard DCT...\n');

    [standardImage, standardMetrics] = ...
        decompressImage(standardCompressedPath);

    % ------------------------------------------------------------
    % DECOMPRESS ADAPTIVE DCT
    % ------------------------------------------------------------

    fprintf('Decompressing Adaptive DCT...\n');

    [adaptiveImage, adaptiveMetrics] = ...
        decompressAdaptiveImage(adaptiveCompressedPath);

    % ------------------------------------------------------------
    % FILE SIZE INFORMATION
    % ------------------------------------------------------------

    originalInfo = dir(originalPath);
    standardInfo = dir(standardCompressedPath);
    adaptiveInfo = dir(adaptiveCompressedPath);

    originalSizeKB = originalInfo.bytes / 1024;
    standardSizeKB = standardInfo.bytes / 1024;
    adaptiveSizeKB = adaptiveInfo.bytes / 1024;

    % ------------------------------------------------------------
    % COMPRESSION RATIOS
    % ------------------------------------------------------------

    standardRatio = ...
        originalSizeKB / standardSizeKB;

    adaptiveRatio = ...
        originalSizeKB / adaptiveSizeKB;

    % ------------------------------------------------------------
    % SPACE SAVING
    % ------------------------------------------------------------

    standardSaving = ...
        ((originalSizeKB - standardSizeKB) / ...
        originalSizeKB) * 100;

    adaptiveSaving = ...
        ((originalSizeKB - adaptiveSizeKB) / ...
        originalSizeKB) * 100;

    % ------------------------------------------------------------
    % IMPROVEMENTS
    % ------------------------------------------------------------

    psnrImprovement = ...
        adaptiveMetrics.PSNR - standardMetrics.PSNR;

    mseImprovement = ...
        standardMetrics.MSE - adaptiveMetrics.MSE;

    compressionImprovement = ...
        adaptiveRatio - standardRatio;

    sizeReduction = ...
        standardSizeKB - adaptiveSizeKB;

    % ------------------------------------------------------------
    % DISPLAY FINAL RESULTS
    % ------------------------------------------------------------

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('                 FINAL COMPARISON\n');
    fprintf('============================================================\n');

    fprintf('\n');

    fprintf('%-30s %-15s %-15s\n', ...
        'METRIC', 'STANDARD DCT', 'ADAPTIVE DCT');

    fprintf('------------------------------------------------------------\n');

    fprintf('%-30s %-15.2f %-15.2f\n', ...
        'Compressed Size (KB)', ...
        standardSizeKB, ...
        adaptiveSizeKB);

    fprintf('%-30s %-15.2f %-15.2f\n', ...
        'Compression Ratio', ...
        standardRatio, ...
        adaptiveRatio);

    fprintf('%-30s %-15.2f %-15.2f\n', ...
        'Space Saving (%)', ...
        standardSaving, ...
        adaptiveSaving);

    fprintf('%-30s %-15.4f %-15.4f\n', ...
        'MSE', ...
        standardMetrics.MSE, ...
        adaptiveMetrics.MSE);

    fprintf('%-30s %-15.2f %-15.2f\n', ...
        'PSNR (dB)', ...
        standardMetrics.PSNR, ...
        adaptiveMetrics.PSNR);

    fprintf('%-30s %-15.4f %-15.4f\n', ...
        'Similarity', ...
        standardMetrics.Similarity, ...
        adaptiveMetrics.Similarity);

    fprintf('------------------------------------------------------------\n');

    % ------------------------------------------------------------
    % ADAPTIVE INFORMATION
    % ------------------------------------------------------------

    fprintf('\n');
    fprintf('ADAPTIVE COMPRESSION DETAILS\n');
    fprintf('------------------------------------------------------------\n');

    fprintf('High Detail Blocks       : %d\n', ...
        adaptiveMetrics.HighDetailBlocks);

    fprintf('Medium Detail Blocks     : %d\n', ...
        adaptiveMetrics.MediumDetailBlocks);

    fprintf('Low Detail Blocks        : %d\n', ...
        adaptiveMetrics.LowDetailBlocks);

    fprintf('Total Blocks             : %d\n', ...
        adaptiveMetrics.TotalBlocks);

    fprintf('------------------------------------------------------------\n');

    % ------------------------------------------------------------
    % IMPROVEMENT SUMMARY
    % ------------------------------------------------------------

    fprintf('\n');
    fprintf('IMPROVEMENT ACHIEVED BY ADAPTIVE METHOD\n');
    fprintf('------------------------------------------------------------\n');

    fprintf('Compressed File Reduction : %.2f KB\n', ...
        sizeReduction);

    fprintf('Compression Ratio Gain    : %.2f\n', ...
        compressionImprovement);

    fprintf('PSNR Difference           : %.2f dB\n', ...
        psnrImprovement);

    fprintf('MSE Difference            : %.4f\n', ...
        mseImprovement);

    fprintf('------------------------------------------------------------\n');

    % ------------------------------------------------------------
    % FIGURE 1 - RECONSTRUCTION COMPARISON
    % ------------------------------------------------------------

    figure( ...
        'Name', ...
        'Standard vs Adaptive Reconstruction', ...
        'NumberTitle', ...
        'off');

    subplot(1,3,1);

    imshow(originalImage);

    title('Original Image');

    subplot(1,3,2);

    imshow(standardImage);

    title('Standard DCT');

    subplot(1,3,3);

    imshow(adaptiveImage);

    title('Adaptive DCT');

    % ------------------------------------------------------------
    % FIGURE 2 - COMPRESSION COMPARISON
    % ------------------------------------------------------------

    figure( ...
        'Name', ...
        'Compression Performance', ...
        'NumberTitle', ...
        'off');

    compressionValues = ...
        [standardSizeKB adaptiveSizeKB];

    bar(compressionValues);

    title('Compressed File Size Comparison');

    ylabel('File Size (KB)');

    xticks([1 2]);

    xticklabels({'Standard DCT','Adaptive DCT'});

    grid on;

    % ------------------------------------------------------------
    % FIGURE 3 - PSNR COMPARISON
    % ------------------------------------------------------------

    figure( ...
        'Name', ...
        'Image Quality Comparison', ...
        'NumberTitle', ...
        'off');

    psnrValues = ...
        [standardMetrics.PSNR adaptiveMetrics.PSNR];

    bar(psnrValues);

    title('PSNR Comparison');

    ylabel('PSNR (dB)');

    xticks([1 2]);

    xticklabels({'Standard DCT','Adaptive DCT'});

    grid on;

    % ------------------------------------------------------------
    % FIGURE 4 - COMPRESSION RATIO
    % ------------------------------------------------------------

    figure( ...
        'Name', ...
        'Compression Ratio Comparison', ...
        'NumberTitle', ...
        'off');

    ratioValues = ...
        [standardRatio adaptiveRatio];

    bar(ratioValues);

    title('Compression Ratio Comparison');

    ylabel('Compression Ratio');

    xticks([1 2]);

    xticklabels({'Standard DCT','Adaptive DCT'});

    grid on;

    % ------------------------------------------------------------
    % FIGURE 5 - ADAPTIVE BLOCK DISTRIBUTION
    % ------------------------------------------------------------

    figure( ...
        'Name', ...
        'Adaptive Block Distribution', ...
        'NumberTitle', ...
        'off');

    blockValues = [
        adaptiveMetrics.HighDetailBlocks
        adaptiveMetrics.MediumDetailBlocks
        adaptiveMetrics.LowDetailBlocks
    ];

    bar(blockValues);

    title('Adaptive Block Classification');

    ylabel('Number of 8x8 Blocks');

    xticks([1 2 3]);

    xticklabels({
        'High Detail'
        'Medium Detail'
        'Low Detail'
    });

    grid on;

    % ------------------------------------------------------------
    % SAVE RESULTS
    % ------------------------------------------------------------

    results.StandardCompressedSizeKB = standardSizeKB;
    results.AdaptiveCompressedSizeKB = adaptiveSizeKB;

    results.StandardCompressionRatio = standardRatio;
    results.AdaptiveCompressionRatio = adaptiveRatio;

    results.StandardSpaceSaving = standardSaving;
    results.AdaptiveSpaceSaving = adaptiveSaving;

    results.StandardMSE = standardMetrics.MSE;
    results.AdaptiveMSE = adaptiveMetrics.MSE;

    results.StandardPSNR = standardMetrics.PSNR;
    results.AdaptivePSNR = adaptiveMetrics.PSNR;

    results.StandardSimilarity = ...
        standardMetrics.Similarity;

    results.AdaptiveSimilarity = ...
        adaptiveMetrics.Similarity;

    results.PSNRImprovement = psnrImprovement;

    results.MSEReduction = mseImprovement;

    results.FileSizeReductionKB = sizeReduction;

    results.HighDetailBlocks = ...
        adaptiveMetrics.HighDetailBlocks;

    results.MediumDetailBlocks = ...
        adaptiveMetrics.MediumDetailBlocks;

    results.LowDetailBlocks = ...
        adaptiveMetrics.LowDetailBlocks;

    results.TotalBlocks = ...
        adaptiveMetrics.TotalBlocks;

    save( ...
        fullfile(projectRoot, ...
        'results', ...
        'finalComparisonResults.mat'), ...
        'results');

    % ------------------------------------------------------------
    % FINAL MESSAGE
    % ------------------------------------------------------------

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('Comparison completed successfully.\n');
    fprintf('Results saved to:\n');
    fprintf('%s\n', fullfile( ...
        projectRoot, ...
        'results', ...
        'finalComparisonResults.mat'));

    fprintf('============================================================\n');

end