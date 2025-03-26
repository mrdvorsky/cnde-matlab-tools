function [yzeros] = bessely_zeros(nu, n)
%BESSELY_ZEROS Gives the first "n" zeros of the "bessely" function.
% Returns a column vector with the first n zeros (yvn) of the "bessely"
% function.
%
% Example Usage:
%   yzeros = bessely_zeros(nu, n);
%   assert(all(bessely(nu, jzeros) == 0));      % Almost passes.
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
    nu(1, 1);
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) bessely(nu, y);

yzeros = zeros(n, 1);
yzeros(1) = fzero(fun, nu + 2.41*(nu < 10));
for ii = 2:n
    y_guess = yzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(y_guess))) ~= 0
        y_guess(2) = 1.1*y_guess(2) - 0.1*yzeros(ii - 1);
    end
    yzeros(ii) = fzero(fun, y_guess);
end

end

