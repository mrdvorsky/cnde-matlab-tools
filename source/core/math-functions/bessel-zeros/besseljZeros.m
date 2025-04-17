function [jzeros] = besselj_zeros(nu, n)
%Gives the first "n" zeros of the "besselj" function.
% Returns a column vector with the first n zeros (jvn) of the "besselj"
% function.
%
% Example Usage:
%   jzeros = besselj_zeros(nu, n);
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
    nu(1, 1);
    n(1, 1) {mustBePositive, mustBeInteger};
end

%% Calculate Zeros
fun = @(y) besselj(nu, y);

jzeros = zeros(n, 1);
jzeros(1) = fzero(fun, nu + 2.41*(nu < 10));
for ii = 2:n
    j_guess = jzeros(ii - 1) + pi*[0.9, 1.1];
    while sum(sign(fun(j_guess))) ~= 0
        j_guess(2) = 1.1*j_guess(2) - 0.1*jzeros(ii - 1);
    end
    jzeros(ii) = fzero(fun, j_guess);
end

end

