function [legPolys] = legendrePolynomials(nMinus1)
%LEGENDREPOLYNOMIALS Computes the legendre polynomials coefficient matrix.
% Output will be a lower triangular matrix of size "nMinus1" square, where
% each row contains the coefficients of a Legendre polynomial of order
% "n - 1". Each row starts with the zeroth order coefficient.
% 
% Author: Matt Dvorsky

arguments
    nMinus1(1, 1) {mustBeInteger, mustBeNonnegative};
end

%% Compute Matrix
legPolys = eye(nMinus1, nMinus1);
for n = 3:nMinus1
    legPolys(n, :) = ...
        ((2*n - 3) ./ (n - 1)) * circshift(legPolys(n - 1, :), 1) ...
        - ((n - 2) ./ (n - 1)) * legPolys(n - 2, :);
end

end

