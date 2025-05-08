clc;
clear;
close all;

%% Inputs
x(:, 1) = linspace(0, 1, 1000);
numLines = 20;

%% Create Data
y_noise1 = (0.2*x + 0.02) .* (rand(numel(x), numLines) - 0.5);
y_noise1 = convn(y_noise1, kaiser(50, 10)/5, "same");

y1 = 0.1 + 0.9*x.^2 ...
    + y_noise1;

y_noise2 = (0.2*x + 0.02) .* (rand(numel(x), numLines) - 0.5);
y_noise2 = convn(y_noise2, kaiser(50, 10)/5, "same");

y2 = 0.3 + 0.5*x.^2 ...
    + y_noise2;

%% Plot
figure;
plotWithShadedBounds(x, mean(y1, 2), ...
    min(y1, [], 2), max(y1, [], 2), ...
    "", ...
    LineWidth=1.5, ...
    DisplayName="y_1");

hold on;
plotWithShadedBounds(x, mean(y2, 2), ...
    min(y2, [], 2), max(y2, [], 2), ...
    ":", ...
    LineWidth=1.5, ...
    DisplayName="y_2");

legend(Location="northwest");
grid on;



