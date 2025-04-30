function [ Img, Img1, Img2, ImgC, ImgS, ImgCC, ImgSS ] = sar3dRadialElevationScattering( S, x, y, z, f, zx, zy )
%SAR3DRADIAL Generate polarized images from radial sar data
%   S -> Raw Data
%   x -> x coordinates
%   y -> y coordinates
%   z -> Desired z coordinates
%   f -> Freqeuncy coordinates
%   zx -> (Optional) Zero pad amount x (percent)
%   zy -> (Optional) Zero pad amount y (percent)
%
%   Img -> SAR image generated using standard SAR algorithm. This image
%       represents the circularly polarized cross-pol image.
%   ImgL -> Like-pol left-hand circularly polarized SAR image
%   ImgR -> Like-pol right-hand circularly polarized SAR image
%   ImgAng (Optional) -> Image showing magnitude (gamma) and orientation
%       (theta). Represented as abs(Img) .* exp(2j .* theta).

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

phi = atan2(ky, kx);
theta = atan2(hypot(kx, ky), kz);

outSize = size(WarpedSpectrum);
outSize(3) = length(z);
ImageSpectrum = zeros(outSize);
ImageSpectrum1 = zeros(outSize);
ImageSpectrum2 = zeros(outSize);
ImageSpectrumC = zeros(outSize);
ImageSpectrumS = zeros(outSize);
ImageSpectrumCC = zeros(outSize);
ImageSpectrumSS = zeros(outSize);
for iz = 1:length(z)
    ImageSpectrum(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)), 3);
    ImageSpectrum1(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)) .* sin(theta).^2, 3);
    ImageSpectrum2(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)) .* cos(theta).^2, 3);
    ImageSpectrumC(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)) .* cos(phi) .* 0.5.*sin(2*theta), 3);
    ImageSpectrumS(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)) .* sin(phi) .* 0.5.*sin(2*theta), 3);
    ImageSpectrumCC(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)) .* cos(2*phi) .* sin(theta).^2, 3);
    ImageSpectrumSS(:, :, iz, :) = sum(WarpedSpectrum ...
        .* exp(-1j .* kz .* z(iz)) .* sin(2*phi) .* sin(theta).^2, 3);
end

Img = 1j .* ifft2(ImageSpectrum);
Img1 = 1j .* ifft2(ImageSpectrum1);
Img2 = 1j .* ifft2(ImageSpectrum2);
ImgC = 1j .* ifft2(ImageSpectrumC);
ImgS = 1j .* ifft2(ImageSpectrumS);
ImgCC = 1j .* ifft2(ImageSpectrumCC);
ImgSS = 1j .* ifft2(ImageSpectrumSS);

Img = Img(1:length(x), 1:length(y), :);
Img1 = Img1(1:length(x), 1:length(y), :);
Img2 = Img2(1:length(x), 1:length(y), :);
ImgC = ImgC(1:length(x), 1:length(y), :);
ImgS = ImgS(1:length(x), 1:length(y), :);
ImgCC = ImgCC(1:length(x), 1:length(y), :);
ImgSS = ImgSS(1:length(x), 1:length(y), :);

%% Normalize
% imgMax = max(abs(Img(:)));
% Img = Img ./ imgMax;
% Img1 = Img1 ./ imgMax;
% Img2 = Img2 ./ imgMax;
% ImgC = ImgC ./ imgMax;
% ImgS = ImgS ./ imgMax;
% ImgCC = ImgCC ./ imgMax;
% ImgSS = ImgSS ./ imgMax;

end