function [val] = besselyPrime(v, z, scale)
%Derivative of the "bessely" function.
% Use the same way as "bessely". Computes the derivative of the bessely
% function of order nu at z.
%
% Example Usage:
%   val = besselyPrime(v, z);
%   val = besselyPrime(v, z, true);     % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   v - Bessel function order. See "bessely" documentation.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "bessely" documentation for more information.
%
% Outputs:
%   val - Value of bessely derivative.
%
% Author: Matt Dvorsky

arguments
    v;
    z;
    scale(1, 1) double = 0;
end

val = 0.5 * (bessely(v - 1, z, scale) - bessely(v + 1, z, scale));

end

