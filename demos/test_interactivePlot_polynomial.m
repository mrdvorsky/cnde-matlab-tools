clc;
clear;
close all;

%% Inputs
px = [-1, -0.5, 0.5, 1];
py = [1, 2, -1, 1];

%% Set Up Plot As Normal
xplot = linspace(-1, 1, 10000);
yplot = polyval(polyfit(px, py, numel(px) - 1), xplot);

figure;
lineHandle = plot(xplot, yplot, "", LineWidth=1.5);
grid on;

%% Add Interactive Points
hold on;
interactivePlot(px, py, ...
    {@updatePlot, lineHandle}, ...
    MarkerSize=20);




%% Helper Function
function [xp, yp] = updatePlot(xp, yp, ind, lineHandle)
    xplot = lineHandle.XData;
    yplot = polyval(polyfit(xp, yp, numel(xp) - 1), xplot);
    lineHandle.YData = yplot;
end


