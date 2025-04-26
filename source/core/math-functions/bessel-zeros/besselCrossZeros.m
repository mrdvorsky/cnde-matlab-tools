function [kvn, tvn] = besselCrossZeros(v, lam, n)
%Calculates the "n"th *zero(s)* of the "bessel cross product function".
% This function computes the "n"th zero(s) of the "bessel cross product
% function", which is defined below:
%       Jv(x) Yv(lam*x) - Yv(x) Jv(lam*x)
%
% Optionally, also returns phase shift coefficients (tvn), for use with
% the besselCylinder function, such that "besselCylinder(v, tvn, kvn)" and
% "besselCylinder(v, tvn, lam.*kvn)" are both zero (or approximately
% zero). In this case, the sign of the besselCylinder function that is
% specified is arbitrary, and thus will be chosen such that the derivative
% at "kvn" is positive.
%
% *** Note that for large values of "v" OR "lam", evaluating the bessel
% cross product function numerically will not result in a value of zero
% due to floating point precision issues. However, the value of "kvn" will
% still be accurate.
%
% Example Usage:
%   [k, t] = besselCrossZeros(v, lam, n);
%   assert(all(besselCylinder(v, t, k) == 0));          % Almost passes.
%   assert(all(besselCylinder(v, t, lam.*k) == 0));     % Almost passes.
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   lam - Parameter in the "bessel cross product function", shown above.
%   n - Number of zeros to find.
%
% Outputs:
%   kvn - First "n" zeros. See above.
%   tvn - Phase shift coefficients, in the form of exp(1j*phase), such
%       that the "besselCylinder" function gives zeros. See above.
%
% Author: Matt Dvorsky

arguments
    v {mustBeNonnegative, mustBeFinite};
    lam {mustBeGreaterThan(lam, 1)};
    n {mustBePositive, mustBeInteger};
end
mustBeBroadcastable(v, lam, n);

%% Broadcast Inputs
% This is only necessary because MATLAB's bessel function implementation
% does not support broadcasting properly.
[v, lam, n] = broadcastArrays(v, lam, n);

%% Calculate Zeros
kvn_desiredUnwrappedPhase = pi*n;
kvn = besseljZeros(v, n) ./ lam;
for nn = 1:5
    [ph, ph_der] = besselCrossPhaseUnwrapped(v, lam, kvn);

    % Update using Newton's method
    kvn = kvn - (ph - kvn_desiredUnwrappedPhase)./ph_der;
end

%% Calculate BesselCylinder Phase Shift Coefficients
tvn = 1j*besselh(v, 1, kvn);
tvn = tvn ./ abs(tvn);
tvn(isnan(tvn)) = 1;

end



%% Helper Functions
function [ph, ph_der] = besselCrossPhaseUnwrapped(v, lam, x)
    [ph1, ph1_der] = besselhPhaseUnwrapped(v, x);
    [ph2, ph2_der] = besselhPhaseUnwrapped(v, lam.*x);

    ph = ph2 - ph1;
    ph_der = ph2_der.*lam - ph1_der;
end