function [ Tlin, Tcirc, g1, g2 ] = SquareCalGetErrorParams( Sm, d, g1Guess, g2Guess, t15Guess )
%SQUARECALGETERRORPARAMS Calibrate square waveguide
%   Calculate calibration parameters for a 2-port square waveguide. The
%   inputs S and Sm are the actual and measured S-parameters of the square
%   waveguide calibration standards. The last standard, Sm(:, :, end), is
%   unknown except for the conditions S11 = S22 and S21 = S12, and thus
%   S(:, :, end) is not used here. The output parameters g1, g2 are the
%   unknown parameters of this standard (g1 = SVV, g2 = SHH).
%   The input parameters g1Guess, g2Guess should be approximate guesses for
%   the values g1, g2. The parameter tGuess is the guess for the
%   calibration parameter T(2, 1, 4), which is generally close to 0.
%
%   It should be noted that the S-parameters here use a circularly
%   polarized basis, thus the final calibrated square waveguide will have
%   ports corresponding to left-hand and right-hand cirular polarization.
%   Also, the unknown standard should have S21 = S12 = 0 when written in
%   the linear polarization basis, since this becomes S11 = S22, S21 = S12
%   when converted to the circular polarization basis.

%% Check Missing Parameters
if nargin < 3
    g1Guess = 0;
end
if nargin < 4
    g2Guess = 0;
end
if nargin < 5
    t15Guess = 0;
end

%% Setup
numReflects = size(Sm, 3) - 1;
SmLoad = Sm(:, :, end);
% SmRecip = Sm(:, :, end);

%% Calculate Intermediate Matrices Least Squares
A = zeros(4, 12, numReflects);
b = zeros(2, 2, numReflects);
for ii = 1:numReflects
    A(:, 1:4, ii) = d(ii) * eye(4);
    A(:, 5:8, ii) = eye(4);
    A(1:2, 9:10, ii) = -d(ii) * Sm(:, :, ii);
    A(3:4, 11:12, ii) = -d(ii) * Sm(:, :, ii);
    
    b(:, :, ii) = Sm(:, :, ii);
end
c = reshape(reshape(permute(A, [1, 3, 2]), [], 12) \ b(:), 2, 2, 3);

C1 = c(:, :, 1);
C2 = c(:, :, 2);
C3 = c(:, :, 3);

%% Calculate Intermediate Matrices Directly (Old Method)
% Sm1 = Sm(:, :, 1);
% Sm2 = Sm(:, :, 2);
% Sm3 = Sm(:, :, 3);
% 
% d1 = d(1);
% d2 = d(2);
% d3 = d(3);
% 
% A = d1*d2*(Sm1 - Sm2) + d2*d3*(Sm2 - Sm3) + d3*d1*(Sm3 - Sm1);
% B = d1*(Sm2 - Sm3) + d2*(Sm3 - Sm1) + d3*(Sm1 - Sm2);
% C3 = A \ B;
% 
% C1 = ((d1*Sm1 - d2*Sm2)*C3 + Sm1 - Sm2) ./ (d1 - d2);
% C2 = d1*(Sm1*C3 - C1) + Sm1;

%% Calculate T4
C4 = C3;
% C4 = (C1 - SmRecip*C3) \ (SmRecip - C2);

[Q, D] = eig((C1 - SmLoad*C3) \ (SmLoad - C2));
g1 = D(1, 1);
g2 = D(2, 2);
% Swap g1 and g2 if necessary
if (abs(g1 - g1Guess) + abs(g2 - g2Guess)) > (abs(g2 - g1Guess) + abs(g1 - g2Guess))
    g2 = D(1, 1);
    g1 = D(2, 2);
    Q = Q * [0, 1; 1, 0];
end

Q = Q ./ Q(2, 2);
V = Q\C4*Q;
k = [1, -1] * sqrt(V(1, 2) ./ V(2, 1));
[~, kInd] = min(abs(k*Q(2, 1) - t15Guess));

T4 = Q * [k(kInd), 0; 0, 1];

%% Calculate T2,T3,T4
T3 = C3*T4;
T2 = C2*T4;
T1 = C1*T4;

%% Convert to Circular Polarization From Linear
A = [1, 1j; 1, -1j] * sqrt(0.5);
Tcirc = cat(3, T1 * A', T2 * A.', T3 * A', T4 * A.');
Tlin = cat(3, T1, T2, T3, T4);

end




