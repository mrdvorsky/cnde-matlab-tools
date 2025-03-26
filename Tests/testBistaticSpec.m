clc;
clear;
close all;

%% Inputs
dx = 1;
dy = dx;

x(:, 1, 1) = -200:dx:200;
y(:, 1, 1) = -200:dy:200;

c = 299.792468;
f = 30;

z0 = -50;
biX = 50;

%% Create SAR Data
S = createSarData3d(x, y, f, 0, 0, z0, 1, BistaticSeparationX=biX);

%% Perform FFT
[iy, ix] = freqspace([size(S, 1); size(S, 2)]);
kx(:, 1, 1) = (ix * pi / dx);
ky(1, :, 1) = (iy * pi / dy);

S_spec = fftshift(fft2(S));

k = 2*pi * f ./ c;
% S_spec = 1./S_spec;
% S_spec(hypot(kx, ky) > (2*k)) = 0;

%% Plot Spectrum
figure;
showImage(kx, ky, S_spec, DisplayFormat="Magnitude");
colormap jet;




