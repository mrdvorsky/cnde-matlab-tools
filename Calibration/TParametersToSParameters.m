function [ S ] = TParametersToSParameters( T )
%SParametersToTParameters Convert S-parameters to T-parameters
%   The T-parameter matrix T is converted to the S-parameter form.
%   T should be either n-by-n-by-4. The output T will be n-by-n-by-4, 
%   where the third dimension represents the quadrant of the 2n-by-2n form
%   of S (NW, NE, SW, SE corresponds to S1, S2, S3, S4).
%   The equations for this are as follows:
%
%   S1 = T2/T4
%   S2 = T1 - T2/T4*T3
%   S3 = inv(T4)
%   S4 = -T4\T3

S = T;
S(:, :, 1) = T(:, :, 2) / T(:, :, 4);
S(:, :, 2) = T(:, :, 1) - T(:, :, 2) / T(:, :, 4) * T(:, :, 3);
S(:, :, 3) = inv(T(:, :, 4));
S(:, :, 4) = -T(:, :, 4) \ T(:, :, 3);

end

