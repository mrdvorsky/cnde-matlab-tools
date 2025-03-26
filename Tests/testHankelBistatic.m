clc;
clear;
close all;

%% Inputs
dx = 0.25;
dy = 0.25;

x(:, 1, 1) = -20:dx:20;
y(1, :, 1) = -20:dy:20;
k = (1);
z0 = -10;

%% Calculate Bistatic Spectrum
[kx, ky] = fftCoordinates(x, y);

kzPrimeFun = @(kp) conj(sqrt(1 - (kp./k).^2));
biSpecFun = @(kp) exp(1j*deg2rad(-90)) * exp(-1j .* abs(z0) .* k .* kzPrimeFun(kp)) ./ kzPrimeFun(kp);

% kzPrimeFun = @(kp) conj(sqrt(1 - (0.5*kp./k).^2));
% biSpecFun = @(kp) exp(1j*deg2rad(-90)) * exp(-1j .* abs(z0) .* k .* kzPrimeFun(kp));

specBi = biSpecFun(hypot(kx, ky));

%% Calculate Bistatic 
[greenRho, rho] = hankelTransform(biSpecFun, 30, 100000);

greenInterp = griddedInterpolant(rho, greenRho, "spline", "nearest");
greenMono = greenInterp(hypot(x, y)).^2;

%% Calculate Mono Spec
monoSpec1 = fft2(greenMono);
monoSpec2 = ifft2(greenMono);

%% Plotting
figure;
plot(rho, rad2deg(angle(greenRho)), "", LineWidth=1.5);
xlim([0, 10]);

figure;
plot(rho, abs(greenRho), "", LineWidth=1.5);
xlim([0, 10]);

figure;
showImage(fftshift(kx), fftshift(ky), (greenMono), DisplayFormat="Magnitude");
clim([0, inf]);

figure;
showImage(fftshift(kx), fftshift(ky), ifft2(specBi), DisplayFormat="Magnitude");
clim([0, inf]);






