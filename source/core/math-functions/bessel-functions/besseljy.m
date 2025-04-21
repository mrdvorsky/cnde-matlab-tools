function [val] = besseljy(t, v, z, scale)
%Essentially a shifted version of the "besselj" and "bessely" functions.
% Use the same way as "besselj" or "bessely". This function is basically a
% shifted version of the besselj function, where "t" describes the phase
% shift, created using a linear combination of "besselj" and "bessely".
% This is analagous to how a shifted version of cos(x), or cos(x - t), can
% be created using s linear combination of sin(x) and cos(x).
%
% Example Usage:
%   val = besseljy(t, v, z);
%   val = besseljy(t, v, z, true);      % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   t - Phase shift, in radians. A value of t=0 will cause this function to
%       behave exactly like besselj, and a value of t=pi/2 will result in
%       "bessely"-like behavior.
%   v - Bessel function order. See "besselj" documentation.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of the "phase shifted" besselj function.
%
% Author: Matt Dvorsky

arguments
    t;
    v;
    z;
    scale(1, 1) double = 0;
end

val = cos(t).*besselj(v, z, scale) ...
    + sin(t).*bessely(v, z, scale);

end

