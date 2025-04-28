function [jvn] = besseljZeros(v, n)
%Calculates the "n"th zero(s) of the "besselj" function.
% Returns the nth (1-indexed) zero of the "besselj" function.
%
% Example Usage:
%   jvn = besseljZeros(v, n);
%   assert(all(besselj(v, jvn) == 0));      % Almost passes.
%
%
% Inputs:
%   v - Bessel function order(s).
%   n - Which zeros to find, indexed starting at 1.
%
% Outputs:
%   jvn - The "n"th zeros of besselj of order "v".
%
% Author: Matt Dvorsky

arguments
    v {mustBeNonnegative, mustBeFinite};
    n {mustBePositive, mustBeInteger, ...
        mustBeBroadcastable(v, n)};
end

%% Broadcast "v" and "n"
% This is only necessary because MATLAB's bessel function implementation
% does not support broadcasting properly.
[v, n] = broadcastArrays(v, n);

%% Calculate Zeros
jvm_desiredUnwrappedPhase = pi*n - 0.5*pi;
jvn = jvm_desiredUnwrappedPhase ...
    + max(2.4 + v, v + 1.8557571*v.^(1/3)) - 0.5*pi;
for nn = 1:5
    [ph, ph_der] = besselhPhaseUnwrapped(v, jvn);

    % Update using Newton's method
    jvn = jvn - (ph - jvm_desiredUnwrappedPhase)./ph_der;
end

end

