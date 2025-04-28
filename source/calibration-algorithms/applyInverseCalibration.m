function [Sm] = applyInverseCalibration(T, S)
%Invert the calibration for n-port non-ideal network analyzer.
% The error adapter (T) for a non-ideal network analyzer is added to
% the actual S-parameters (S) to give the measured S-parameters (Sm).
% The input T represents the four T-parameter matrices used in the
% following calibration equations, where T(:, :, ii, ...) is the matrix
% T_{ii}, Sm is the measured S-parameter matrix, and S is the actual.
%
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0
%   S = (T1 - Sm*T3)\(Sm*T4 - T2)
%   Sm = (T1*S + T2)/(T3*S + T4)
%
% Example Usage:
%   Sm = applyInverseCalibration(T, S);
%
%
% Inputs:
%   T - Calibration adapter with size (nPorts, nPorts, 4, ...).
%   S - Actual S-parameter matrix(es) with size (nPorts, nPorts,
%       nFreqs, ...) or (nPorts, nPorts, 1, nFreqs, ...).
%
% Outputs:
%   Sm - Measured S-parameter matrix(es) with the same size as S.
%
% Author: Matt Dvorsky

arguments
    T(:, :, 4, :) {mustBeNumeric};
    S {mustBeNumeric};
end

%% Check Arguments
nPorts = size(T, 1);
nFreqs = size(T, 4);

if size(T, 2) ~= nPorts
    error("Argument 'T' must have size (nPorts, nPorts, 4, nFreqs).");
end

if (size(S, 3) ~= nFreqs && (size(S, 4) ~= nFreqs || size(S, 3) ~= 1)) ...
        || (size(S, 1) ~= nPorts || size(S, 2) ~= nPorts)
    error("Argument 'S' must have size (nPorts, nPorts, nFreqs, ...) " + ...
        "or (nPorts, nPorts, 1, nFreqs, ...).");
end

%% Apply Inverse Calibration
outSize = size(S);
S = reshape(S, nPorts, nPorts, 1, nFreqs, []);
Sm = reshape(pagemrdivide(pagemtimes(T(:, :, 1, :), S) + T(:, :, 2, :), ...
    pagemtimes(T(:, :, 3, :), S) + T(:, :, 4, :)), outSize);

end

