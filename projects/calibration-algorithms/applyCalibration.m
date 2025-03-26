function [S] = applyCalibration(T, Sm)
%APPLYCALIBRATION Calibrate measurements from n-port non-ideal network analyzer.
% The error adapter (T) for a non-ideal network analyzer is removed from
% the measured S-parameters (Sm) to give the actual S-parameters (S).
% The input T represents the four T-parameter matrices used in the
% following calibration equations, where T(:, :, ii, ...) is the matrix
% T_{ii}, Sm is the measured S-parameter matrix, and S is the actual.
%
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0
%   S = (T1 - Sm*T3)\(Sm*T4 - T2)
%   Sm = (T1*S + T2)/(T3*S + T4)
%
% Example Usage:
%   S = applyCalibration(T, Sm);
%
% Inputs:
%   T - Calibration adapter with size (nPorts, nPorts, 4, nFreqs).
%   Sm - Measured S-parameter matrix(es) with size (nPorts, nPorts,
%       nFreqs, ...) or (nPorts, nPorts, 1, nFreqs, ...).
%
% Outputs:
%   S - S-parameter matrix(es) with the same size as Sm.
%
% Author: Matt Dvorsky

arguments
    T(:, :, 4, :) {mustBeNumeric};
    Sm {mustBeNumeric};
end

%% Check Arguments
nPorts = size(T, 1);
nFreqs = size(T, 4);

if size(T, 2) ~= nPorts
    error("Argument 'T' must have size (nPorts, nPorts, 4, nFreqs).");
end

if (size(Sm, 3) ~= nFreqs && (size(Sm, 4) ~= nFreqs || size(Sm, 3) ~= 1)) ...
        || (size(Sm, 1) ~= nPorts || size(Sm, 2) ~= nPorts)
    error("Argument 'Sm' must have size (nPorts, nPorts, nFreqs, ...) " + ...
        "or (nPorts, nPorts, 1, nFreqs, ...).");
end

%% Apply Calibration
outSize = size(Sm);
Sm = reshape(Sm, nPorts, nPorts, 1, nFreqs, []);
S = reshape(pagemldivide(T(:, :, 1, :) - pagemtimes(Sm, T(:, :, 3, :)), ...
    pagemtimes(Sm, T(:, :, 4, :)) - T(:, :, 2, :)), outSize);

end


