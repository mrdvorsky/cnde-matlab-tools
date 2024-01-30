function [val] = besseljy(nu, z, alpha, beta, scale)
%BESSELJY Linear combination of "besselj" and "bessely" functions.
% Use the same way as "besselj" or "bessely". Computes the linear
% combination of besselj and bessely function of order nu at z. The inputs
% "alpha" and "beta" are the coefficients of "besselj" and "bessely",
% respectively.
%
% Example Usage:
%   val = besseljy(a, b, nu, z);
%   val = besseljy(a, b, nu, z, true);  % Scaled by exp(-abs(imag(z))).
%
% Inputs:
%   nu - Bessel function order. See "besselj" documentation.
%   z - Value to evaluate at.
%   alpha - Coefficient of besselj.
%   beta - Coefficient of bessely.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of "alpha.*besselj(nu, z) + beta.*bessely(nu, z)".
%
% Author: Matt Dvorsky

arguments
    nu;
    z;
    alpha;
    beta;
    scale(1, 1) = 0;
end

val = alpha .* besselj(nu, z, scale) + beta .* bessely(nu, z, scale);

end

