clc;
clear;
close all;

%% Inputs
N = 15;

x1 = linspace(-1, 1, N) .* (N./(N + 0));
% x1 = fejer2(N, -1, 1);
% x1 = gaussLegendre(N, -1, 1);

xplot = linspace(-1, 1, 1000);
yplot = 0*xplot;

% fitFun = @(x) real(exp(-(10j + 1.5) * x));

% polyfit([])
fitFun = @(x) real(exp(-(10j + 1.5) * x)) + 0.1*exp(-(x - 0.2).^2*1000);
fitFun = @(x) sin(3*pi*x) + 0.1*exp(-(x - 0.2).^2*50);

%% Create Plot
figure;
linePlot = plot(xplot, yplot, "", LineWidth=1.5);
grid on;
hold on;
plot(xplot, fitFun(xplot), ":", LineWidth=1.5);

%% Interactive Plot
hold on;
interactiveDots(x1, fitFun(x1), ...
    {@updatePlot, linePlot}, ...
    MarkerSize=20);




%% Helper
function [xp, yp] = updatePlot(xp, yp, ind, linePlot)
    % p = polyfit(xp, yp, numel(xp) - 1);
    % linePlot.YData = polyval(p, linePlot.XData);

    linePlot.YData = interp1(xp, yp, linePlot.XData, "spline");
end










