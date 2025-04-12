function mustHaveValidCoordinateVectors(Arrays, coords, options)
%Validate that input arrays have coordinate vectors with the correct lengths.
% Throws an error if the input array size does not match the coordinate
% vectors. The most common use of this validator is for functions that
% accept nd-arrays along with Repeating inputs for the grid coordinates.
%
% Example Usage:
%   arguments
%       Array1;
%       Array2;
%       x(:, 1);
%       y(:, 1);
%       z(:, 1);
%   end
%   % Strict check. First 3 dimensions of both arrays must be exactly
%   %   numel(x) by numel(y) by numel(z).
%   mustHaveValidCoordinateVectors({Array1, Array2}, {x, y, z});
%   
%   % Optionally, ignore dimensions that have empty coordinate vectors.
%   mustHaveValidCoordinateVectors({Array1, Array2}, {x, y, z}, ...
%           AllowEmptyCoord=true);
%
%   % Optionally, allow mismatches on singleton array dimensions.
%   mustHaveValidCoordinateVectors({Array1, Array2}, {x, y, z}, ...
%           AllowBroadcasting=true);
%
%
%   % Use with Repeating arguments block.
%   arguments
%       Array;
%   end
%   arguments (Repeating)
%       coords(:, 1);
%   end
%   mustHaveValidCoordinateVectors({Array}, coords);
%
%
% Inputs:
%   Arrays - Cell array of nd-arrays to check. Will throw an error if they
%       are not the same size or if not broadcastable, depending on the
%       "AllowBroadcasting" option.
%   coords - Cell array of coordinate vectors to check against.
%
% Author: Matt Dvorsky

arguments
    Arrays cell {mustBeNonempty};
    coords cell;
    
    options.AllowEmptyCoord(1, 1) logical = false;
    options.AllowBroadcasting(1, 1) logical = false;
end

%% Check Inputs
try
    if options.AllowBroadcasting
        arrayDims = broadcastSize(Arrays{:}, Dimensions=1:numel(coords));
    else
        mustHaveEqualSizes(Arrays{:});
        arrayDims = size(Arrays{1}, 1:numel(coords));
    end
catch ex
    throwAsCaller(ex);
end

coordDims = cellfun(@numel, coords);

%% Check for Mismatches
dimMismatch = coordDims ~= arrayDims;
if options.AllowEmptyCoord
    dimMismatch = dimMismatch ...
        & cellfun(@numel, coords) ~= 0;
end
if options.AllowBroadcasting
    dimMismatch = dimMismatch ...
        & arrayDims ~= 1;
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
    "coordinate vectors:%s%s    size(Arrays) = [%s]" + ...
    "%s    size(coords) = [%s]", ...
    newline(), newline(), ...
    join(arrayDimStr, ", "), ...
    newline(), ...
    join(coordDimStr, ", ")));

end

