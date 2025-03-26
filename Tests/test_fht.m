clc;
clear;
close all;

%% Inputs
r(:, 1) = linspace(0.01, 1000, 100001);
k(1, :) = linspace(0.1, 10, 101);

y = 0*r + 10;

%% Hankel Transform
Y = sum(besselj(0, k .* r) .* r .* y, 1) .* abs(r(2) - r(1));

%% Plotting
figure;
plot(r, y, "", LineWidth=1.5);
grid on;

figure;
plot(k, Y, "", LineWidth=1.5);
grid on;





