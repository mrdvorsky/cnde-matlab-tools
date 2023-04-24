function [yvn] = besselyZeros(v, n)
%Calculates the "n"th zero(s) of the "bessely" function.
% Returns the nth (1-indexed) zero of the "bessely" function.
%
% Example Usage:
%   yvn = besselyZeros(v, n);
%   assert(all(bessely(v, yvn) == 0));      % Almost passes.
%
%
% Inputs:
%   v - Bessel function order(s).
%   n - Which zeros to find, indexed starting at 1.
%
% Outputs:
%   yvn - The "n"th zeros of bessely of order "v".
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
yvm_desiredUnwrappedPhase = pi*n - pi;
yvn = yvm_desiredUnwrappedPhase ...
    + max(0.89 + v, v + 0.9315768*v.^(1/3));
for nn = 1:5
    [ph, ph_der] = besselhPhaseUnwrapped(v, yvn);

    % Update using Newton's method
    yvn = yvn - (ph - yvm_desiredUnwrappedPhase)./ph_der;
end

end

