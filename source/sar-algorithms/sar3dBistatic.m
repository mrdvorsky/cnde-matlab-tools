function [ Image ] = sar3dBistatic( S, x, y, z, f, rho0, phi0, zx, zy )
%SAR3D Formulate Plane Wave SAR image from raw data
%   S -> Raw Data
%   x -> x coordinates
%   y -> y coordinates
%   z -> Desired z coordinates
%   f -> Freqeuncy coordinates
%   rho0 -> Bistatic distance vector length
%   phi0 -> Bistatic distance vector angle (0 along x, pi/2 along y)
%   zx -> (Optional) Zero pad amount x (percent)
%   zy -> (Optional) Zero pad amount y (percent)

%% Calculate k
if nargin == 7
    zx = 0;
    zy = 0;
elseif nargin == 8
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

%% Compute Bistatic Fit Coefficients
kRhoRel = 0.5 * hypot(kx, ky) ./ k;
kPhi = atan2(ky, kx);
cosPhi = cos(kPhi - phi0).^2;

kz = 2*k .* real(sqrt(1 - kRhoRel.^2));

% y0 = 0.2071 + kRhoRel .* cosPhi .* ...
%     polyval([-1.953e-1, 2.159e-1, 9.954e-2, -3.221e-1, -5.14e-3], kRhoRel);
% y1 = 0.1180 + kRhoRel .* cosPhi .* ...
%     polyval([-5.780e-2, 8.490e-2, -7.424e-3, -1.377e-1, 2.4e-5], kRhoRel);

n = 0.5;
m = 1;

y0 = 0.2071 + kRhoRel .* cosPhi .* (polyval([0.009869, 0.1935, -0.3775, -0.0001588], kRhoRel) ...
    + cosPhi .* polyval([-0.2399, 0.2580, -0.05538, 0.006277], kRhoRel));
y1 = 0.1180 + kRhoRel .* cosPhi .* (polyval([0.01510, 0.01822, -0.1458, 0.0008880 ], kRhoRel) ...
    + cosPhi .* polyval([-0.06594, 0.08463, -0.02745, 0.002715], kRhoRel));

a = 0.5 * (y0.^2 - y1.^2) ./ (m*y1 - n*y0);
a(a < 0) = 0;
b = rho0.^2 .* y0 .* (y0 + 2*a.*n);

a(kRhoRel >= 1) = 0;
b(kRhoRel >= 1) = 0;

%% Compute SAR Algorithm
S = S - mean(mean(S, 1), 2);
WarpedSpectrum = fft2(S, length(kx), length(ky));
WarpedSpectrum(kRhoRel >= 1) = 0;

outSize = size(WarpedSpectrum);
outSize(3) = length(z);
ImageSpectrum = zeros(outSize);
for zz = 1:length(z)
    gam = sqrt((a.*z(zz)).^2 + b) + (1 - a).*abs(z(zz));
    z(zz)
%     surf(0.5*kx./k, 0.5*ky./k, real(gam));
    
    ImageSpectrum(:, :, zz) = sum(WarpedSpectrum ...
        .* exp(1j .* kz .* gam), 3);
end

Image = ifft2(ImageSpectrum);
Image = Image(1:length(x), 1:length(y), :);

end