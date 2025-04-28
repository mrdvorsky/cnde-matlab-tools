function [val] = besselCylinder(v, t, z, scale)
%Essentially a shifted version of the "besselj" and "bessely" functions.
% Use the same way as "besselj" or "bessely", except with an additional
% argument to specify phase shift. This function is basically shifted
% version of the besselj function, where "t" is a unitary complex number
% describing the phase shift, created using a linear combination
% of "besselj" and "bessely".
%
% This is analagous to how cos(x - angle(t)), can be created using a
% linear combination of sin(x) and cos(x).
%
% This function can also be thought of as the instantaneous part of the
% besselh function of the second kind, i.e.: 
%       besselCylinder(v, t, z) = real(besselh(v, 2, x) .* t)
%
% Example Usage:
%   val = besselCylinder(v, t, z);
%   val = besselCylinder(v, t, z, true);    % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   t - Phase shift, expressed as a unitary complex number. A value of t=1
%       will cause this function to behave exactly like besselj, and a
%       value of t=1j will result in "bessely"-like behavior.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of the "phase shifted" besselj function.
%
% Author: Matt Dvorsky

arguments
    v;
    t;
    z;
    scale(1, 1) double = 0;
end
mustBeBroadcastable(v, t, z);

%% Calculate
[v, t, z] = broadcastArrays(v, t, z);
val_real = real(t).*besselj(v, z, scale);
val_imag = imag(t).*bessely(v, z, scale);
val_imag(isnan(val_imag)) = 0;
val = val_real + val_imag;

end

