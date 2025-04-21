function [ypzeros] = besselyPrimeZeros(v, n)
%Gives the first "n" zeros of the "besselyPrime" function.
% Returns a column vector with the first n zeros (y'vn) of the
% "besselyPrime" function.
%
% Example Usage:
%   ypzeros = besselyPrimeZeros(v, n);
%   assert(all(besselyPrime(v, ypzeros) == 0));     % Almost passes.
%
%
% Inputs:
%   v - Bessel function order. See "bessely" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   ypzeros - First "n" zeros of besselyPrime of order "v".
%
% Author: Matt Dvorsky

arguments
    v(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besselyPrime(v, y);

ypzeros = zeros(n, 1);
ypzero0_guess = v + 1.8210980*v.^(1/3) + max(0, 2.19*(1 - v));

for ii = 1:5
    ypzero0_guess = ypzero0_guess ...
        - 2 * besselyPrime(v, ypzero0_guess) ...
        ./ (besselyPrime(v - 1, ypzero0_guess) - besselyPrime(v + 1, ypzero0_guess));
end

assert(abs(besselyPrime(v, ypzero0_guess)) < 1e-10, ...
    "Could not find initial zero.");

ypzeros(1) = ypzero0_guess;
for ii = 2:n
    yp_guess = ypzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(yp_guess))) ~= 0
        yp_guess(2) = 1.1*yp_guess(2) - 0.1*ypzeros(ii - 1);
    end
    ypzeros(ii) = fzero(fun, yp_guess);
end

%% Refine Using Newtons Method
for ii = 1:5
    ypzeros = ypzeros ...
        - 2 * besselyPrime(v, ypzeros) ...
        ./ (besselyPrime(v - 1, ypzeros) - besselyPrime(v + 1, ypzeros));
end

assert(all(abs(besselyPrime(v, ypzeros)) < 1e-10), ...
    "One or more zeros could not be found.");

end

