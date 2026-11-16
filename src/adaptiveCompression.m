function [compressedImage, metrics] = adaptiveCompression(imagePath, quality)

    % ============================================================
    % CONTENT-AWARE ADAPTIVE IMAGE COMPRESSION
    % DCT + EDGE-AWARE COMPRESSION
    % Toolbox-independent implementation
    % ============================================================

    % Read original image
    original = imread(imagePath);

    % ------------------------------------------------------------
    % Preserve color image and create grayscale image for analysis
    % ------------------------------------------------------------

    if size(original, 3) == 3

        colorImage = double(original);

        R = colorImage(:,:,1);
        G = colorImage(:,:,2);
        B = colorImage(:,:,3);

        grayImage = 0.299 * R + ...
                    0.587 * G + ...
                    0.114 * B;

    else

        colorImage = double(original);
        grayImage = colorImage;

    end

    % ------------------------------------------------------------
    % Image dimensions
    % ------------------------------------------------------------

    [rows, cols] = size(grayImage);

    % Make dimensions divisible by 8
    newRows = floor(rows / 8) * 8;
    newCols = floor(cols / 8) * 8;

    % Crop image
    grayImage = grayImage(1:newRows, 1:newCols);

    if size(original, 3) == 3
        colorImage = colorImage(1:newRows, 1:newCols, :);
    end

    % ------------------------------------------------------------
    % Quality control
    % ------------------------------------------------------------

    quality = max(10, min(100, quality));

    % ------------------------------------------------------------
    % Create 8x8 DCT transform matrix
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

            D(k+1,n+1) = alpha * ...
                cos((pi * (2*n + 1) * k) / (2*N));

        end

    end

    % ------------------------------------------------------------
    % Sobel edge detection
    % ------------------------------------------------------------

    Gx = [-1 0 1;
          -2 0 2;
          -1 0 1];

    Gy = [-1 -2 -1;
           0  0  0;
           1  2  1];

    gradientX = conv2(grayImage, Gx, 'same');
    gradientY = conv2(grayImage, Gy, 'same');

    % Calculate gradient magnitude
    gradientMagnitude = sqrt( ...
        gradientX.^2 + gradientY.^2);

    % Normalize gradient
    maxGradient = max(gradientMagnitude(:));

    if maxGradient > 0

        normalizedGradient = ...
            gradientMagnitude / maxGradient;

    else

        normalizedGradient = gradientMagnitude;

    end

    % ------------------------------------------------------------
    % Initialize reconstructed image
    % ------------------------------------------------------------

    compressedGray = zeros(newRows, newCols);

    % ------------------------------------------------------------
    % Statistics
    % ------------------------------------------------------------

    totalRetained = 0;
    totalCoefficients = 0;

    highDetailBlocks = 0;
    mediumDetailBlocks = 0;
    lowDetailBlocks = 0;

    % ============================================================
    % ADAPTIVE DCT COMPRESSION
    % ============================================================

    for i = 1:8:newRows

        for j = 1:8:newCols

            % Extract 8x8 image block
            block = grayImage(i:i+7, j:j+7);

            % Extract corresponding edge block
            edgeBlock = ...
                normalizedGradient(i:i+7, j:j+7);

            % Calculate local edge density
            localEdgeDensity = mean(edgeBlock(:));

            % ----------------------------------------------------
            % ADAPTIVE COMPRESSION
            % ----------------------------------------------------

            if localEdgeDensity > 0.08

                % HIGH DETAIL REGION
                % Preserve more DCT coefficients

                blockSize = round(8 * ...
                    sqrt(min(100, quality + 30) / 100));

                highDetailBlocks = ...
                    highDetailBlocks + 1;

            elseif localEdgeDensity > 0.03

                % MEDIUM DETAIL REGION
                % Moderate compression

                blockSize = round(8 * ...
                    sqrt(quality / 100));

                mediumDetailBlocks = ...
                    mediumDetailBlocks + 1;

            else

                % LOW DETAIL REGION
                % Stronger compression

                blockSize = round(8 * ...
                    sqrt(max(5, quality - 25) / 100));

                lowDetailBlocks = ...
                    lowDetailBlocks + 1;

            end

            % Keep block size between 1 and 8
            blockSize = max(1, min(8, blockSize));

            % ----------------------------------------------------
            % FORWARD DCT
            % ----------------------------------------------------

            dctBlock = D * block * D';

            % ----------------------------------------------------
            % CREATE ADAPTIVE FREQUENCY MASK
            % ----------------------------------------------------

            mask = zeros(8, 8);

            mask(1:blockSize, 1:blockSize) = 1;

            % Keep selected frequency coefficients
            compressedDCT = dctBlock .* mask;

            % ----------------------------------------------------
            % INVERSE DCT
            % ----------------------------------------------------

            reconstructedBlock = ...
                D' * compressedDCT * D;

            % Store reconstructed block
            compressedGray(i:i+7, j:j+7) = ...
                reconstructedBlock;

            % Update coefficient statistics
            totalRetained = ...
                totalRetained + blockSize^2;

            totalCoefficients = ...
                totalCoefficients + 64;

        end

    end

    % ============================================================
    % RECONSTRUCT COLOR IMAGE
    % ============================================================

    if size(original, 3) == 3

        % Difference between reconstructed and original luminance
        difference = compressedGray - grayImage;

        compressedImage = zeros( ...
            newRows, newCols, 3);

        % Apply luminance change to RGB channels
        for channel = 1:3

            channelData = ...
                colorImage(:,:,channel);

            reconstructedChannel = ...
                channelData + difference;

            compressedImage(:,:,channel) = ...
                reconstructedChannel;

        end

    else

        compressedImage = compressedGray;

    end

    % ------------------------------------------------------------
    % Convert to uint8
    % ------------------------------------------------------------

    compressedImage = uint8( ...
        max(0, min(255, compressedImage)));

    originalColor = uint8(colorImage);

    % ============================================================
    % QUALITY METRICS
    % ============================================================

    % Convert reconstructed image to grayscale
    compressedGrayFinal = ...
        double(rgbToGrayManual(compressedImage));

    originalGrayFinal = ...
        double(rgbToGrayManual(originalColor));

    % ------------------------------------------------------------
    % MSE
    % ------------------------------------------------------------

    difference = ...
        compressedGrayFinal - originalGrayFinal;

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
    % Structural similarity approximation
    % ------------------------------------------------------------

    originalVector = ...
        originalGrayFinal(:);

    compressedVector = ...
        compressedGrayFinal(:);

    correlationMatrix = ...
        corrcoef(originalVector, compressedVector);

    if size(correlationMatrix, 1) == 2

        metrics.SSIM = ...
            correlationMatrix(1,2);

    else

        metrics.SSIM = 1;

    end

    % ------------------------------------------------------------
    % Coefficient retention
    % ------------------------------------------------------------

    metrics.CoefficientRetention = ...
        (totalRetained / totalCoefficients) * 100;

    % ------------------------------------------------------------
    % Adaptive compression statistics
    % ------------------------------------------------------------

    metrics.HighDetailBlocks = ...
        highDetailBlocks;

    metrics.MediumDetailBlocks = ...
        mediumDetailBlocks;

    metrics.LowDetailBlocks = ...
        lowDetailBlocks;

    metrics.TotalBlocks = ...
        totalCoefficients / 64;

    metrics.AdaptiveMode = true;

end


% ================================================================
% MANUAL RGB TO GRAYSCALE FUNCTION
% ================================================================

function gray = rgbToGrayManual(image)

    if size(image, 3) == 3

        R = double(image(:,:,1));
        G = double(image(:,:,2));
        B = double(image(:,:,3));

        gray = uint8( ...
            max(0, min(255, ...
            0.299 * R + ...
            0.587 * G + ...
            0.114 * B)));

    else

        gray = image;

    end

end