function [k, alpha, beta] = besseljy_zeros(nu, n, r1, r2)
%BESSELJY_ZEROS Gives the first "n" *zeros* of the "besseljy" function.
% This function computes the firts "n" trios (alpha, beta, and k) so that
% "besseljy(alpha, beta, nu, k*r1)" and "besseljy(alpha, beta, nu, k*r2)"
% are both equal to zero. Specifically, this function computes the smallest
% "n" values of "k".
%
% Note that there is an arbitrary scale factor that must be chosen when
% choosing alpha and beta, similarly to if we were finding zeros of 
% "a*cos + b*sin". In that case, we would want the scale to be such that
% the result is a shifted cos function. This function attempts to do the
% same, so that besseljy returns a "shifted besselj". More specifically,
% the asymtotic behavior at infinity will be "sqrt(2/(pi*x)) cos(x - c)",
% where "c" is the required phase shift. This matches the behavior of
% besselj and bessely.
%
% The sign, which is also arbitrary, will be chosen such that the
% derivative at k*r2 is positive.
%
% Example Usage:
%   [k, alpha, beta] = besseljy_zeros(nu, n, r1, r2);
%   assert(all(besseljy(alpha, beta, nu, k*r1) == 0));  % Almost passes.
%   assert(all(besseljy(alpha, beta, nu, k*r2) == 0));  % Almost passes.
%
% Inputs:
%   nu - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%   r1 - First value at which "besseljy" should evaluate to zero.
%   r2 - Second value at which "besseljy" should evaluate to zero.
%
% Outputs:
%   k - First "n" scale factors corresponding to zeros. See above.
%   alpha - First "n" besselj coefficients. See above.
%   beta - First "n" bessely coefficients. See above.
%
% Author: Matt Dvorsky

arguments
    nu(1, 1);
    n(1, 1) {mustBePositive, mustBeInteger};
    r1(1, 1) {mustBePositive};
    r2(1, 1) {mustBePositive, mustBeGreaterThan(r2, r1)};
end

%% Calculate Zeros of Determinant
fun = @(y) besselj(nu, abs(y)).*bessely(nu, (r1./r2).*abs(y)) ...
    - besselj(nu, (r1./r2).*abs(y)).*bessely(nu, abs(y));

k = zeros(n, 1);
k(1) = abs(fzero(fun, (nu + (nu == 0))));
for ii = 2:n
    k_guess = k(ii - 1) + (0.5*pi ./ (1 - (r1./r2)./(nu + 1)))*[0.9, 1.1];
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
    ab = null([besseljy(1, 0, nu, k(ii) .* r2), ...
        besseljy(0, 1, nu, k(ii) .* r2)]);
    alpha(ii) = ab(1);
    beta(ii) = ab(2);

    % Choose sign.
    der_sign = (-1).^(ii) ...
        .* sign(besseljyprime(alpha(ii), beta(ii), nu, k(ii)*r2));
    alpha(ii) = der_sign * alpha(ii);
    beta(ii) = der_sign * beta(ii);
end

end

