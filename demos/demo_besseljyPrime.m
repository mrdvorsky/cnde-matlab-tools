clc;
clear;
close all;

%% Inputs
% Try changing the order below.
besselOrder = 5;
numZeros = 3;


r12 = [1, 4];
rPlot(:, 1) = linspace(0, 5, 1000);

%% Plot
figure;
linePlot = plot(rPlot, zeros(numel(rPlot), numZeros), "", LineWidth=1.5);
ax = gca;
grid on;
ylim([-1.5, 1.5]);

%% Interactive
hold on;
interactiveDots(r12, 0*r12, ...
    {@updateFunction, linePlot, ax, besselOrder, numZeros});


%% Update Function
function [x, y] = updateFunction(x, y, ind, linePlot, axis, besselOrder, numZeros)
    x = max(x, 0.0000001);
    y = 0*y;

    [k, t] = besselCrossPrimeZeros(besselOrder, max(x)./min(x), 1:numZeros);

    for ii = 1:numel(linePlot)
        linePlot(ii).YData = besselCylinder(...
            besselOrder, t(ii), k(ii).*linePlot(ii).XData ./ min(x));
    end

    legend(axis, compose("kc = %.2f", k ./ min(x)));
end


