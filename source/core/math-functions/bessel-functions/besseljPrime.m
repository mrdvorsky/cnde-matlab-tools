function [val] = besseljPrime(v, z, scale)
%Derivative of the "besselj" function.
% Use the same way as "besselj". Computes the derivative of the "besselj"
% function of order v at z.
%
% Example Usage:
%   val = besseljPrime(v, z);
%   val = besseljPrime(v, z, true);     % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of besselj derivative.
%
% Author: Matt Dvorsky

arguments
    v;
    z;
    scale(1, 1) double = 0;
end

val = 0.5 * (besselj(v - 1, z, scale) - besselj(v + 1, z, scale));

end

