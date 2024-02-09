function [k, alpha, beta] = besseljyprime_zeros(nu, n, r1, r2)
%BESSELJYPRIME_ZEROS Gives the first "n" *zeros* of the "besseljyprime" function.
% This function computes the firts "n" trios (alpha, beta, and k) so that
% "besseljyprime(alpha, beta, nu, k*r1)" and "besseljyprime(alpha, beta, nu, k*r2)"
% are both equal to zero. Specifically, this function computes the smallest
% "n" values of "k".
%
% Example Usage:
%   [k, alpha, beta] = besseljyprime_zeros(nu, n, r1, r2);
%   assert(all(besseljyprime(alpha, beta, nu, k*r1) == 0));     % Almost passes.
%   assert(all(besseljyprime(alpha, beta, nu, k*r2) == 0));     % Almost passes.
%
% Inputs:
%   nu - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%   r1 - First value at which "besseljyprime" should evaluate to zero.
%   r2 - Second value at which "besseljyprime" should evaluate to zero.
%
% Outputs:
%   k - First "n" scale factors corresponding to zeros. See above.
%   alpha - First "n" besseljprime coefficients. See above.
%   beta - First "n" besselyprime coefficients. See above.
%
% Author: Matt Dvorsky

arguments
    nu(1, 1);
    n(1, 1) {mustBePositive, mustBeInteger};
    r1(1, 1) {mustBePositive};
    r2(1, 1) {mustBePositive, mustBeGreaterThan(r2, r1)};
end

%% Calculate Zeros of Determinant
fun = @(y) besseljprime(nu, abs(y)).*besselyprime(nu, (r1./r2).*abs(y)) ...
    - besseljprime(nu, (r1./r2).*abs(y)).*besselyprime(nu, abs(y));

k = zeros(n, 1);
k(1) = abs(fzero(fun, (nu + (nu == 0))));
for ii = 2:n
    k_guess = k(ii - 1) + (0.5*pi ./ (1 - (r1./r2)))*[0.9, 1.1];
    while sum(sign(fun(k_guess))) ~= 0
        k_guess(2) = 1.1*k_guess(2) - 0.1*k(ii - 1);
    end
    k(ii) = fzero(fun, k_guess);
end
k = k ./ r2;

%% Calculate "alpha" and "beta"
alpha = zeros(n, 1);
beta = zeros(n, 1);
for ii = 1:numel(k)
    ab = null([besseljyprime(1, 0, nu, k(ii) .* r2), ...
        besseljyprime(0, 1, nu, k(ii) .* r2)]);
    alpha(ii) = ab(1);
    beta(ii) = ab(2);
end

end

