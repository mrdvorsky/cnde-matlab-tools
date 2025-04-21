function [k, t] = besseljyCrossZeros(v, n, r1, r2)
%Gives the first "n" *zeros* of the "besseljy" cross product function.
% This function computes the firts "n" pairs (k and t) so that
% "besseljy(t, v, k*r1)" and "besseljy(t, v, k*r2)" are both equal to
% zero. Specifically, this function computes the smallest "n" values of
% "k".
%
% The sign of besseljy function that is specified is arbitrary, and thus
% will be chosen such that the derivative at k*r1 is positive.
%
% Example Usage:
%   [k, t] = besseljyCrossZeros(v, n, r1, r2);
%   assert(all(besseljy(t, v, k*r1) == 0));     % Almost passes.
%   assert(all(besseljy(t, v, k*r2) == 0));     % Almost passes.
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   n - Number of zeros to find.
%   r1 - First value at which "besseljy" should evaluate to zero.
%   r2 - Second value at which "besseljy" should evaluate to zero.
%
% Outputs:
%   k - First "n" scale factors corresponding to zeros. See above.
%   t - Phase shift coefficients such that the zeros are in the correct
%       place.
%
% Author: Matt Dvorsky

arguments
    v(1, 1) {mustBeNonnegative, mustBeFinite};
    n(1, 1) {mustBePositive, mustBeInteger};
    r1(1, 1) {mustBePositive};
    r2(1, 1) {mustBePositive, mustBeGreaterThan(r2, r1)};
end

%% Calculate Zeros of Determinant
fun = @(y) besselj(v, abs(y)).*bessely(v, (r1./r2).*abs(y)) ...
    - besselj(v, (r1./r2).*abs(y)).*bessely(v, abs(y));

k = zeros(n, 1);
k(1) = abs(fzero(fun, (v + (v == 0))));
for ii = 2:n
    k_guess = k(ii - 1) + (0.5*pi ./ (1 - (r1./r2)./(v + 1)))*[0.9, 1.1];
    while sum(sign(fun(k_guess))) ~= 0
        k_guess(2) = 1.1*k_guess(2) - 0.1*k(ii - 1);
    end
    k(ii) = fzero(fun, k_guess);
end
k = k ./ r2;

%% Calculate "alpha" and "beta"
t = zeros(n, 1);
for ii = 1:numel(k)
    ab = null([besseljy(0, v, k(ii) .* r2), ...
        besseljy(0.5*pi, v, k(ii) .* r2)]);
    alpha = ab(1);
    beta = ab(2);

    t(ii) = atan2(beta, alpha);

    % Choose sign.
    der_sign = (-1).^(ii) ...
        .* sign(besseljyPrime(t(ii), v, k(ii)*r2));
    t(ii) = t(ii) + pi*(der_sign < 0);
end

end

