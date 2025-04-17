function [jzeros] = besseljZeros(nu, n)
%Gives the first "n" zeros of the "besselj" function.
% Returns a column vector with the first n zeros (jvn) of the "besselj"
% function.
%
% Example Usage:
%   jzeros = besseljZeros(nu, n);
%   assert(all(besselj(nu, jzeros) == 0));      % Almost passes.
%
%
% Inputs:
%   nu - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   jzeros - First "n" zeros of besselj of order "nu".
%
% Author: Matt Dvorsky

arguments
    nu(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besselj(nu, y);

jzero0_guess = nu + 1.8557571*nu.^(1/3) + max(0, 2.4*(1 - nu));
for ii = 1:5
    jzero0_guess = jzero0_guess ...
        - besselj(nu, jzero0_guess) ./ besseljPrime(nu, jzero0_guess);
end

assert(abs(besselj(nu, jzero0_guess)) < 1e-14, ...
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
        - besselj(nu, jzeros) ./ besseljPrime(nu, jzeros);
end

assert(all(abs(besselj(nu, jzeros)) < 1e-13), ...
    "One or more zeros could not be found.");

end

