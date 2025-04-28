function [ph_unwrapped_exact, ph_der] = besselhPrimePhaseUnwrapped(v, x)
%Calculates phase (and derivative) of besselhPrime, but unwrapped.
%
% Author: Matt Dvorsky

arguments
    v;
    x;
end

%% Calculate Exact Wrapped Phase
jVal = besseljPrime(v, x);
yVal = besselyPrime(v, x);

yVal(isinf(yVal) | isnan(yVal)) = inf;  % Fix Matlab bug when x/v is small.
ph_wrapped_exact = atan2(yVal, jVal);

%% Approximate Unwrapped Phase
ph_unwrapped_approx = sqrt(max(0, x.^2 - v.^2)) ...
    - v.*asec(max(1, x ./ v)) + 0.25*pi;

%% Unwrap Exact Phase using Approximate Unwrapped Value
nOff = round((ph_unwrapped_approx - ph_wrapped_exact) ./ (2*pi));
ph_unwrapped_exact = ph_wrapped_exact + (2*pi) * nOff;

%% Calculate Derivative of Phase
ph_der = (1 ./ (jVal.^2 + yVal.^2)) ...
    ./ (0.5*pi*x) .* (1 - (v./x).^2);

end
