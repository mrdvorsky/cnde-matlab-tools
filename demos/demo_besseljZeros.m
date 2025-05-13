clc;
clear;
close all;

%% Inputs
v(1, :) = [0, 1, 5, 0.5];
n(:, 1) = 1:10;

xPlot(:, 1) = linspace(0, 25, 1000);

%% Calculate Zeros
% The bessel{j,y,j',y'}Zeros functions calculate the zeros of the bessel
% functions such that the following equations are true.
%
% $$J_v(j_{vn}) = 0$$
%
% $$Y_v(y_{vn}) = 0$$
%
% $$J^{'}_v(j^{'}_{vn}) = 0$$
%
% $$Y^{'}_v(y^{'}_{vn}) = 0$$
%

jvn = besseljZeros(v, n);
jpvn = besseljPrimeZeros(v, n);
yvn = besselyZeros(v, n);
ypvn = besselyPrimeZeros(v, n);

%% Calculate Bessel Function
jPlot = besselj(v + 0*xPlot, xPlot + 0*v);
yPlot = bessely(v + 0*xPlot, xPlot + 0*v);

jvnY = besselj(v + 0*jvn, jvn);
jpvnY = besselj(v + 0*jpvn, jpvn);
yvnY = bessely(v + 0*yvn, yvn);
ypvnY = bessely(v + 0*ypvn, ypvn);

for vv = 1:numel(v)
    figure;
    plot(xPlot, jPlot(:, vv), "", LineWidth=1.5, DisplayName="J_v(x)");
    hold on;
    plot(xPlot, yPlot(:, vv), "", LineWidth=1.5, DisplayName="Y_v(x)");
    xlim([0, max(xPlot)]);
    ylim([-1, 1]);


    plot(jvn(:, vv), jvnY(:, vv), ".k", MarkerSize=15, DisplayName="Zeros");
    plot(jpvn(:, vv), jpvnY(:, vv), "ok", MarkerSize=5, DisplayName="Stationary Points");

    plot(yvn(:, vv), yvnY(:, vv), ".k", MarkerSize=15, HandleVisibility="off");
    plot(ypvn(:, vv), ypvnY(:, vv), "ok", MarkerSize=5, HandleVisibility="off");

    grid on;
    title(sprintf("v = %g", v(vv)));
    legend();
end



