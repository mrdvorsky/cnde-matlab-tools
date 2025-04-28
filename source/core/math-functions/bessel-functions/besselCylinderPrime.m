function [val] = besselCylinderPrime(v, t, z, scale)
%Derivative of "besselCylinder" with respect to z.
% Use the same way as "besselCylinder".
%
% Example Usage:
%   val = besselCylinderPrime(v, t, z);
%   val = besselCylinderPrime(v, t, z, true);   % Scaled by exp(-abs(imag(z))).
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   t - Shift parameter. See "besselCylinderPrime" for more information.
%   z - Value to evaluate at.
%   scale (0) - Whether to scale output by exp(-abs(imag(Z))). See
%       "besselj" documentation for more information.
%
% Outputs:
%   val - Value of the derivative.
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
val_real = real(t).*besseljPrime(v, z, scale);
val_imag = imag(t).*besselyPrime(v, z, scale);
val_imag(isnan(val_imag)) = 0;
val = val_real + val_imag;

end

