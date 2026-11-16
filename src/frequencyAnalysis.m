function frequencyAnalysis(imagePath)

    % ============================================================
    % FREQUENCY DOMAIN ANALYSIS
    % ============================================================

    % Read image
    image = imread(imagePath);

    % Convert RGB image to grayscale
    if size(image, 3) == 3
        image = rgb2gray(image);
    end

    % Convert to double
    image = double(image);

    % ============================================================
    % APPLY 2-D FOURIER TRANSFORM
    % ============================================================

    frequencyDomain = fft2(image);

    % Shift low frequencies to the center
    shiftedSpectrum = fftshift(frequencyDomain);

    % Calculate magnitude spectrum
    magnitudeSpectrum = log(1 + abs(shiftedSpectrum));

    % ============================================================
    % DISPLAY RESULTS
    % ============================================================

    figure('Name', 'Frequency Domain Analysis', ...
           'NumberTitle', 'off');

    % Original image
    subplot(1,2,1);

    imshow(uint8(image));

    title('Original Image', ...
          'FontSize', 14, ...
          'FontWeight', 'bold');

    % Frequency spectrum
    subplot(1,2,2);

    imshow(magnitudeSpectrum, []);

    title('2-D Fourier Frequency Spectrum', ...
          'FontSize', 14, ...
          'FontWeight', 'bold');

end