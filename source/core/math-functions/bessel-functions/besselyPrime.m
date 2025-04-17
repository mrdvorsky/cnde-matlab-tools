function [val] = besselyPrime(nu, z, scale)
%Derivative of the "bessely" function.
% Use the same way as "bessely". Computes the derivative of the bessely
% function of order nu at z.
%
% Example Usage:
%   val = besselyPrime(nu, z);
%   val = besselyPrime(nu, z, true);    % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   nu - Bessel function order. See "bessely" documentation.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "bessely" documentation for more information.
%
% Outputs:
%   val - Value of bessely derivative.
%
% Author: Matt Dvorsky

arguments
    nu;
    z;
    scale(1, 1) double = 0;
end

val = 0.5 * (bessely(nu - 1, z, scale) - bessely(nu + 1, z, scale));

end

