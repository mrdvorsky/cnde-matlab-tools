% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
nPorts = 2;
nCalMeas = 3;
nMeas = nCalMeas + 10;
nFreqs = 1;
noiseStd = 0;
gam(1, 1, 1, :) = [1, -1, 1j];

%% Generate Calibration Adapter
T = generateCalibrationModel(nPorts, nFreqs);
T(:, :, 4, :) = ones(nPorts, nPorts, 1, nFreqs);

%% Create Calibration Standards
S = eye(nPorts) .* gam;
% S = 0.5*(S + pagetranspose(S));     % Enforce Reciprocity

%% Find Measurements
Sm = applyInverseCalibration(T, S);
Sm = Sm + noiseStd .* rand(size(Sm)) .* exp(2j*pi .* rand(size(Sm)));

%% Test
N = gam(1)*gam(2)*(Sm(:, :, 1) - Sm(:, :, 2)) ...
    + gam(2)*gam(3)*(Sm(:, :, 2) - Sm(:, :, 3)) ...
    + gam(3)*gam(1)*(Sm(:, :, 3) - Sm(:, :, 1));
inv(N)

%% Calibrate
T_meas = solveCalibrationModel(S(:, :, :, 1:nCalMeas), Sm(:, :, :, 1:nCalMeas));

%% Apply Calibration
S_cal = applyCalibration(T_meas, Sm);

rms(S - S_cal, "all")







