function [yzeros] = besselyZeros(v, n)
%Gives the first "n" zeros of the "bessely" function.
% Returns a column vector with the first n zeros (yvn) of the "bessely"
% function.
%
% Example Usage:
%   yzeros = besselyZeros(v, n);
%   assert(all(bessely(v, jzeros) == 0));       % Almost passes.
%
%
% Inputs:
%   v - Bessel function order. See "bessely" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   yzeros - First "n" zeros of bessely of order "v".
%
% Author: Matt Dvorsky

arguments
    v(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) bessely(v, y);

yzero0_guess = v + 0.9315768*v.^(1/3) + max(0, 0.89*(1 - v));
for ii = 1:5
    yzero0_guess = yzero0_guess ...
        - bessely(v, yzero0_guess) ./ besselyPrime(v, yzero0_guess);
end

assert(abs(bessely(v, yzero0_guess)) < 1e-10, ...
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
        - bessely(v, yzeros) ./ besselyPrime(v, yzeros);
end

assert(all(abs(bessely(v, yzeros)) < 1e-10), ...
    "One or more zeros could not be found.");

end

