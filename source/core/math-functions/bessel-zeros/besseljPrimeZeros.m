function [jpzeros] = besseljPrimeZeros(nu, n)
%Gives the first "n" zeros of the "besseljprime" function.
% Returns a column vector with the first n zeros (j'vn) of the
% "besseljprime" function.
%
% Example Usage:
%   jpzeros = besseljPrimeZeros(nu, n);
%   assert(all(besseljPrime(nu, jpzeros) == 0));    % Almost passes.
%
%
% Inputs:
%   nu - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   jpzeros - First "n" zeros of besseljPrime of order "nu".
%
% Author: Matt Dvorsky

arguments
    nu(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besseljPrime(nu, y);

jpzero0_guess = nu + 0.8086165*nu.^(1/3) + 3.83*(nu == 0);
for ii = 1:5
    jpzero0_guess = jpzero0_guess ...
        - 2 * besseljPrime(nu, jpzero0_guess) ...
        ./ (besseljPrime(nu - 1, jpzero0_guess) - besseljPrime(nu + 1, jpzero0_guess));
end

assert(abs(besseljPrime(nu, jpzero0_guess)) < 1e-14, ...
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
        - 2 * besseljPrime(nu, jpzeros) ...
        ./ (besseljPrime(nu - 1, jpzeros) - besseljPrime(nu + 1, jpzeros));
end

assert(all(abs(besseljPrime(nu, jpzeros)) < 1e-13), ...
    "One or more zeros could not be found.");

end

