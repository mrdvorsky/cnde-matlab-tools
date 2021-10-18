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
    x (:, 1) double;
    y (:, 1) double;
    z (:, 1) double;
    f (:, 1) double;
    options.ZeroPadPercent (1, 1) double = 0;
    options.ZeroPadPercentX (1, 1) double = -1;
    options.ZeroPadPercentY (1, 1) double = -1;
end

if options.ZeroPadPercentX < 0
    options.ZeroPadPercentX = options.ZeroPadPercent;
end

if options.ZeroPadPercentY < 0
    options.ZeroPadPercentY = options.ZeroPadPercent;
end

%% Calculate k
zx = 2 * round((options.ZeroPadPercentX ./ 100) .* length(x));
zy = 2 * round((options.ZeroPadPercentY ./ 100) .* length(y));

c = 299.792458;
k(1, 1, :) = 2*pi*f/c;

dx = x(2) - x(1);
dy = y(2) - y(1);
[iy, ix] = freqspace([zx + size(S, 1); zy + size(S, 2)]);
kx(:, 1, 1) = ifftshift(ix * pi / dx);
ky(1, :, 1) = ifftshift(iy * pi / dy);

%% Compute SAR Algorithm
S = S - mean(mean(S, 1), 2);
WarpedSpectrum = fft2(S, length(kx), length(ky));
WarpedSpectrum(1, 1, :) = 0;

kz = real(sqrt(4*k.^2 - kx.^2 - ky.^2));
WarpedSpectrum(4*k.^2 - kx.^2 - ky.^2 <= 0) = 0;

outSize = size(WarpedSpectrum);
outSize(3) = length(z);
ImageSpectrum = zeros(outSize);
for iz = 1:length(z)
    ImageSpectrum(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(1j .* kz .* abs(z(iz))), 3);
end

Image = ifft2(ImageSpectrum);

%% Crop Output
outSizeCropped = outSize;
outSizeCropped(1:2) = [length(x), length(y)];
Image = reshape(Image(1:length(x), 1:length(y), :), outSizeCropped);

end