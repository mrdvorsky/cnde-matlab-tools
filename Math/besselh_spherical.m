function [val] = besselh_spherical(nu, kind, z, scale)
%BESSELH_SPHERICAL Spherical besselh function.
% Use the same way as "besselh", with the "kind" argument specifying the
% 1st or 2nd kind. Computes the spherical besselh function of order "nu".
%
% Example Usage:
%   val = besselh_spherical(nu, kind, z);
%   val = besselh_spherical(nu, kind, z, true);  % Scaled by exp(-abs(imag(z))).
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
    kind(1, 1) {mustBeMember(kind, [1, 2])};
    z;
    scale(1, 1) = 0;
end

val = sqrt(0.5*pi) ./ sqrt(z) .* besselh(0.5 + nu, kind, z, scale);

end

