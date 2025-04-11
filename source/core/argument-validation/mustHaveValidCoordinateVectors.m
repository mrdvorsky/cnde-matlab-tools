function [] = mustHaveValidCoordinateVectors(Array, coords, options)
%Validate that input array has coordinate vectors with the correct lengths.
% Throws an error if the input array size does not match the coordinate
% vectors. The purpose of this validator is for functions that accept
% nd-arrays along with Repeating inputs for the grid coordinates.
%
% Example Usage:
%   arguments
%       Array;
%   end
%   arguments (Repeating)
%       coords(:, 1);
%   end
%   mustBeValidCoordinateVectors(Array, coords);
%
% Author: Matt Dvorsky

arguments
    Array;
    coords;
    
    options.AllowEmptyCoord(1, 1) logical = false;
end

%% Check Inputs
arrayDims = size(Array, 1:numel(coords));
coordDims = cellfun(@numel, coords);

dimMismatch = coordDims ~= arrayDims;
if options.AllowEmptyCoord
    dimMismatch = dimMismatch ...
        & cellfun(@numel, coords) ~= 0;
end

if ~any(dimMismatch)
    return;
end

%% Create Error Message
arrayDimStr = compose("%d", arrayDims);
coordDimStr = compose("%d", coordDims);

arrayDimStr(dimMismatch) = compose("*%d*", arrayDims(dimMismatch));
coordDimStr(dimMismatch) = compose("*%d*", coordDims(dimMismatch));

throwAsCaller(MException("CNDE:mustHaveValidCoordinateVectors", ...
    "Mismatch between array dimensions and the supplied " + ...
    "coordinate vectors:%s%s    size(Array)  = [%s]" + ...
    "%s    size(coords) = [%s]", ...
    newline(), newline(), ...
    join(arrayDimStr, ", "), ...
    newline(), ...
    join(coordDimStr, ", ")));

end

