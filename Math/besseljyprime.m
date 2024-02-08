function [val] = besseljyprime(alpha, beta, nu, z, scale)
%BESSELJYPRIME Derivative of "besseljy".
% Use the same way as "besseljy". Computes the derivative of besseljy.
%
% Example Usage:
%   val = besseljyprime(a, b, nu, z);
%   val = besseljyprime(a, b, nu, z, true); % Scaled by exp(-abs(imag(z))).
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
%   val - Value of the derivative.
%
% Author: Matt Dvorsky

arguments
    alpha;
    beta;
    nu;
    z;
    scale(1, 1) = 0;
end

val = 0.5 * (besseljy(alpha, beta, nu - 1, z, scale) ...
    - besseljy(alpha, beta, nu + 1, z, scale));

end

