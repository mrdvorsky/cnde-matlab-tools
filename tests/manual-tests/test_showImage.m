clc;
clear;
close all;

%% Inputs
x(:, 1) = 15 * linspace(-1, 1, 350);
y(1, :) = 10 * linspace(-1, 1, 250);

%% Calculate Image
r = hypot(x, y);
phi = atan2(y, x);

Img = besselh(1, 2, r) .* cos(phi - pi/4) .* (r > 1);

%% Plotting
figure;
[~, updateFun] = showImage(x, y, Img, DisplayFormat="Magnitude");

pause(5);
updateFun(conj(Img));
