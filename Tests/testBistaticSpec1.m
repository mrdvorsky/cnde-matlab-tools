clc;
clear;
close all;

%% Inputs
dx = 0.25;
dy = dx;

x(:, 1, 1) = -800:dx:800;
y(:, 1, 1) = -800:dy:800;

c = 299.792468;
f = c;

z0 = -50;
biX = 0;

%% Create SAR Data
S = createSarData3d(x, y, f, 0, 0, z0, 1, BistaticSeparationX=biX, ...
    Er=[1, 10], Thk=[0.01, inf]);

%% Perform FFT
[iy, ix] = freqspace([size(S, 1); size(S, 2)]);
kx(:, 1, 1) = (ix * pi / dx);
ky(1, :, 1) = (iy * pi / dy);

S_spec = fft2(S);

S_spec = ifft2(fft2(S_spec).^2);

S_spec = fftshift(S_spec);

k = 2*pi * f ./ c;
% S_spec = 1./S_spec;
% S_spec(hypot(kx, ky) > (2*k)) = 0;

kxp = kx ./ k;

%% Fit
fit_kxp = kxp;
fit_spec = abs(S_spec(kx == 0, :));

%% Plot Spectrum
figure;
showImage(kx, ky, S_spec, DisplayFormat="Magnitude");
colormap jet;

figure;
plot(kxp, abs(S_spec(kx == 0, :)), "", Linewidth=1.5);




