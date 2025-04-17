function [val] = besseljy(alpha, beta, nu, z, scale)
%Linear combination of "besselj" and "bessely" functions.
% Use the same way as "besselj" or "bessely". Computes the linear
% combination of besselj and bessely function of order nu at z. The inputs
% "alpha" and "beta" are the coefficients of "besselj" and "bessely",
% respectively.
%
% Example Usage:
%   val = besseljy(a, b, nu, z);
%   val = besseljy(a, b, nu, z, true);  % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   alpha - Coefficient of besselj.
%   beta - Coefficient of bessely.
%   nu - Bessel function order. See "besselj" documentation.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of "alpha.*besselj(nu, z) + beta.*bessely(nu, z)".
%
% Author: Matt Dvorsky

arguments
    alpha;
    beta;
    nu;
    z;
    scale(1, 1) double = 0;
end

val = alpha .* besselj(nu, z, scale) + beta .* bessely(nu, z, scale);

end

