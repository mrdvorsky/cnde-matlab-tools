clc;
clear;
close all;

%% Inputs
f = linspace(8.2, 12.4, 1000);

% Whether or not to create a second axis with priority, to test whether
% the "Axis" input can properly target non-active axes.
createUnusedFigureForTesting = true;

%% Create Data
v1 = (f - 9 + 0.2j) .* exp(-0.5j .* f) ./ 15;
v2 = f .* exp(-0.3j .* (f + pi)) ./ 19;

%% Plotting
figure;
ax = gca();

% Test if the "Axis" input works properly by creating a new axis.
if createUnusedFigureForTesting
    figure;
    axUnused = gca();
end

plotComplex(f, v1, "", LineWidth=1.5, DisplayFormat="Polar", Axis=ax);
hold(ax, "on");
plotComplex(f, v2, "", LineWidth=1.5, DisplayFormat="Polar", Axis=ax);
grid(ax, "on");


