function metrics = compressionMetrics(imagePath, coefficientRetention)

    % ============================================================
    % COMPRESSION METRICS
    % Calculates image size, estimated compressed size,
    % compression ratio and space saving.
    % ============================================================

    % ------------------------------------------------------------
    % Check input
    % ------------------------------------------------------------

    if nargin < 2
        error('Two inputs are required: imagePath and coefficientRetention.');
    end

    % ------------------------------------------------------------
    % Get original file information
    % ------------------------------------------------------------

    fileInfo = dir(imagePath);

    if isempty(fileInfo)
        error('Image file not found: %s', imagePath);
    end

    originalFileSizeBytes = fileInfo.bytes;

    % ------------------------------------------------------------
    % Read image
    % ------------------------------------------------------------

    original = imread(imagePath);

    [rows, cols, channels] = size(original);

    % ------------------------------------------------------------
    % Calculate raw image size
    % ------------------------------------------------------------

    rawImageSizeBytes = rows * cols * channels;

    % ------------------------------------------------------------
    % Calculate estimated compressed size
    %
    % Assumption:
    % Each retained DCT coefficient is stored using the same
    % number of bytes as the original pixel representation.
    %
    % This is an ESTIMATE, not an actual encoded JPEG-like file.
    % ------------------------------------------------------------

    coefficientRetention = ...
        max(0, min(100, coefficientRetention));

    estimatedCompressedBytes = ...
        rawImageSizeBytes * ...
        (coefficientRetention / 100);

    % ------------------------------------------------------------
    % Estimated compression ratio
    % ------------------------------------------------------------

    if estimatedCompressedBytes > 0

        estimatedCompressionRatio = ...
            rawImageSizeBytes / estimatedCompressedBytes;

    else

        estimatedCompressionRatio = Inf;

    end

    % ------------------------------------------------------------
    % Estimated space saving
    % ------------------------------------------------------------

    estimatedSpaceSaving = ...
        (1 - coefficientRetention / 100) * 100;

    % ------------------------------------------------------------
    % File-size-based comparison
    % ------------------------------------------------------------

    fileBasedSizeRatio = ...
        rawImageSizeBytes / originalFileSizeBytes;

    % ------------------------------------------------------------
    % Store results
    % ------------------------------------------------------------

    metrics.OriginalFileSizeBytes = ...
        originalFileSizeBytes;

    metrics.OriginalFileSizeKB = ...
        originalFileSizeBytes / 1024;

    metrics.RawImageSizeBytes = ...
        rawImageSizeBytes;

    metrics.RawImageSizeKB = ...
        rawImageSizeBytes / 1024;

    metrics.CoefficientRetention = ...
        coefficientRetention;

    metrics.EstimatedCompressedSizeBytes = ...
        estimatedCompressedBytes;

    metrics.EstimatedCompressedSizeKB = ...
        estimatedCompressedBytes / 1024;

    metrics.EstimatedCompressionRatio = ...
        estimatedCompressionRatio;

    metrics.EstimatedSpaceSaving = ...
        estimatedSpaceSaving;

    metrics.FileBasedSizeRatio = ...
        fileBasedSizeRatio;

    metrics.ImageHeight = rows;

    metrics.ImageWidth = cols;

    metrics.ColorChannels = channels;

end