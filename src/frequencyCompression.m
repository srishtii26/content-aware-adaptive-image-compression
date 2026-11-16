function [compressedImage, metrics] = frequencyCompression(imagePath, quality)

    % ============================================================
    % STANDARD DCT-BASED COLOR IMAGE COMPRESSION
    % Toolbox-independent implementation
    % ============================================================

    % Read original image
    original = imread(imagePath);

    % Convert image to double
    originalDouble = double(original);

    % ============================================================
    % CHECK IMAGE TYPE
    % ============================================================

  
    if size(original, 3) == 3

        % Color image
        colorImage = originalDouble;

    else

        % Grayscale image
        colorImage = originalDouble;

    end

    % ============================================================
    % IMAGE DIMENSIONS
    % ============================================================

    [rows, cols, channels] = size(colorImage);

    % Make dimensions divisible by 8
    newRows = floor(rows / 8) * 8;
    newCols = floor(cols / 8) * 8;

    % Crop image
    colorImage = ...
        colorImage(1:newRows, 1:newCols, :);

    % Initialize compressed image
    compressedImage = zeros( ...
        newRows, newCols, channels);

    % ============================================================
    % QUALITY CONTROL
    % ============================================================

    retainPercentage = ...
        max(5, min(100, quality));

    % Determine retained low-frequency region
    blockSize = max(1, ...
        round(8 * sqrt(retainPercentage / 100)));

    % ============================================================
    % CREATE 8x8 DCT TRANSFORM MATRIX
    % ============================================================

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

    % ============================================================
    % PROCESS EACH COLOR CHANNEL
    % ============================================================

    for channel = 1:channels

        % Extract channel
        channelImage = ...
            colorImage(:,:,channel);

        % --------------------------------------------------------
        % PROCESS IMAGE BLOCK-BY-BLOCK
        % --------------------------------------------------------

        for i = 1:8:newRows

            for j = 1:8:newCols

                % Extract 8x8 block
                block = ...
                    channelImage(i:i+7, j:j+7);

                % ------------------------------------------------
                % FORWARD 2-D DCT
                % ------------------------------------------------

                dctBlock = D * block * D';

                % ------------------------------------------------
                % FREQUENCY MASK
                % ------------------------------------------------

                mask = zeros(8,8);

                % Retain low-frequency coefficients
                mask(1:blockSize,1:blockSize) = 1;

                % Remove high-frequency coefficients
                compressedDCT = ...
                    dctBlock .* mask;

                % ------------------------------------------------
                % INVERSE 2-D DCT
                % ------------------------------------------------

                reconstructedBlock = ...
                    D' * compressedDCT * D;

                % Store reconstructed block
                compressedImage( ...
                    i:i+7, ...
                    j:j+7, ...
                    channel) = reconstructedBlock;

            end

        end

    end

    % ============================================================
    % CONVERT BACK TO UINT8 IMAGE
    % ============================================================

    compressedImage = uint8( ...
        max(0, min(255, compressedImage)));

    originalImage = uint8(colorImage);

    % ============================================================
    % QUALITY METRICS
    % ============================================================

    % Calculate difference for all RGB channels
    difference = ...
        double(compressedImage) - ...
        double(originalImage);

    % ------------------------------------------------------------
    % MSE
    % ------------------------------------------------------------

    metrics.MSE = ...
        mean(difference(:).^2);

    % ------------------------------------------------------------
    % PSNR
    % ------------------------------------------------------------

    if metrics.MSE == 0

        metrics.PSNR = Inf;

    else

        metrics.PSNR = ...
            10 * log10((255^2) / metrics.MSE);

    end

    % ------------------------------------------------------------
    % CORRELATION-BASED SIMILARITY
    % ------------------------------------------------------------

    originalVector = ...
        double(originalImage(:));

    compressedVector = ...
        double(compressedImage(:));

    correlationMatrix = ...
        corrcoef(originalVector, compressedVector);

    if size(correlationMatrix,1) == 2

        metrics.SSIM = ...
            correlationMatrix(1,2);

    else

        metrics.SSIM = 1;

    end

    % ============================================================
    % COEFFICIENT RETENTION
    % ============================================================

    metrics.CoefficientRetention = ...
        (blockSize^2 / 64) * 100;

    % ============================================================
    % COMPRESSION INFORMATION
    % ============================================================

    metrics.Quality = quality;

    metrics.BlockSize = 8;

    metrics.RetainedFrequencySize = blockSize;

    metrics.TotalBlocks = ...
        floor(newRows/8) * floor(newCols/8);

    % ============================================================
    % IMAGE INFORMATION
    % ============================================================

    metrics.OriginalHeight = newRows;

    metrics.OriginalWidth = newCols;

    metrics.ColorChannels = channels;

end