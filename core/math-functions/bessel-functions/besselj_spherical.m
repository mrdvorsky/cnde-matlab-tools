function [val] = besselj_spherical(nu, z, scale)
%Spherical besselj function.
% Use the same way as "besselj" or "bessely". Computes the spherical
% besselj function of order "nu".
%
% Example Usage:
%   val = besselj_spherical(nu, z);
%   val = besselj_spherical(nu, z, true);  % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   nu - Bessel function order. Must be an integer.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of spherical besselj function at "z".
%
% Author: Matt Dvorsky

arguments
    nu {mustBeInteger};
    z;
    scale(1, 1) = 0;
end

val = sqrt(0.5*pi) ./ sqrt(z) .* besselj(0.5 + nu, z, scale);
val(abs(z) <= eps) = (nu == 0);

end

