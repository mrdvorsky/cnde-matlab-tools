function [ Image ] = sar3dSlow( S, x, y, z, f, zx, zy )
%SAR3D Formulate Plane Wave SAR image from raw data
%   S -> Raw Data
%   x -> x coordinates
%   y -> y coordinates
%   z -> Desired z coordinates
%   f -> Freqeuncy coordinates
%   zx -> (Optional) Zero pad amount x (percent)
%   zy -> (Optional) Zero pad amount y (percent)

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

kz = sqrt(4*k.^2 - kx.^2 - ky.^2);
WarpedSpectrum(imag(kz) ~= 0) = 0;
kz = real(kz);

outSize = size(WarpedSpectrum);
outSize(3) = length(z);
ImageSpectrum = zeros(outSize);
for iz = 1:length(z)
    ImageSpectrum(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)), 3);
end

Image = ifft2(ImageSpectrum);
Image = Image(1:length(x), 1:length(y), :);

end