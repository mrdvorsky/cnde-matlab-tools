% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
nPorts = 2;
nCalMeas = 4;
nMeas = nCalMeas + 10;
nFreqs = 1;
noiseStd = 0;
% gam(1, 1, 1, :) = [1, -1, 1j];

%% Generate Calibration Adapter
T = generateCalibrationModel(nPorts, nFreqs, IsLeaky=true, IsReciprocal=true);

%% Create Calibration Standards
S = rand(nPorts, nPorts, nFreqs, nMeas) ...
    .* exp(1j .* rand(nPorts, nPorts, nFreqs, nMeas));
% S = cat(4, [1, 0; 0, 1], [1j, 0; 0, 1j], [-1, 0; 0, -1])
S = 0.5*(S + pagetranspose(S));     % Enforce Reciprocity

%% Find Measurements
Sm = applyInverseCalibration(T, S);
Sm = Sm + noiseStd .* rand(size(Sm)) .* exp(2j*pi .* rand(size(Sm)));

%% Calibrate
[T_meas, A] = solveCalibrationModel(S(:, :, :, 1:nCalMeas), ...
    Sm(:, :, :, 1:nCalMeas));

%% Test
K = A(:, 1:3*nPorts.^2) \ -A(:, 3*nPorts.^2 + 1:end);
K1 = (K(1:nPorts.^2, :));

H1 = [...
    11, 12, 31, 32; ...
    21, 22, 41, 42; ...
    13, 14, 33, 34; ...
    23, 24, 43, 44];
H1p = reshape(permute(reshape(H1, 2, 2, 2, 2), [3, 2, 1, 4]), 4, 4)

for p = perms(1:4).'
    K1p = reshape(permute(reshape(K1, 2, 2, 2, 2), p), 4, 4);
    svd(K1p)
end
% K1p = reshape(permute(reshape(K1, 2, 2, 2, 2), [3, 2, 1, 4]), 4, 4);
abs(K)

%% Apply Calibration
S_cal = applyCalibration(T_meas, Sm);

rms(S - S_cal, "all")







