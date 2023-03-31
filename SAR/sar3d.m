function [Image] = sar3d(S, x, y, z, f, options)
%SAR3D Calculate SAR image(s) from a uniform 2D scan data set or sets.
% This function returns a 3D complex SAR image given measurement data from
% a 2D frequency-stepped xy-raster scan. Optionally, can process multiple
% data sets having the same dimensions simultaneously.
%
% Example Usage:
%   Img = sar3d(S, x, y, z, f);
%   Img = sar3d(S, x, y, z, f, ZeroPadPercent=25);
%   Img = sar3d(S, x, y, z, f, ZeroPadPercentX=25, ZeroPadPercentY=0);
%   Img = sar3d(S, x, y, z, f, RemoveAverage=false);
%   Img = sar3d(S, x, y, z, f, Er=[2, 3], Thk=[10, inf]);
%
% The output Img will have size length(x) by length(y) by length(z) by ...,
% each value correspoding to the measurement made at the coordinate
% corresponding to the same indices in the inputs x, y, z, with extra
% dimensions (4 and onward) being preserved in the output. Each image
% Img(:, :, :, ii) will be a SAR image of the data S(:, :, :, ii).
%
% The default units are mm and GHz, but this can be changed by specifying
% the speed of light as an optional named parameter.
%
% Inputs:
%   S - Matrix of size length(x) by length(y) by length(f) by ..., each
%       value correspoding to the measurement made at the coordinate and
%       frequency corresponding to the same indices in the inputs x, y, f.
%       The matrix S may have any number of extra dimensions, and each of
%       S(:, :, :, ii) will be treated as an independent data set.
%   x - Vector of sample x-coordinates.
%   y - Vector of sample y-coordinates.
%   z - Vector of desired z-coordinates.
%   f - Vector of sample frequency coordinates.
% Outputs:
%   Img - Matrix of size length(x) by length(y) by length(z) by ..., each
%       value correspoding to the measurement made at the coordinate
%       corresponding to the same indices in the inputs x, y, z. The 4th
%       dimensions and onward will be the same size as the input S.
%       Essentially, Img(:, :, :, ii) will be the SAR image of the data set
%       S(:, :, :, ii).
% Named Arguments:
%   ZeroPadPercent (0) - Amount of zero padding to use on the x- and
%       y-axes. Expressed as a percentage of the input size. For example, a
%       value of 100 will result in the input matrix size being doubled
%       along both the x- and y-axes.
%   ZeroPadPercentX (ZeroPadPercent) - Same as ZeroPadPercent, but
%       specified for the x-axis only.
%   ZeroPadPercentY (ZeroPadPercent) - Same as ZeroPadPercent, but
%       specified for the y-axis only.
%   RemoveAverage (true) - If true, the average value for each xy-slice in
%       the input S will be removed (e.g., S = S - mean(S, [1, 2]);).
%   SpeedOfLight (299.792458) - Value of speed of light to use.
%   Er (1) - Vector of dielectric constants for each layer.
%   Thk (inf) - Vector of thicknesses for each layer. Thk(end) is assumed
%       to be inf (i.e., infinite half-space). Must be same lenth as Er.
%
% Author: Matt Dvorsky

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
    options.RemoveAverage(1, 1) logical = true;
    options.SpeedOfLight(1, 1) {mustBePositive} = 299.792458;
    options.Er(:, 1) {mustBeGreaterThanOrEqual(options.Er, 1)} = 1;
    options.Thk(:, 1) {mustBePositive} = inf;
    options.BistaticSeparationX(1, 1) {mustBeReal} = 0;
    options.BistaticSeparationY(1, 1) {mustBeReal} = 0;
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
zLayerStart = [0; cumsum(options.Thk(1:end - 1))];  % Start of each layer
layerIndices = sum(zLayerStart <= abs(z).', 1);

%% Remove Average over Frequency
if options.RemoveAverage
    S = S - mean(S, [1, 2]);
end

%% Calculate Wavenumbers
zx = round((options.ZeroPadPercentX ./ 100) .* length(x));
zy = round((options.ZeroPadPercentY ./ 100) .* length(y));

k0(1, 1, :) = (2*pi) .* f ./ options.SpeedOfLight;

dx = 1;
if numel(x) > 1
    dx = x(2) - x(1);
end

dy = 1;
if numel(y) > 1
    dy = y(2) - y(1);
end

[iy, ix] = freqspace([zx + size(S, 1); zy + size(S, 2)]);
kx(:, 1, 1) = ifftshift(ix * pi / dx);
ky(1, :, 1) = ifftshift(iy * pi / dy);

%% Compute SAR Algorithm
WarpedSpectrum = (1 ./ k0).^1 .* fft2(S, length(kx), length(ky));

ImageSpectrum = zeros([size(WarpedSpectrum, 1:2), length(z), ...
    size(WarpedSpectrum, 4:max(4, ndims(WarpedSpectrum)))]);

if (options.BistaticSeparationX == 0) && (options.BistaticSeparationY == 0)
    prevLayerMult = 1;
    for ii = 1:numel(options.Thk)
        kz = real(sqrt(4*options.Er(ii)*k0.^2 - kx.^2 - ky.^2));

        % Set evanescent modes to zero
        WarpedSpectrum(kz == 0) = 0;

        for iz = find(layerIndices == ii)
            ImageSpectrum(:, :, iz, :) = abs(z(iz)) .* mean(prevLayerMult .* WarpedSpectrum ...
                .* exp(1j .* kz .* (abs(z(iz)) - zLayerStart(ii))), 3);
        end

        if ii ~= numel(options.Thk)
            prevLayerMult = prevLayerMult .* exp(1j .* kz .* options.Thk(ii));
        end
    end
else
    for ii = 1:numel(options.Thk)
        kz = real(sqrt(4*options.Er(ii)*k0.^2 - kx.^2 - ky.^2));

        % Set evanescent modes to zero
        WarpedSpectrum(kz == 0) = 0;

        for iz = find(layerIndices == ii)
            xPadded = 0.5 * kx .* (numel(kx).*dx.^2 ./ pi);
            yPadded = 0.5 * ky .* (numel(ky).*dy.^2 ./ pi);
            if z(iz) ~= 0
                specPSF = fft2(createSarData3d(xPadded, yPadded, f, 0, 0, z(iz), 1, ...
                    Er=options.Er, Thk=options.Thk, ...
                    BistaticSeparationX=options.BistaticSeparationX, ...
                    BistaticSeparationY=options.BistaticSeparationY));
            else
                specPSF = 0;
            end

            ImageSpectrum(:, :, iz, :) = abs(z(iz)).^2 .* mean(WarpedSpectrum ...
                .* conj(specPSF), 3);
        end
    end
end

Image = ifft2(ImageSpectrum);

%% Crop Output
Image = reshape(Image(1:length(x), 1:length(y), :), ...
    [length(x), length(y), size(Image, 3:max(3, ndims(Image)))]);

end