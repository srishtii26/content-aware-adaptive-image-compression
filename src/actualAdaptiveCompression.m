function results = actualAdaptiveCompression(imagePath, quality, outputPath)

    % ============================================================
    % ACTUAL CONTENT-AWARE ADAPTIVE DCT COMPRESSION
    % ============================================================

    if nargin < 3
        error('Three inputs required: imagePath, quality, outputPath.');
    end

    quality = max(10, min(100, quality));

    % ============================================================
    % READ IMAGE
    % ============================================================

    original = imread(imagePath);
    originalDouble = double(original);

    [rows, cols, channels] = size(originalDouble);

    % Make dimensions divisible by 8
    newRows = floor(rows / 8) * 8;
    newCols = floor(cols / 8) * 8;

    originalDouble = originalDouble(1:newRows, 1:newCols, :);

    % ============================================================
    % CREATE GRAYSCALE IMAGE FOR EDGE ANALYSIS
    % ============================================================

    if channels == 3

        R = originalDouble(:,:,1);
        G = originalDouble(:,:,2);
        B = originalDouble(:,:,3);

        grayImage = 0.299 * R + ...
                    0.587 * G + ...
                    0.114 * B;

    else

        grayImage = originalDouble;

    end

    % ============================================================
    % CREATE 8x8 DCT MATRIX
    % ============================================================

    N = 8;

    D = zeros(N,N);

    for k = 0:N-1

        for n = 0:N-1

            if k == 0
                alpha = sqrt(1/N);
            else
                alpha = sqrt(2/N);
            end

            D(k+1,n+1) = alpha * ...
                cos((pi * (2*n + 1) * k) / (2*N));

        end

    end

    % ============================================================
    % JPEG-LIKE QUANTIZATION MATRIX
    % ============================================================

    Q = [16 11 10 16 24 40 51 61;
         12 12 14 19 26 58 60 55;
         14 13 16 24 40 57 69 56;
         14 17 22 29 51 87 80 62;
         18 22 37 56 68 109 103 77;
         24 35 55 64 81 104 113 92;
         49 64 78 87 103 121 120 101;
         72 92 95 98 112 100 103 99];

    % ============================================================
    % QUALITY SCALING
    % ============================================================

    if quality < 50

        scale = 50 / quality;

    else

        scale = 2 - quality / 50;

    end

    quantMatrix = max(1, round(Q * scale));

    % ============================================================
    % SOBEL EDGE DETECTION
    % ============================================================

    Gx = [-1 0 1;
          -2 0 2;
          -1 0 1];

    Gy = [-1 -2 -1;
           0  0  0;
           1  2  1];

    gradientX = conv2(grayImage, Gx, 'same');

    gradientY = conv2(grayImage, Gy, 'same');

    gradientMagnitude = sqrt( ...
        gradientX.^2 + gradientY.^2);

    maxGradient = max(gradientMagnitude(:));

    if maxGradient > 0

        normalizedGradient = ...
            gradientMagnitude / maxGradient;

    else

        normalizedGradient = gradientMagnitude;

    end

    % ============================================================
    % BLOCK INFORMATION
    % ============================================================

    numRowsBlocks = newRows / 8;
    numColsBlocks = newCols / 8;

    totalBlocks = ...
        numRowsBlocks * numColsBlocks;

    % ============================================================
    % DETERMINE ADAPTIVE BLOCK SIZE
    % ============================================================

    blockSizes = zeros( ...
        numRowsBlocks, ...
        numColsBlocks, ...
        'uint8');

    blockTypes = zeros( ...
        numRowsBlocks, ...
        numColsBlocks, ...
        'uint8');

    highDetailBlocks = 0;
    mediumDetailBlocks = 0;
    lowDetailBlocks = 0;

    totalRetainedCoefficients = 0;

    for blockRow = 1:numRowsBlocks

        for blockCol = 1:numColsBlocks

            rowStart = ...
                (blockRow - 1) * 8 + 1;

            colStart = ...
                (blockCol - 1) * 8 + 1;

            edgeBlock = ...
                normalizedGradient( ...
                rowStart:rowStart+7, ...
                colStart:colStart+7);

            localEdgeDensity = mean(edgeBlock(:));

            % ----------------------------------------------------
            % HIGH DETAIL REGION
            % ----------------------------------------------------

            if localEdgeDensity > 0.08

                blockSize = round( ...
                    8 * sqrt( ...
                    min(100, quality + 30) / 100));

                blockType = 3;

                highDetailBlocks = ...
                    highDetailBlocks + 1;

            % ----------------------------------------------------
            % MEDIUM DETAIL REGION
            % ----------------------------------------------------

            elseif localEdgeDensity > 0.03

                blockSize = round( ...
                    8 * sqrt(quality / 100));

                blockType = 2;

                mediumDetailBlocks = ...
                    mediumDetailBlocks + 1;

            % ----------------------------------------------------
            % LOW DETAIL REGION
            % ----------------------------------------------------

            else

                blockSize = round( ...
                    8 * sqrt( ...
                    max(5, quality - 25) / 100));

                blockType = 1;

                lowDetailBlocks = ...
                    lowDetailBlocks + 1;

            end

            % Keep between 1 and 8
            blockSize = max(1, min(8, blockSize));

            blockSizes(blockRow, blockCol) = ...
                uint8(blockSize);

            blockTypes(blockRow, blockCol) = ...
                uint8(blockType);

            totalRetainedCoefficients = ...
                totalRetainedCoefficients + blockSize^2;

        end

    end

    % ============================================================
    % CALCULATE STORAGE SIZE
    % ============================================================

    totalStoredCoefficients = ...
        totalRetainedCoefficients * channels;

    retainedCoefficients = zeros( ...
        totalStoredCoefficients, ...
        1, ...
        'int16');

    currentPosition = 1;

    % ============================================================
    % DCT + QUANTIZATION + ADAPTIVE STORAGE
    % ============================================================

    for channel = 1:channels

        channelImage = ...
            originalDouble(:,:,channel);

        for blockRow = 1:numRowsBlocks

            for blockCol = 1:numColsBlocks

                rowStart = ...
                    (blockRow - 1) * 8 + 1;

                colStart = ...
                    (blockCol - 1) * 8 + 1;

                block = ...
                    channelImage( ...
                    rowStart:rowStart+7, ...
                    colStart:colStart+7);

                blockSize = double( ...
                    blockSizes(blockRow, blockCol));

                % Level shift
                shiftedBlock = block - 128;

                % Forward DCT
                dctBlock = D * shiftedBlock * D';

                % Quantization
                quantizedBlock = ...
                    round(dctBlock ./ quantMatrix);

                % Select adaptive coefficients
                selectedCoefficients = ...
                    quantizedBlock( ...
                    1:blockSize, ...
                    1:blockSize);

                selectedCoefficients = ...
                    int16(selectedCoefficients(:));

                numberCoefficients = ...
                    numel(selectedCoefficients);

                endPosition = ...
                    currentPosition + ...
                    numberCoefficients - 1;

                retainedCoefficients( ...
                    currentPosition:endPosition) = ...
                    selectedCoefficients;

                currentPosition = ...
                    endPosition + 1;

            end

        end

    end

    % ============================================================
    % DEFINE SAVED IMAGE DIMENSIONS
    % ============================================================

    compressedRows = newRows;
    compressedCols = newCols;

    % ============================================================
    % SAVE ACTUAL ADAPTIVE COMPRESSED FILE
    % ============================================================

    save(outputPath, ...
        'retainedCoefficients', ...
        'blockSizes', ...
        'blockTypes', ...
        'compressedRows', ...
        'compressedCols', ...
        'channels', ...
        'quality', ...
        'quantMatrix', ...
        '-v7');

    % ============================================================
    % FILE SIZE MEASUREMENT
    % ============================================================

    originalInfo = dir(imagePath);
    compressedInfo = dir(outputPath);

    originalFileBytes = originalInfo.bytes;
    compressedFileBytes = compressedInfo.bytes;

    rawImageBytes = ...
        newRows * newCols * channels;

    % ============================================================
    % COMPRESSION METRICS
    % ============================================================

    fileCompressionRatio = ...
        originalFileBytes / compressedFileBytes;

    rawCompressionRatio = ...
        rawImageBytes / compressedFileBytes;

    fileSpaceSaving = ...
        (1 - compressedFileBytes / ...
        originalFileBytes) * 100;

    rawSpaceSaving = ...
        (1 - compressedFileBytes / ...
        rawImageBytes) * 100;

    totalPossibleCoefficients = ...
        totalBlocks * channels * 64;

    coefficientRetention = ...
        (totalRetainedCoefficients * channels / ...
        totalPossibleCoefficients) * 100;

    % ============================================================
    % STORE RESULTS
    % ============================================================

    results.OriginalFileSizeKB = ...
        originalFileBytes / 1024;

    results.CompressedFileSizeKB = ...
        compressedFileBytes / 1024;

    results.RawImageSizeKB = ...
        rawImageBytes / 1024;

    results.FileCompressionRatio = ...
        fileCompressionRatio;

    results.RawCompressionRatio = ...
        rawCompressionRatio;

    results.FileSpaceSavingPercent = ...
        fileSpaceSaving;

    results.RawSpaceSavingPercent = ...
        rawSpaceSaving;

    results.CoefficientRetention = ...
        coefficientRetention;

    results.HighDetailBlocks = ...
        highDetailBlocks;

    results.MediumDetailBlocks = ...
        mediumDetailBlocks;

    results.LowDetailBlocks = ...
        lowDetailBlocks;

    results.TotalBlocks = ...
        totalBlocks;

    results.Quality = ...
        quality;

    results.OutputFile = ...
        outputPath;

    % ============================================================
    % DISPLAY RESULTS
    % ============================================================

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('       ACTUAL ADAPTIVE DCT COMPRESSION RESULTS\n');
    fprintf('============================================================\n');

    fprintf('Original File Size      : %.2f KB\n', ...
        results.OriginalFileSizeKB);

    fprintf('Compressed File Size    : %.2f KB\n', ...
        results.CompressedFileSizeKB);

    fprintf('Raw Image Size          : %.2f KB\n', ...
        results.RawImageSizeKB);

    fprintf('\n');

    fprintf('File Compression Ratio  : %.2f : 1\n', ...
        results.FileCompressionRatio);

    fprintf('Raw Compression Ratio   : %.2f : 1\n', ...
        results.RawCompressionRatio);

    fprintf('File Space Saving       : %.2f %%\n', ...
        results.FileSpaceSavingPercent);

    fprintf('Raw Space Saving        : %.2f %%\n', ...
        results.RawSpaceSavingPercent);

    fprintf('\n');

    fprintf('Coefficient Retention   : %.2f %%\n', ...
        results.CoefficientRetention);

    fprintf('High Detail Blocks      : %d\n', ...
        results.HighDetailBlocks);

    fprintf('Medium Detail Blocks    : %d\n', ...
        results.MediumDetailBlocks);

    fprintf('Low Detail Blocks       : %d\n', ...
        results.LowDetailBlocks);

    fprintf('Total Blocks            : %d\n', ...
        results.TotalBlocks);

    fprintf('============================================================\n');

end