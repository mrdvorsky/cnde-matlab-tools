clc;
clear;
close all;

%% Inputs
x(:, 1) = 15 * linspace(-1, 1, 700);
y(1, :) = 10 * linspace(-1, 1, 500);

%% Calculate Image
r = hypot(x, y);
phi = atan2(y, x);

Img = besselh(1, 2, r) .* cos(phi - pi/4) .* (r > 1);

%% Plotting
figure;
showImage(x, y, Img, DisplayFormat="Magnitude");


