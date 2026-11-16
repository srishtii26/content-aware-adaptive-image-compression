function [edgeMap, edgeDensity, edgeOverlay] = edgeDetection(imagePath)

    % ============================================================
    % EDGE DETECTION USING SOBEL OPERATOR
    % Toolbox-independent implementation
    % ============================================================

    % Read original image
    original = imread(imagePath);

    % ------------------------------------------------------------
    % Convert RGB to grayscale manually
    % ------------------------------------------------------------

    if size(original, 3) == 3

        R = double(original(:,:,1));
        G = double(original(:,:,2));
        B = double(original(:,:,3));

        grayImage = 0.299 * R + ...
                    0.587 * G + ...
                    0.114 * B;

    else

        grayImage = double(original);

    end

    % ------------------------------------------------------------
    % Sobel operators
    % ------------------------------------------------------------

    Gx = [-1 0 1;
          -2 0 2;
          -1 0 1];

    Gy = [-1 -2 -1;
           0  0  0;
           1  2  1];

    % ------------------------------------------------------------
    % Calculate horizontal and vertical gradients
    % ------------------------------------------------------------

    gradientX = conv2(grayImage, Gx, 'same');
    gradientY = conv2(grayImage, Gy, 'same');

    % ------------------------------------------------------------
    % Calculate gradient magnitude
    % ------------------------------------------------------------

    gradientMagnitude = sqrt( ...
        gradientX.^2 + gradientY.^2);

    % Normalize gradient magnitude
    maxGradient = max(gradientMagnitude(:));

    if maxGradient > 0
        normalizedGradient = ...
            gradientMagnitude / maxGradient;
    else
        normalizedGradient = gradientMagnitude;
    end

    % ------------------------------------------------------------
    % Adaptive threshold
    % ------------------------------------------------------------

    threshold = 0.20;

    % Create binary edge map
    edgeMap = normalizedGradient > threshold;

    % ------------------------------------------------------------
    % Calculate edge density
    % ------------------------------------------------------------

    edgeDensity = sum(edgeMap(:)) / numel(edgeMap);

    % ------------------------------------------------------------
    % Create colored edge overlay
    % ------------------------------------------------------------

    if size(original, 3) == 1

        originalColor = repmat( ...
            uint8(original), [1 1 3]);

    else

        originalColor = original;

    end

    edgeOverlay = originalColor;

    % Highlight detected edges
    redChannel = edgeOverlay(:,:,1);
    greenChannel = edgeOverlay(:,:,2);
    blueChannel = edgeOverlay(:,:,3);

    redChannel(edgeMap) = 255;
    greenChannel(edgeMap) = 0;
    blueChannel(edgeMap) = 0;

    edgeOverlay(:,:,1) = redChannel;
    edgeOverlay(:,:,2) = greenChannel;
    edgeOverlay(:,:,3) = blueChannel;

    % ------------------------------------------------------------
    % Display results
    % ------------------------------------------------------------

    figure('Name', 'Edge Detection Analysis', ...
           'NumberTitle', 'off');

    subplot(1,3,1);

    image(originalColor);
    axis image off;
    title('Original Color Image', ...
          'FontSize', 13, ...
          'FontWeight', 'bold');

    subplot(1,3,2);

    imagesc(normalizedGradient);
    axis image off;
    colormap(gca, 'jet');
    colorbar;
    title('Edge Strength Map', ...
          'FontSize', 13, ...
          'FontWeight', 'bold');

    subplot(1,3,3);

    image(edgeOverlay);
    axis image off;
    title('Detected Edges', ...
          'FontSize', 13, ...
          'FontWeight', 'bold');

    % ------------------------------------------------------------
    % Display edge density
    % ------------------------------------------------------------

    fprintf('\n');
    fprintf('============================================\n');
    fprintf('           EDGE DETECTION RESULTS\n');
    fprintf('============================================\n');

    fprintf('Edge Threshold : %.2f\n', threshold);

    fprintf('Edge Density   : %.2f %%\n', ...
            edgeDensity * 100);

    fprintf('============================================\n');
    fprintf('\n');

end