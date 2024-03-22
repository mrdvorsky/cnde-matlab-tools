clc;
clear;
% close all;

%% Inputs
% S(1, 1, 1, :) = -exp(0.2j * (0:3));
S(1, 1, 1, :) = -exp(0.5j * (0:2));
% S(1, 1, 1, :) = [-1, exp(0.0j), 0j];
% S(1, 1, 1, :) = -exp(1j * 2*pi/3 * (0:2));
% S(1, 1, 1, :) = -exp(1j * 2*pi/6 * (0:5));


Sm(1, 1, 1, :) = 1.0*S;

nPhi = 20;
nR = 10;

%% Create Plot Info
phiOrig(1, 1, 1, 1, :, :) = exp(1j * linspace(0, 2*pi, 1001).') ...
    .* ((1:nR)./nR);
rOrig(1, 1, 1, 1, :, :) = linspace(0, 1, 1001).' ...
    .* exp(1j * (1:nPhi) ./ nPhi * 2*pi);

%% Get Calibration Function
T = solveCalibrationModel(S, Sm);
phiPlot = squeeze(applyInverseCalibration(T, phiOrig));
rPlot = squeeze(applyInverseCalibration(T, rOrig));

%% Plot
figure;
handle_r = plot(rPlot, "r", LineWidth=0.5);
hold on;
handle_phi = plot(phiPlot, "b", LineWidth=0.5);
zplane([]);
interactivePlot(real(Sm), imag(Sm), ...
    {@updatePlot, S, handle_r, handle_phi, rOrig, phiOrig}, ...
    MarkerSize=20, ...
    DragClampFun=@(x, y) [x, y] ./ max(hypot(x, y), 1));






%% Helper Function
function updatePlot(x, y, S, handle_r, handle_phi, rOrig, phiOrig)
    arguments
        x(1, 1, 1, :);
        y(1, 1, 1, :);
        S(1, 1, 1, :);
        handle_r;
        handle_phi;
        rOrig;
        phiOrig;
    end

    Sm = x + 1j*y;
    T = solveCalibrationModel(S, Sm);
    phiPlot = squeeze(applyInverseCalibration(T, phiOrig));
    rPlot = squeeze(applyInverseCalibration(T, rOrig));

    for rr = 1:numel(handle_r)
        handle_r(rr).XData = real(rPlot(:, rr));
        handle_r(rr).YData = imag(rPlot(:, rr));
    end
    for pp = 1:numel(handle_phi)
        handle_phi(pp).XData = real(phiPlot(:, pp));
        handle_phi(pp).YData = imag(phiPlot(:, pp));
    end
end



