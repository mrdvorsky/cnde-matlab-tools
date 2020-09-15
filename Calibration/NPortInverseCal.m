function [ Sm ] = NPortInverseCal( S, T )
%NPORTCAL Apply the error adapter for non-ideal network analyzer
%   The error adapter (T) for a non-ideal network analyzer is applied to
%   the actual S-parameters (S) to give the measured S-parameters (Sm) 
%   using the equation Sm = (T1*S + T2)/(T4*S + T4). For an N-port device,
%   the size of Sm should be N-by-N.
%   T is N-by-N-by-4 and represents the four parameters in the equation
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0.

Sm = (T(:, :, 1) * S + T(:, :, 2)) / (T(:, :, 3) * S + T(:, :, 4));

end

