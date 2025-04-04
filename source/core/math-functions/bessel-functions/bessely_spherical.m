function [val] = bessely_spherical(nu, z, scale)
%Spherical bessely function.
% Use the same way as "besselj" or "bessely". Computes the spherical
% bessely function of order "nu".
%
% Example Usage:
%   val = bessely_spherical(nu, z);
%   val = bessely_spherical(nu, z, true);  % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   nu - Bessel function order. Must be an integer.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "bessely" documentation for more information.
%
% Outputs:
%   val - Value of spherical bessely function at "z".
%
% Author: Matt Dvorsky

arguments
    nu {mustBeInteger};
    z;
    scale(1, 1) = 0;
end

val = sqrt(0.5*pi) ./ sqrt(z) .* bessely(0.5 + nu, z, scale);

end

