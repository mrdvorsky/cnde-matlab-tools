function [T] = generateCalibrationModel(numPorts, numFreqs, options)
%Generates a random n-port calibration adapter.
% Generates a T-parameter calibration adapter for an n-port network
% analyzer. The output T represents the four T-parameter matrices used in
% the following calibration equations, where T(:, :, ii, ...) is the matrix
% T_{ii}, Sm is the measured S-parameter matrix, and S is the actual.
%
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0
%   S = (T1 - Sm*T3)\(Sm*T4 - T2)
%   Sm = (T1*S + T2)/(T3*S + T4)
%
% Example Usage:
%   [T] = randomCalibrationModel(numPorts);
%   [T] = randomCalibrationModel(numPorts, numFreqs);
%   S = applyCalibration(T, Sm);
%   Sm = applyInverseCalibration(T, S);
%
%
% Inputs:
%   numPorts - Number of network analyzer ports.
%   numFreqs (1) - Number of frequencies. A calibration adapter will
%       be generated for each frequency.
%
% Outputs:
%   T - Calibration adapter of size (numPorts, numPorts, 4, numFreqs).
%
% Named Arguments:
%   IsReciprocal (false) - If true, the resulting network will be
%       reciprocal.
%   IsLeaky (false) - If true, the coupling terms between ports will be
%       non-zero.
%
% Author: Matt Dvorsky

arguments
    numPorts(1, 1) {mustBePositive, mustBeInteger};
    numFreqs(1, 1) {mustBePositive, mustBeInteger} = 1;
    options.IsReciprocal(1, 1) logical = false;
    options.IsLeaky(1, 1) logical = false;
end

%% Generate S-parameter Model
isDiagonal = repmat(diag(zeros(numPorts, 1) == 0), [1, 1, 4, numFreqs]);
isNonDiagonal = ~isDiagonal;

S_data = (0.5 + 0.5*rand(numPorts, numPorts, 4, numFreqs)) .* ...
    exp(2j*pi .* rand(numPorts, numPorts, 4, numFreqs));

if options.IsReciprocal
    S_data(:, :, 1, :) = 0.5*(S_data(:, :, 1, :) ...
        + pagetranspose(S_data(:, :, 1, :)));
    S_data(:, :, 2, :) = pagetranspose(S_data(:, :, 3, :));
    S_data(:, :, 4, :) = 0.5*(S_data(:, :, 4, :) ...
        + pagetranspose(S_data(:, :, 4, :)));
end

S = S_data .* isDiagonal;
S(:, :, [2, 3], :) = 0.2 * S(:, :, [2, 3], :);
if options.IsLeaky
    S = S + S_data .* isNonDiagonal .* 0.2;
end

%% Calculate T-parameters from S-parameters
T = zeros(size(S));
T(:, :, 1, :) =  S(:, :, 2, :) - pagemtimes(...
    pagemrdivide(S(:, :, 1, :), S(:, :, 3, :)), ...
    S(:, :, 4, :));
T(:, :, 2, :) =  pagemrdivide(S(:, :, 1, :), S(:, :, 3, :));
T(:, :, 3, :) = -pagemldivide(S(:, :, 3, :), S(:, :, 4, :));
T(:, :, 4, :) =  pageinv(S(:, :, 3, :));

end

