function [val] = besselhprime(nu, kind, z, scale)
%BESSELJPRIME Derivative of the "besselh" function.
% Use the same way as "besselh", with the "kind" argument specifying the
% 1st or 2nd kind. Computes the derivative of the besselh function of order
% "nu".
%
% Example Usage:
%   val = besselhprime(nu, z);
%   val = besselhprime(nu, z, true);    % Scaled by exp(-abs(imag(z))).
%
% Inputs:
%   nu - Bessel function order. See "besselh" documentation.
%   kind - Value of 1, or 2, indicating the 'kind' of the hankel function.
%       See the "besselh" documentation for more info.
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
    kind(1, 1) {mustBeMember(kind, [1, 2])};
    z;
    scale(1, 1) = 0;
end

val = 0.5 * (besselh(nu - 1, kind, z, scale) ...
    - besselh(nu + 1, kind, z, scale));

end

