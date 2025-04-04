function [Image] = sar3d_fast(S, x, y, z, f, options)
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
    options.RemoveAverage(1, 1) logical = true;
    options.SpeedOfLight(1, 1) {mustBePositive} = 299.792458;
end

z = abs(z);
if min(z ~= 0) || ~isuniform(z)
    error("Input 'z' must be a uniform vector ranging from 0 to zMax.");
end

%% Remove Average over Frequency
if options.RemoveAverage
    S = S - mean(S, [1, 2]);
end

%% Calculate Wavenumbers
k0(1, 1, :) = (2*pi) .* f ./ options.SpeedOfLight;

[kx, ky] = fftCoordinates(x, y);
[~, ~, kz] = fftCoordinates(0, 0, [z; z], PositiveOutput=true);

dkz = abs(kz(1) - kz(2));

kr2 = kx.^2 + ky.^2;
kzInd = real(sqrt(4 * k0.^2 - kr2)) ./ dkz + 1;

kzIndMin = floor(kzInd);
kzIndMax = ceil(kzInd);
kzIndFrac = kzInd - kzIndMin;

%% Compute SAR Algorithm
WarpedSpectrum = reshape((1 ./ k0).^1 .* fft2(S, length(kx), length(ky)), ...
    [], numel(k0));

k0_samp = 0.5 * sqrt(kr2 + kz.^2);

mult = kz ./ k0_samp;
mult(k0_samp > max(k0) | k0_samp < min(k0)) = 0;

tic;
kx_samp = cumsum(1 + 0*kx);
ky_samp = cumsum(1 + 0*ky);
ImageSpectrum = mult .* interpn(kx_samp(:), ky_samp(:), k0(:), WarpedSpectrum, ...
    kx_samp + 0*k0_samp, ky_samp + 0*k0_samp, k0_samp, ...
    "linear", 0);
toc;

Image = ifft2(ifft(ImageSpectrum, [], 3)) .* reshape([z; z].^2, 1, 1, []);

%% Crop Output
Image = Image(1:numel(x), 1:numel(y), 1:numel(z));

end