function [ S ] = NPortCal( Sm, T )
%NPORTCAL Remove the error adapter for non-ideal network analyzer
%   The error adapter (T) for a non-ideal network analyzer is removed from
%   the measured S-parameters (Sm) to give the actual S-parameters (S) 
%   using the equation S = (T1 - Sm*T3)\(Sm*T4 - T2). For an N-port device,
%   the size of Sm should be N-by-N.
%   T is N-by-N-by-4 and represents the four parameters in the equation
%   T1*S + T2 - Sm*T3*S - Sm*T4 = 0.

S = (T(:, :, 1) - Sm * T(:, :, 3)) \ (Sm * T(:, :, 4) - T(:, :, 2));

end

