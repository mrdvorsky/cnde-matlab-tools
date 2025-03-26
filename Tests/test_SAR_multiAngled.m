clc;
clear;
close all;

%% Inputs
x(:, 1, 1) = -20:0.05:20;
y(1, :, 1) = -20:0.05:20;
z(1, 1, :) = -(0:0.05:20);

x0 = 0;
y0 = 0;
z0 = -10;

xg = 10;
yg = 0;
rg = 5;

k = 2*pi;

%% Create Data
R = hypot(hypot(x - x0, y - y0), z0);
S = (exp(-1j .* k .* R) ./ R).^2;
S = S .* exp(-(hypot(x - xg, y - yg) ./ rg).^2);

%% Create Focus
Img = sar3d(S, x, y, z, 299.79, ZeroPadPercent=25);

%% Plotting
figure;
showImage(x, z, Img(:, y == 0, :), DisplayFormat="MagPhase");

figure;
showImage(x, z, Img(:, y == 0, :), DisplayFormat="Magnitude");












