function results = actualCompression(imagePath, quality, outputPath)

    % ============================================================
    % ACTUAL QUANTIZED DCT COMPRESSION
    %
    % Pipeline:
    % Image
    %   -> 8x8 DCT
    %   -> Quantization
    %   -> Frequency coefficient selection
    %   -> Compact integer storage
    %   -> Compressed MAT representation
    %
    % This version uses int16 quantized coefficients instead of
    % storing large single-precision DCT arrays.
    % ============================================================

    % ------------------------------------------------------------
    % CHECK INPUTS
    % ------------------------------------------------------------

    if nargin < 3
        error('Three inputs required: imagePath, quality, outputPath.');
    end

    % Limit quality
    quality = max(10, min(100, quality));

    % ------------------------------------------------------------
    % READ IMAGE
    % ------------------------------------------------------------

    original = imread(imagePath);

    originalDouble = double(original);

    % ------------------------------------------------------------
    % IMAGE DIMENSIONS
    % ------------------------------------------------------------

    [rows, cols, channels] = size(originalDouble);

    % Make dimensions divisible by 8
    newRows = floor(rows / 8) * 8;
    newCols = floor(cols / 8) * 8;

    % Crop image
    originalDouble = ...
        originalDouble(1:newRows, 1:newCols, :);

    % ------------------------------------------------------------
    % CREATE 8x8 DCT TRANSFORM MATRIX
    % ------------------------------------------------------------

    N = 8;

    D = zeros(N, N);

    for k = 0:N-1

        for n = 0:N-1

            if k == 0
                alpha = sqrt(1/N);
            else
                alpha = sqrt(2/N);
            end

            D(k+1,n+1) = ...
                alpha * cos( ...
                (pi * (2*n + 1) * k) / (2*N));

        end

    end

    % ------------------------------------------------------------
    % QUANTIZATION MATRIX
    %
    % Based on the standard JPEG luminance quantization matrix.
    % We scale it according to the requested quality.
    % ------------------------------------------------------------

    Q = [16 11 10 16 24 40 51 61;
         12 12 14 19 26 58 60 55;
         14 13 16 24 40 57 69 56;
         14 17 22 29 51 87 80 62;
         18 22 37 56 68 109 103 77;
         24 35 55 64 81 104 113 92;
         49 64 78 87 103 121 120 101;
         72 92 95 98 112 100 103 99];

    % ------------------------------------------------------------
    % QUALITY SCALING
    % ------------------------------------------------------------

    if quality < 50

        scale = 50 / quality;

    else

        scale = 2 - (quality / 50);

    end

    quantMatrix = max(1, round(Q * scale));

    % ------------------------------------------------------------
    % FREQUENCY RETENTION
    % ------------------------------------------------------------

    blockSize = max(1, ...
        round(8 * sqrt(quality / 100)));

    % ------------------------------------------------------------
    % NUMBER OF BLOCKS
    % ------------------------------------------------------------

    numRowsBlocks = newRows / 8;
    numColsBlocks = newCols / 8;

    % ------------------------------------------------------------
    % CREATE COMPACT STORAGE ARRAY
    %
    % int16 uses 2 bytes per coefficient instead of 4 bytes
    % used by single precision.
    % ------------------------------------------------------------

    retainedCoefficients = zeros( ...
        blockSize, ...
        blockSize, ...
        numRowsBlocks, ...
        numColsBlocks, ...
        channels, ...
        'int16');

    % ============================================================
    % DCT + QUANTIZATION + COEFFICIENT SELECTION
    % ============================================================

    for channel = 1:channels

        channelImage = ...
            originalDouble(:,:,channel);

        for blockRow = 1:numRowsBlocks

            for blockCol = 1:numColsBlocks

                % Calculate starting coordinates
                rowStart = ...
                    (blockRow - 1) * 8 + 1;

                colStart = ...
                    (blockCol - 1) * 8 + 1;

                % Extract 8x8 block
                block = channelImage( ...
                    rowStart:rowStart+7, ...
                    colStart:colStart+7);

                % ------------------------------------------------
                % LEVEL SHIFT
                %
                % Center pixel values around zero before DCT.
                % ------------------------------------------------

                shiftedBlock = block - 128;

                % ------------------------------------------------
                % FORWARD DCT
                % ------------------------------------------------

                dctBlock = ...
                    D * shiftedBlock * D';

                % ------------------------------------------------
                % QUANTIZATION
                % ------------------------------------------------

                quantizedBlock = ...
                    round(dctBlock ./ quantMatrix);

                % ------------------------------------------------
                % RETAIN LOW-FREQUENCY COEFFICIENTS
                % ------------------------------------------------

                selectedCoefficients = ...
                    quantizedBlock( ...
                    1:blockSize, ...
                    1:blockSize);

                % ------------------------------------------------
                % STORE AS INT16
                % ------------------------------------------------

                retainedCoefficients(:,:, ...
                    blockRow, ...
                    blockCol, ...
                    channel) = ...
                    int16(selectedCoefficients);

            end

        end

    end

    % ============================================================
    % CREATE COMPRESSION INFORMATION
    % ============================================================

    compressedRows = newRows;
    compressedCols = newCols;

    originalRows = rows;
    originalCols = cols;

    % ============================================================
    % STORE COMPRESSED REPRESENTATION
    %
    % We use MAT v7 because it supports compressed storage.
    % ============================================================

    save(outputPath, ...
        'retainedCoefficients', ...
        'compressedRows', ...
        'compressedCols', ...
        'originalRows', ...
        'originalCols', ...
        'channels', ...
        'blockSize', ...
        'quality', ...
        'quantMatrix', ...
        '-v7');

    % ============================================================
    % GET FILE SIZES
    % ============================================================

    originalInfo = dir(imagePath);

    compressedInfo = dir(outputPath);

    if isempty(originalInfo)

        error( ...
            'Original image could not be located.');

    end

    if isempty(compressedInfo)

        error( ...
            'Compressed file was not created.');

    end

    originalFileBytes = ...
        originalInfo.bytes;

    compressedFileBytes = ...
        compressedInfo.bytes;

    % ============================================================
    % RAW IMAGE SIZE
    %
    % Useful because PNG/JPEG input is already compressed.
    % ============================================================

    rawImageBytes = ...
        newRows * newCols * channels;

    % ============================================================
    % COMPRESSION RATIO
    % ============================================================

    fileCompressionRatio = ...
        originalFileBytes / compressedFileBytes;

    rawCompressionRatio = ...
        rawImageBytes / compressedFileBytes;

    % ============================================================
    % SPACE SAVING
    % ============================================================

    fileSpaceSaving = ...
        (1 - compressedFileBytes / ...
        originalFileBytes) * 100;

    rawSpaceSaving = ...
        (1 - compressedFileBytes / ...
        rawImageBytes) * 100;

    % ============================================================
    % THEORETICAL COEFFICIENT INFORMATION
    % ============================================================

    totalCoefficients = ...
        numRowsBlocks * ...
        numColsBlocks * ...
        channels * 64;

    retainedCoefficientCount = ...
        numRowsBlocks * ...
        numColsBlocks * ...
        channels * blockSize^2;

    coefficientRetention = ...
        (retainedCoefficientCount / ...
        totalCoefficients) * 100;

    % ============================================================
    % STORE RESULTS
    % ============================================================

    results.OriginalFileSizeBytes = ...
        originalFileBytes;

    results.CompressedFileSizeBytes = ...
        compressedFileBytes;

    results.OriginalFileSizeKB = ...
        originalFileBytes / 1024;

    results.CompressedFileSizeKB = ...
        compressedFileBytes / 1024;

    results.RawImageSizeBytes = ...
        rawImageBytes;

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

    results.Quality = quality;

    results.BlockSize = 8;

    results.RetainedFrequencySize = ...
        blockSize;

    results.TotalBlocks = ...
        numRowsBlocks * numColsBlocks;

    results.ColorChannels = channels;

    results.OutputFile = ...
        outputPath;

    % ============================================================
    % DISPLAY RESULTS
    % ============================================================

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('        QUANTIZED DCT COMPRESSION RESULTS\n');
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

    fprintf('Quality                 : %d %%\n', ...
        quality);

    fprintf('Retained Frequency Size : %d x %d\n', ...
        blockSize, blockSize);

    fprintf('Coefficient Retention   : %.2f %%\n', ...
        coefficientRetention);

    fprintf('Total 8x8 Blocks        : %d\n', ...
        results.TotalBlocks);

    fprintf('Color Channels          : %d\n', ...
        channels);

    fprintf('============================================================\n');

end