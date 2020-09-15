function [ T ] = SParametersToTParameters( S )
%SParametersToTParameters Convert S-parameters to T-parameters
%   The S-parameter matrix S is converted to the T-parameter form.
%   S should be either 2n-by-2n or n-by-n-by-4, where the third dimension
%   represents the quadrant of the 2n-by-2n form (NW, NE, SW, SE).
%   The output T will be n-by-n-by-4, where the third dimension represents 
%   the quadrant of the 2n-by-2n form (NW, NE, SW, SE corresponds to
%   T1, T2, T3, T4). The equations for this are as follows:
%
%   T1 = S2 - S1/S3*S4
%   T2 = S1/S3
%   T3 = S3\S4
%   T4 = inv(S3)

if size(S, 3) ~= 4
    S = cat(3, S(1:end/2, 1:end/2), S(1:end/2, end/2 + 1:end), ...
        S(end/2 + 1:end, 1:end/2), S(end/2 + 1:end, end/2 + 1:end));
end

T = S;
T(:, :, 1) = S(:, :, 2) - S(:, :, 1) / S(:, :, 3) * S(:, :, 4);
T(:, :, 2) = S(:, :, 1) / S(:, :, 3);
T(:, :, 3) = -S(:, :, 3) \ S(:, :, 4);
T(:, :, 4) = inv(S(:, :, 3));

end

