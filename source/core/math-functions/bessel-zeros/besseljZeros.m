function [jzeros] = besseljZeros(v, n)
%Gives the first "n" zeros of the "besselj" function.
% Returns a column vector with the first n zeros (jvn) of the "besselj"
% function.
%
% Example Usage:
%   jzeros = besseljZeros(v, n);
%   assert(all(besselj(v, jzeros) == 0));       % Almost passes.
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   jzeros - First "n" zeros of besselj of order "v".
%
% Author: Matt Dvorsky

arguments
    v(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besselj(v, y);

jzero0_guess = v + 1.8557571*v.^(1/3) + max(0, 2.4*(1 - v));
for ii = 1:5
    jzero0_guess = jzero0_guess ...
        - besselj(v, jzero0_guess) ./ besseljPrime(v, jzero0_guess);
end

assert(abs(besselj(v, jzero0_guess)) < 1e-10, ...
    "Could not find initial zero.");

jzeros = zeros(n, 1);
jzeros(1) = jzero0_guess;
for ii = 2:n
    j_guess = jzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(j_guess))) ~= 0
        j_guess(2) = 1.1*j_guess(2) - 0.1*jzeros(ii - 1);
    end
    jzeros(ii) = fzero(fun, j_guess);
end

%% Refine Using Newtons Method
for ii = 1:5
    jzeros = jzeros ...
        - besselj(v, jzeros) ./ besseljPrime(v, jzeros);
end

assert(all(abs(besselj(v, jzeros)) < 1e-10), ...
    "One or more zeros could not be found.");

end

