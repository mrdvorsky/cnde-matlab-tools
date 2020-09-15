function [ T, err ] = NPortCalGetErrorParamsReciprocal( Sm, S, tGuess )
%NPORTCALGETERRORPARAMS Find error adapter for non-ideal network analyzer
%   The error adapter (T) for a non-ideal network analyzer is found using
%   the measured S-parameters (Sm) along with the corresponding known 
%   standards (S). For an N-port device, the size of Sm and S should be
%   N-by-N-by-C, where C is the number of calibration standards measured.
%   T is N-by-N-by-4 and represents the four parameters in the equation
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0. T can be used to find the actual
%   S-parameters using the following equation.
%   S = (T1 - Sm*T3)\(Sm*T4 - T2)
%
%   !!!! Currently this is only implemented for a 2-port network !!!!

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
            Teq = permute(Teq, [2, 1, 3]);
            equations(eqIndex, :) = Teq(:);
        end
    end
end

M = -equations(:, 1:14) \ equations(:, 15);
N = -equations(:, 1:14) \ equations(:, 16);

a = M(5)*M(11) + M(6)*M(12) - M(1);
b = N(5)*M(11) + M(5)*N(11) + N(6)*M(12) + M(6)*N(12) - N(1) - M(2);
c = N(5)*N(11) + N(6)*N(12) - N(2);

r = roots([a, b, c]);
[minR, minIndex] = min(r - tGuess);
T = M*r(minIndex) + N;
T = [T; r(minIndex); 1];

t16p = (T(13)*T(16) - T(14)*T(15))*T(1) ...
    - (T(5)*T(16) - T(6)*T(15))*T(9) ...
    - (T(6)*T(13) - T(5)*T(14))*T(11);
k = sqrt(t16p ./ T(16));

T = reshape(T, [2, 2, 4]);
err = equations * T(:);
T = T .* k;
T = permute(T, [2, 1, 3]);

end

