function [ypzeros] = besselyPrimeZeros(nu, n)
%Gives the first "n" zeros of the "besselyPrime" function.
% Returns a column vector with the first n zeros (y'vn) of the
% "besselyprime" function.
%
% Example Usage:
%   ypzeros = besselyPrimeZeros(nu, n);
%   assert(all(besselyPrime(nu, ypzeros) == 0));    % Almost passes.
%
%
% Inputs:
%   nu - Bessel function order. See "bessely" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   ypzeros - First "n" zeros of besselyPrime of order "nu".
%
% Author: Matt Dvorsky

arguments
    nu(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besselyPrime(nu, y);

ypzeros = zeros(n, 1);
ypzero0_guess = nu + 1.8210980*nu.^(1/3) + max(0, 2.19*(1 - nu));

for ii = 1:5
    ypzero0_guess = ypzero0_guess ...
        - 2 * besselyPrime(nu, ypzero0_guess) ...
        ./ (besselyPrime(nu - 1, ypzero0_guess) - besselyPrime(nu + 1, ypzero0_guess));
end

assert(abs(besselyPrime(nu, ypzero0_guess)) < 1e-14, ...
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
        - 2 * besselyPrime(nu, ypzeros) ...
        ./ (besselyPrime(nu - 1, ypzeros) - besselyPrime(nu + 1, ypzeros));
end

assert(all(abs(besselyPrime(nu, ypzeros)) < 1e-13), ...
    "One or more zeros could not be found.");

end

