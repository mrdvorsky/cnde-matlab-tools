function [yzeros] = besselyZeros(nu, n)
%Gives the first "n" zeros of the "bessely" function.
% Returns a column vector with the first n zeros (yvn) of the "bessely"
% function.
%
% Example Usage:
%   yzeros = besselyZeros(nu, n);
%   assert(all(bessely(nu, jzeros) == 0));      % Almost passes.
%
%
% Inputs:
%   nu - Bessel function order. See "bessely" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   yzeros - First "n" zeros of bessely of order "nu".
%
% Author: Matt Dvorsky

arguments
    nu(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) bessely(nu, y);

yzero0_guess = nu + 0.9315768*nu.^(1/3) + max(0, 0.89*(1 - nu));
for ii = 1:5
    yzero0_guess = yzero0_guess ...
        - bessely(nu, yzero0_guess) ./ besselyPrime(nu, yzero0_guess);
end

assert(abs(bessely(nu, yzero0_guess)) < 1e-14, ...
    "Could not find initial zero.");

yzeros = zeros(n, 1);
yzeros(1) = yzero0_guess;
for ii = 2:n
    y_guess = yzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(y_guess))) ~= 0
        y_guess(2) = 1.1*y_guess(2) - 0.1*yzeros(ii - 1);
    end
    yzeros(ii) = fzero(fun, y_guess);
end

%% Refine Using Newtons Method
for ii = 1:5
    yzeros = yzeros ...
        - bessely(nu, yzeros) ./ besselyPrime(nu, yzeros);
end

assert(all(abs(bessely(nu, yzeros)) < 1e-13), ...
    "One or more zeros could not be found.");

end

