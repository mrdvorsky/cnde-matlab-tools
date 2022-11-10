function [ T, err ] = NPortCalGetErrorParams( Sm, S )
%NPORTCALGETERRORPARAMS Find error adapter for non-ideal network analyzer
%   The error adapter (T) for a non-ideal network analyzer is found using
%   the measured S-parameters (Sm) along with the corresponding known 
%   standards (S). For an N-port device, the size of Sm and S should be
%   N-by-N-by-C, where C is the number of calibration standards measured.
%   T is N-by-N-by-4 and represents the four parameters in the equation
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0. T can be used to find the actual
%   S-parameters using the following equation.
%   S = (T1 - Sm*T3)\(Sm*T4 - T2)

inputSize = size(Sm);
N = inputSize(1);
numCals = inputSize(3);
equations = zeros(numCals .* N.^2, 4 .* N.^2);

% Build equations to describe T
for ii = 1:N
    for jj = 1:N
        for cc = 1:numCals
            Teq = zeros(N, N, 4);
            
            Teq(ii, :, 1) = S(:, jj, cc);
            Teq(ii, jj, 2) = 1;
            Teq(:, :, 3) = -(Sm(ii, :, cc) .* S(:, jj, cc)).';
            Teq(:, jj, 4) = -Sm(ii, :, cc);
            
            eqIndex = ii + N .* (jj - 1 + N .* (cc - 1));
            equations(eqIndex, :) = Teq(:);
        end
    end
end

% Get T from equations
[~, ~, V] = svd(equations);
T = V(:, end); % Solution to the homogeneous least squares problem (Ax=0)

T = reshape(T, [N, N, 4]);
err = equations * T(:);

end

