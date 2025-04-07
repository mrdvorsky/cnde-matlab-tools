function [T] = solveCalibrationModel(S, Sm)
%Solve calibration model for n-port network analyzer from calibration measurements.
% The 'error adapter' (T) for a non-ideal network analyzer is found given
% n-port measurements (Sm) of multiple calibration standards (S). The
% measured S-parameters (Sm) and actual S-parameters (S) are related to
% the calibration model by the equations below. The output (T) represents
% the four T-parameter matrices used in the following calibration
% equations, where T(:, :, ii, ...) is the matrix T_{ii}.
%
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0
%   S = (T1 - Sm*T3)\(Sm*T4 - T2)
%   Sm = (T1*S + T2)/(T3*S + T4)
%
% Note that the number of measurements of calibration standards required
% to solve the calibration equation calibrate depends other whether or not
% leaky model is used. Typically (3) n-port measurements are required for
% the non-leaky case, and (5) are required for the leaky case, regardless
% of the number of ports.
%
% Example Usage:
%   T = solveCalibrationModel(S, Sm);
%   S_other = applyCalibration(T, Sm_other);
%
%
% Inputs:
%   S - S-parameter matrices of the calibration standards with size
%       (nPorts, nPorts, nFreqs, nStandards).
%   Sm - Measured S-parameter matrices with the same size as 'S'.
%
% Outputs:
%   T - Calibration adapter with size (nPorts, nPorts, 4, nFreqs).
%
% Author: Matt Dvorsky

arguments
    S;
    Sm {mustHaveEqualSizes(S, Sm)};
end

%% Check Inputs
nPorts = size(S, 1);
nFreqs = size(S, 3);
if size(S, 2) ~= nPorts
    error("Argument 'S' and 'Sm' must have size " + ...
        "(nPorts, nPorts, nFreqs, nStandards).");
end

%% Build System of Equations for T1...T4 into the Matrix Form Ax=0
% Reshape inputs for easier matrix manipulation.
eyeN1 = eye(nPorts, nPorts);
eyeN2 = reshape(eyeN1, [1, 1, nPorts, nPorts]);
S = reshape(pagetranspose(S), [1, 1, size(S, 1:4)]);
Sm = reshape(pagetranspose(-Sm), [size(Sm, 1:2), 1, 1, size(Sm, 3:4)]);

% Put equations in correct form.
T1 = permute(eyeN1 .* S,     [2, 3, 1, 4, 5, 6]);
T2 = permute(eyeN1 .* eyeN2, [2, 3, 1, 4, 5, 6]);
T3 = permute(Sm    .* S,     [2, 3, 1, 4, 5, 6]);
T4 = permute(Sm    .* eyeN2, [2, 3, 1, 4, 5, 6]);

% Reshape into final matrix equation Ax=0.
[T1, T2, T3, T4] = broadcastArrays(T1, T2, T3, T4);
A = reshape(permute(cat(4, T1, T2, T3, T4), [1, 2, 6, 3, 4, 5]), ...
    [], 4*nPorts.^2, nFreqs);

%% Solve Matrix Equation
% [~, ~, V] = pagesvd(A, "vector");
% T = V(:, end, :); % Solution to the homogeneous least squares problem (Ax=0)

T = [pagemldivide(A(:, 1:end-1, :), -A(:, end, :)); ...
    ones(1, 1, size(A, 3))];

T = reshape(T, nPorts, nPorts, 4, nFreqs);

end

