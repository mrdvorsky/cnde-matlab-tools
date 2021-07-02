function [ Image ] = sar3d( S, x, y, z, f, zx, zy, er, thk )
%SAR3D Formulate Plane Wave SAR image from raw data
%   S -> Raw measurement data at each location and frequency. Should be of
%        size length(x) by length(y) by length(f)
%   x -> Vector of x coordinates (mm)
%   y -> Vector of y coordinates (mm)
%   z -> Vector of desired z coordinates (mm)
%   f -> Vector of freqeuncy coordinates (GHz)
%   zx -> (Optional) Zero pad amount x (percent). Default value is 0.
%   zy -> (Optional) Zero pad amount y (percent). Default value is zy.
%   er -> (Optional) Array of permittivities (real part only) for each
%         layer. Default value is [1];
%   thk -> (Optional) Array of thicknesses  for each layer. Default value
%         is [inf]. The last layer thickness is ignored.

%% Calculate k
if nargin == 5
    zx = 0;
    zy = 0;
elseif nargin == 6
    zy = zx;
end

zx = 2 * round((zx ./ 100) .* length(x));
zy = 2 * round((zy ./ 100) .* length(y));

c = 299.7924499512;
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
Image = Image(1:length(x), 1:length(y), :);

end