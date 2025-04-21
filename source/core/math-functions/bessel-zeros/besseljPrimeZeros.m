function [jpzeros] = besseljPrimeZeros(v, n)
%Gives the first "n" zeros of the "besseljprime" function.
% Returns a column vector with the first n zeros (j'vn) of the
% "besseljPrime" function.
%
% Example Usage:
%   jpzeros = besseljPrimeZeros(v, n);
%   assert(all(besseljPrime(v, jpzeros) == 0));     % Almost passes.
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   jpzeros - First "n" zeros of besseljPrime of order "v".
%
% Author: Matt Dvorsky

arguments
    v(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besseljPrime(v, y);

jpzero0_guess = v + 0.8086165*v.^(1/3) + 3.83*(v == 0);
for ii = 1:5
    jpzero0_guess = jpzero0_guess ...
        - 2 * besseljPrime(v, jpzero0_guess) ...
        ./ (besseljPrime(v - 1, jpzero0_guess) - besseljPrime(v + 1, jpzero0_guess));
end

assert(abs(besseljPrime(v, jpzero0_guess)) < 1e-10, ...
    "Could not find initial zero.");

jpzeros = zeros(n, 1);
jpzeros(1) = jpzero0_guess;
for ii = 2:n
    jp_guess = jpzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(jp_guess))) ~= 0
        jp_guess(2) = 1.1*jp_guess(2) - 0.1*jpzeros(ii - 1);
    end
    jpzeros(ii) = fzero(fun, jp_guess);
end

%% Refine Using Newtons Method
for ii = 1:5
    jpzeros = jpzeros ...
        - 2 * besseljPrime(v, jpzeros) ...
        ./ (besseljPrime(v - 1, jpzeros) - besseljPrime(v + 1, jpzeros));
end

assert(all(abs(besseljPrime(v, jpzeros)) < 1e-10), ...
    "One or more zeros could not be found.");

end

