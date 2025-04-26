clc;
clear;
close all;

%% Inputs
r12 = [1, 4];

rPlot(:, 1) = linspace(0, 5, 1000);

besselOrder = 1;
numZeros = 3;

%% Plot
figure;
linePlot = plot(rPlot, 0*rPlot + 0*(1:numZeros), "", LineWidth=1.5);
ax = gca;
grid on;
ylim([-1.5, 1.5]);

%% Interactive
hold on;
interactiveDots(r12, 0*r12, ...
    {@updateFunction, linePlot, ax, besselOrder, numZeros});


%% Update Function
function [x, y] = updateFunction(x, y, ind, linePlot, axes, besselOrder, numZeros)
    y = 0*y;

    [k, t] = besselCrossZeros(besselOrder, max(x)./min(x), 1:numZeros);

    for ii = 1:numel(linePlot)
        linePlot(ii).YData = besselCylinder(...
            besselOrder, t(ii), k(ii).*linePlot(ii).XData ./ min(x));
    end

    legend(axes, compose("kc = %.2f", k));
end


