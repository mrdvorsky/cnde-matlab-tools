function [ arrOut ] = roundToNearest( arrIn, roundValues )
%ROUNDTONEAREST Round arrIn values to the nearest match in roundValues
%   TODO: Write explaination (roundValues will be treated as a vector)

arrOut = arrIn;
[~, nearestIndices] = min(abs(roundValues(:) - arrIn(:).'));
arrOut(:) = roundValues(nearestIndices);

arrOut(arrIn == inf) = max(roundValues(:));
arrOut(arrIn == -inf) = min(roundValues(:));

end

