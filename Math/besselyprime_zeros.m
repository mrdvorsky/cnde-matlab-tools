function [ypzeros] = besselyprime_zeros(nu, n)
%BESSELYPRIME_ZEROS Gives the first "n" zeros of the "besselyprime" function.
% Returns a column vector with the first n zeros (y'vn) of the
% "besselyprime" function.
%
% Example Usage:
%   ypzeros = besselyprime_zeros(nu, n);
%   assert(all(besselyprime(nu, ypzeros) == 0));    % Almost passes.
%
% Inputs:
%   nu - Bessel function order. See "bessely" documentation.
%   n - Number of zeros to find.
%
% Outputs:
%   ypzeros - First "n" zeros of besselyprime of order "nu".
%
% Author: Matt Dvorsky

arguments
    nu(1, 1);
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besselyprime(nu, y);

ypzeros = zeros(n, 1);
ypzeros(1) = fzero(fun, nu + 2.4*(nu < 10));
for ii = 2:n
    yp_guess = ypzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(yp_guess))) ~= 0
        yp_guess(2) = 1.1*yp_guess(2) - 0.1*ypzeros(ii - 1);
    end
    ypzeros(ii) = fzero(fun, yp_guess);
end

end

