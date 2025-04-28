function [kpvn, tpvn] = besselCrossPrimeZeros(v, lam, n)
%Calculates the "n"th *zero(s)* of the "besselPrime cross product function".
% This function computes the "n"th positive zero(s) of the "besselPrime
% cross product function", which is defined below:
%       J'v(x) Y'v(lam*x) - Y'v(x) J'v(lam*x)
%
% Optionally, also returns phase shift coefficients (tvn), for use with
% the besselCylinder function, such that "besselCylinderPrime(v, tvn, kvn)"
% and "besselCylinderPrime(v, tvn, lam.*kvn)" are both zero (or
% approximately zero). In this case, the sign of the besselCylinder
% function that is specified is arbitrary, and thus will be chosen such
% that the value of besselCylinder at "kvn" is positive.
%
% *** Note that for large values of "v" OR "lam", evaluating the bessel
% cross product function numerically will not result in a value of zero
% due to floating point precision issues. However, the value of "kvn" will
% still be accurate.
%
% *** Also note that at the order approaches v=0, the first zero of the
% besselPrime cross function approaches kpvn=0, which is non-positive.
% Therefore, when v=0 exactly, the output jumps (i.e., a there is a
% discontinuity at v=0). This is very similar behavior to the
% "besseljPrimeZeros" function. For very small orders (e.g., v=1e-6), the
% first zero may be innaccurate.
%
% Example Usage:
%   [k, t] = besselCrossPrimeZeros(v, lam, n);
%   assert(all(besselCylinderPrime(v, t, k) == 0));         % Almost passes.
%   assert(all(besselCylinderPrime(v, t, lam.*k) == 0));    % Almost passes.
%
%
% Inputs:
%   v - Bessel function order. See "besselj" documentation.
%   lam - Parameter in the "bessel cross product function", shown above.
%   n - Number of zeros to find.
%
% Outputs:
%   kpvn - First "n" zeros. See above.
%   tpvn - Phase shift coefficients, in the form of exp(1j*phase), such
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
kpvn_desiredUnwrappedPhase = pi*n - pi*(v > 0);
kpvn = besseljPrimeZeros(v, n) ./ lam;
for nn = 1:8
    [ph, ph_der] = besselCrossPrimePhaseUnwrapped(v, lam, kpvn);

    % Update using Newton's method
    kpvn = kpvn - (ph - kpvn_desiredUnwrappedPhase)./ph_der;
end

%% Calculate BesselCylinder Phase Shift Coefficients
tpvn = -1j*besselhPrime(v, 1, kpvn);
tpvn = tpvn ./ abs(tpvn);
tpvn(isnan(tpvn)) = 1;

end



%% Helper Functions
function [ph, ph_der] = besselCrossPrimePhaseUnwrapped(v, lam, x)
    [ph1, ph1_der] = besselhPrimePhaseUnwrapped(v, x);
    [ph2, ph2_der] = besselhPrimePhaseUnwrapped(v, lam.*x);

    ph = ph2 - ph1;
    ph_der = ph2_der.*lam - ph1_der;
end