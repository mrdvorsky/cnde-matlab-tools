function [val] = besseljPrime(nu, z, scale)
%Derivative of the "besselj" function.
% Use the same way as "besselj". Computes the derivative of the "besselj"
% function of order nu at z.
%
% Example Usage:
%   val = besseljPrime(nu, z);
%   val = besseljPrime(nu, z, true);    % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   nu - Bessel function order. See "besselj" documentation.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of besselj derivative.
%
% Author: Matt Dvorsky

arguments
    nu;
    z;
    scale(1, 1) double = 0;
end

val = 0.5 * (besselj(nu - 1, z, scale) - besselj(nu + 1, z, scale));

end

