function [Image] = sar3d(S, x, y, z, f, options)
%SAR3D Formulate Plane Wave SAR image from raw data
%   Usage:
%       Img = sar3d(S, x, y, z, f);
%       Img = sar3d(S, x, y, z, f, ZeroPadPercent=25);
%       Img = sar3d(S, x, y, z, f, ZeroPadPercentX=25, ZeroPadPercentY=0);
%       Img = sar3d(S, x, y, z, f, er=[2, 3], thk=[10, inf]); % Not implemented
%
%   S -> Raw measurement data at each location and frequency. Should be of
%        size length(x) by length(y) by length(f)
%   x -> Vector of x coordinates (mm)
%   y -> Vector of y coordinates (mm)
%   z -> Vector of desired z coordinates (mm)
%   f -> Vector of freqeuncy coordinates (GHz)

%% Check Inputs
arguments
    S double;
    x(:, 1) double;
    y(:, 1) double;
    z(:, 1) double;
    f(:, 1) double;
    options.ZeroPadPercent(1, 1) double = 0;
    options.ZeroPadPercentX(1, 1) double = -1;
    options.ZeroPadPercentY(1, 1) double = -1;
    options.RemoveAverage(1, 1) {mustBeNumericOrLogical} = true;
    options.SpeedOfLight(1, 1) {mustBePositive} = 299.792458;
    options.Er(:, 1) {mustBeGreaterThanOrEqual(options.Er, 1)} = 1;
    options.Thk(:, 1) {mustBePositive} = inf;
end

if options.ZeroPadPercentX < 0
    options.ZeroPadPercentX = options.ZeroPadPercent;
end

if options.ZeroPadPercentY < 0
    options.ZeroPadPercentY = options.ZeroPadPercent;
end

%% Check for Argument Size Mismatch
if numel(options.Er) ~= numel(options.Thk)
    error("Er and Thk must have the same length.");
end

%% Calculate Layer Indices
layerIndices = 1 + sum(cumsum(abs(options.Thk.')) < abs(z), 2);
zLayerStart = [0; cumsum(options.Thk(1:end - 1))];  % Start of each layer

%% Remove Average over Frequency
if options.RemoveAverage
    S = S - mean(mean(S, 1), 2);
end

%% Calculate Wavenumbers
zx = 2 * round((options.ZeroPadPercentX ./ 100) .* length(x));
zy = 2 * round((options.ZeroPadPercentY ./ 100) .* length(y));

k0(1, 1, :) = (2*pi) .*f ./ options.SpeedOfLight;

dx = x(2) - x(1);
dy = y(2) - y(1);
[iy, ix] = freqspace([zx + size(S, 1); zy + size(S, 2)]);
kx(:, 1, 1) = ifftshift(ix * pi / dx);
ky(1, :, 1) = ifftshift(iy * pi / dy);

%% Compute SAR Algorithm
WarpedSpectrum = fft2(S, length(kx), length(ky));

ImageSpectrum = zeros([size(WarpedSpectrum, 1:2), length(z), ...
    size(WarpedSpectrum, 4:max(4, ndims(WarpedSpectrum)))]);

prevLayerMult = 1;
for ii = 1:numel(options.Thk)
    kz = real(sqrt(4*options.Er(ii)*k0.^2 - kx.^2 - ky.^2));
    
    for iz = find(layerIndices == ii).' % Why is the transpose necessary, Matlab??!!!
        ImageSpectrum(:, :, iz, :) = mean(prevLayerMult .* WarpedSpectrum ...
            .* exp(1j .* kz .* (abs(z(iz)) - zLayerStart(ii))), 3);
    end
    
    if ii ~= numel(options.Thk)
        prevLayerMult = prevLayerMult .* exp(1j .* kz .* options.Thk(ii));
    end
end

Image = ifft2(ImageSpectrum);

%% Crop Output
Image = reshape(Image(1:length(x), 1:length(y), :), ...
    [length(x), length(y), size(Image, 3:max(3, ndims(Image)))]);

end