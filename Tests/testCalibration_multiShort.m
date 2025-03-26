% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
k(1, 1, :) = linspace(1.2, 1.8, 21);
kc = 1;

shortLengths(1, 1, 1, :) = 1*[0.1, 0.2, 0.3];
shortLengthsGuess = 0.0 + shortLengths;

%% Calculate Measurements
T = generateCalibrationModel(1, numel(k));
gam = exp(-2j .* sqrt(k.^2 - kc.^2) .* shortLengths);

gamMeas = applyInverseCalibration(T, gam);

%% Calibrate
for kk = 1:numel(k)
    Tp(:, :, :, kk) = NPortCalGetErrorParams(...
        reshape(gamMeas(:, :, kk, :), 1, 1, []), ...
        reshape(gam(:, :, kk, :), 1, 1, []));
end

Tp = solveCalibrationModel(gam, gamMeas);

gamCal = applyCalibration(Tp, gamMeas);

%% Plot
figure;
plots(k, rad2deg(angle(gam)), "", Linewidth=1.5);
hold on;
plots(k, rad2deg(angle(gamCal)), ":", Linewidth=1.5);
xlim([min(k), max(k)]);
grid on;






