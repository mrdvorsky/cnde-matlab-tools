function [jpvm] = besseljPrimeZeros(v, n)
%Calculates the "n"th zero(s) of the "besseljPrime" function.
% Returns the nth (1-indexed) zero of the "besseljPrime" function.
%
% *** Note that for J0'(x) (i.e., when v=0), the first zero is
% approximately 3.83, rather than 0, due to convention. Since the first
% zero of J1'(x) is approximately 1.84, there must be some discontinuity
% between v=0 and v=1. This is chosen here to be at v>0. This means that
% for very small orders (e.g., v=1e-6), the first zero may be innaccurate.
%
% Example Usage:
%   jpvm = besseljPrimeZeros(v, n);
%   assert(all(besseljPrime(v, jpvm) == 0));      % Almost passes.
%
%
% Inputs:
%   v - Bessel function order(s).
%   n - Which zeros to find, indexed starting at 1.
%
% Outputs:
%   jpvn - The "n"th zeros of besseljPrime of order "v".
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
jpvm_desiredUnwrappedPhase = pi*n - 0.5*pi + pi*(v == 0);
jpvm = jpvm_desiredUnwrappedPhase ...
    + v + 0.8086165*v.^(1/3) - 0.5*pi;
for nn = 1:5
    [ph, ph_der] = besselhPrimePhaseUnwrapped(v, jpvm);

    % Update using Newton's method
    jpvm = jpvm - (ph - jpvm_desiredUnwrappedPhase)./ph_der;
end

end
