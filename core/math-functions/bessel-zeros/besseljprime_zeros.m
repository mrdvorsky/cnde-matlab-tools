function [jpzeros] = besseljprime_zeros(nu, n)
%Gives the first "n" zeros of the "besseljprime" function.
% Returns a column vector with the first n zeros (j'vn) of the
% "besseljprime" function.
%
% Example Usage:
%   jpzeros = besseljprime_zeros(nu, n);
%   assert(all(besseljprime(nu, jpzeros) == 0));    % Almost passes.
%
%
% Inputs:
%   nu - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   jpzeros - First "n" zeros of besseljprime of order "nu".
%
% Author: Matt Dvorsky

arguments
    nu(1, 1);
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besseljprime(nu, y);

jpzeros = zeros(n, 1);
jpzeros(1) = fzero(fun, nu + 2.4*(nu < 10));
for ii = 2:n
    jp_guess = jpzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(jp_guess))) ~= 0
        jp_guess(2) = 1.1*jp_guess(2) - 0.1*jpzeros(ii - 1);
    end
    jpzeros(ii) = fzero(fun, jp_guess);
end

end

