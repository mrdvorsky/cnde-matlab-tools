clc;
clear;
close all;

%% Inputs
f = linspace(8.2, 12.4, 1000);

%% Create Data
v1 = (f - 9) .* exp(-0.5j .* f) ./ 15;
v2 = f .* exp(-0.3j .* (f + pi)) ./ 19;

%% Plotting
figure;
plotComplex(f, v1, "", LineWidth=1.5, DisplayFormat="dB");
hold on;
plotComplex(f, v2, "", LineWidth=1.5, DisplayFormat="dB");
grid on;