function [val] = besseljyprime(nu, z, alpha, beta, scale)
%BESSELJYPRIME Derivative of "besseljy".
% Use the same way as "besseljy". Computes the derivative of besseljy.
%
% Example Usage:
%   val = besseljyprime(a, b, nu, z);
%   val = besseljyprime(a, b, nu, z, true); % Scaled by exp(-abs(imag(z))).
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
%   val - Value of the derivative.
%
% Author: Matt Dvorsky

arguments
    nu;
    z;
    alpha;
    beta;
    scale(1, 1) = 0;
end

val = 0.5 * (besseljy(alpha, beta, nu - 1, z, scale) ...
    - besseljy(alpha, beta, nu + 1, z, scale));

end

