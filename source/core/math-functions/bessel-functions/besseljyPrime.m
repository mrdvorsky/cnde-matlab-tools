function [val] = besseljyPrime(t, v, z, scale)
%Derivative of "besseljy" with respect to z.
% Use the same way as "besseljy". Computes the derivative of besseljy.
%
% Example Usage:
%   val = besseljyPrime(t, v, z);
%   val = besseljyPrime(t, v, z, true);     % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   t - Shift parameter. See besseljy for more information.
%   v - Bessel function order. See "besselj" documentation.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of the derivative.
%
% Author: Matt Dvorsky

arguments
    t;
    v;
    z;
    scale(1, 1) double = 0;
end

val = 0.5 * (besseljy(t, v - 1, z, scale) ...
    - besseljy(t, v + 1, z, scale));

end

