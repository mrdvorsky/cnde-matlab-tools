function [ypvm] = besselyPrimeZeros(v, n)
%Calculates the "n"th zero(s) of the "besselyPrime" function.
% Returns the nth (1-indexed) zero of the "besselyPrime" function.
%
% Example Usage:
%   ypvm = besselyPrimeZeros(v, n);
%   assert(all(besselyPrime(v, ypvm) == 0));      % Almost passes.
%
%
% Inputs:
%   v - Bessel function order(s).
%   n - Which zeros to find, indexed starting at 1.
%
% Outputs:
%   ypvn - The "n"th zeros of besselyPrime of order "v".
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
ypvm_desiredUnwrappedPhase = pi*n;
ypvm = ypvm_desiredUnwrappedPhase ...
    + max(v - 1, v + 1.8210980*v.^(1/3) - pi);
for nn = 1:5
    [ph, ph_der] = besselhPrimePhaseUnwrapped(v, ypvm);

    % Update using Newton's method
    ypvm = ypvm - (ph - ypvm_desiredUnwrappedPhase)./ph_der;
end

end
