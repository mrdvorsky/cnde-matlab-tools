clc;
clear;
% close all;

%% Inputs
% S = -exp(0.2j * (0:3));
% S = -exp(0.5j * (0:2));
S = [-1, exp(0.0j), 0j, 1j, -1j];
% S = -exp(1j * 2*pi/3 * (0:2));
% S = -exp(1j * 2*pi/6 * (0:5));


Sm = 1*S;

nPhi = 32;
nR = 10;

%% Create Plot Info
pOrig = exp(2j * pi * (1:nPhi)./nPhi).' ...
    .* ((1:nR)./nR);

pOff = getOffsets(pOrig, S, Sm);

%% Plot
figure;
handle_q = quiver(real(pOrig), imag(pOrig), real(pOff), imag(pOff), 0);
hold on;
zplane([]);
interactivePlot(real(Sm), imag(Sm), ...
    {@updatePlot, S, handle_q, pOrig}, ...
    MarkerSize=20, ...
    DragClampFun=@(x, y) [x, y] ./ max(hypot(x, y), 1));






%% Helper Function
function updatePlot(x, y, S, handle_q, pOrig)
    arguments
        x(1, 1, 1, :);
        y(1, 1, 1, :);
        S(1, 1, 1, :);
        handle_q;
        pOrig;
    end
    
    Sm = x + 1j*y;
    pOff = getOffsets(pOrig, S, Sm);

    handle_q.UData = real(pOff);
    handle_q.VData = imag(pOff);
end

function [pointOffsets] = getOffsets(pointsIn, S, Sm)
    arguments
        pointsIn(1, 1, 1, 1, :, :);
        S(1, 1, 1, :);
        Sm(1, 1, 1, :);
    end
    
    T = solveCalibrationModel(S, Sm);
    pointOffsets = squeeze(applyInverseCalibration(T, pointsIn) - pointsIn);
end


