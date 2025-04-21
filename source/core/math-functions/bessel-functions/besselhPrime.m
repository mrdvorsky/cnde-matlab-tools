function [val] = besselhPrime(v, kind, z, scale)
%Derivative of the "besselh" function.
% Use the same way as "besselh", with the "kind" argument specifying the
% 1st or 2nd kind. Computes the derivative of the besselh function of order
% "v".
%
% Example Usage:
%   val = besselhPrime(v, z);
%   val = besselhPrime(v, z, true);     % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   v - Bessel function order. See "besselh" documentation.
%   kind - Value of 1, or 2, indicating the 'kind' of the hankel function.
%       See the "besselh" documentation for more info.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselh" documentation for more information.
%
% Outputs:
%   val - Value of besselh derivative.
%
% Author: Matt Dvorsky

arguments
    v;
    kind(1, 1) {mustBeMember(kind, [1, 2])};
    z;
    scale(1, 1) double = 0;
end

val = 0.5 * (besselh(v - 1, kind, z, scale) ...
    - besselh(v + 1, kind, z, scale));

end

