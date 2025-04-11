function [ArrayPadded, coordsPadded] = zeropadArray(Array, coords, options)
%Zero-pad multidimensional gridded data.
% This function zero-pads data from a multidimensional array, and
% extrapolates the uniform linear grid coordinate vectors.
%
% Example Usage:
%   [Img, x, y] = padArray(Img, x, y, ZeroPadPercent=100);      % Double the size of each dim
%   [Img, ~, ~] = padArray(Img, [], [], ZeroPadPercent=100);    % Same as above 
%   [Img, x, y] = padArray(Img, x, y, ZeroPadPercent=[100, 0]); % Only pad x
%   [Img, x, y] = padArray(Img, x, y, ZeroPadCount=20);         % Pad 20 elements each
%   
%   % Works with any number of dimensions.
%   [Array, x, y, z, ...] = padArray(Array, x, y, z, ...);
%
%
% Inputs:
%   Array - Array to be padded.
%   coords (Repeating) - Coordinate vector of each dimension. If empty,
%       the corresponding dimension will be ignored.
%
% Outputs:
%   ArrayPadded (Repeating) - Padded input array.
%   coordsPadded (Repeating) - Coordinate vector of each dimension,
%       linearly extrapolated to match the "ArrayPadded" size.
%
% Named Arguments:
%   ZeroPadPercent (0) - Percent size increase, either a scalar or an array
%       with values for each dimension.
%   ZeroPadCount - Number of zeros to append, either a scalar or an array
%       with values for each dimension.
%   Direction ("both") - A scalar or vector of strings with "pre", "post",
%       or "both", indicating which side to append zeros. If "both", will
%       split half and half, preferring "pre" for odd counts.
%
% Author: Matt Dvorsky

arguments (Input)
    Array;
end
arguments (Input, Repeating)
    coords(:, 1);
end
arguments (Input)
    options.PadPercent(1, :) {mustBeNonnegative, ...
        mustBeValidPadSpec(options.PadPercent, coords)};
    options.PadCount(1, :) {mustBeNonnegative, ...
        mustBeValidPadSpec(options.PadCount, coords)} = 0;
    options.Direction(1, :) string {mustBeMember(options.Direction, ...
        ["both", "pre", "post"]), ...
        mustBeValidPadSpec(options.Direction, coords)} = "both";
end

arguments (Output)
    ArrayPadded;
end
arguments (Output, Repeating)
    coordsPadded;
end

mustHaveValidCoordinateVectors(Array, coords, AllowEmptyCoord=true);

%% Check Inputs
if isfield(options, "PadPercent") && isscalar(options.PadPercent)
    options.PadPercent = repmat(options.PadPercent, 1, numel(coords));
end

if isscalar(options.PadCount)
    options.PadCount = repmat(options.PadCount, 1, numel(coords));
end

if isscalar(options.Direction)
    options.Direction = repmat(options.Direction, 1, numel(coords));
end

%% Calculate Padding Sizes
arraySize = size(Array, 1:numel(coords));

if isfield(options, "PadPercent")
    options.PadCount = (0.01 * options.PadPercent) ...
        .* arraySize;
end

%% Pad Output Arrays
padCounts = ceil(options.PadCount);

for dd = 1:numel(coords)
    if padCounts(dd) == 0
        continue;
    end

    zeroArray = zeros([size(Array, 1:dd - 1), padCounts(dd), ...
        size(Array, dd + 1:ndims(Array))]);
    if strcmp(options.Direction(dd), "pre")
        Array = cat(dd, zeroArray, Array);
    else
        Array = cat(dd, Array, zeroArray);
        if strcmp(options.Direction(dd), "both")
            Array = circshift(Array, round(0.5 * padCounts(dd)), dd);
        end
    end
end

ArrayPadded = Array;

%% Crop Output Coordinate Vectors
coordsPadded = cell(numel(coords), 1);
for dd = 1:numel(coords)
    if isempty(coords{dd})
        coordsPadded{dd} = [];
        continue;
    end
    
    outputInds = 1:(numel(coords{dd}) + padCounts(dd));
    if strcmp(options.Direction(dd), "pre")
        outputInds = outputInds - padCounts(dd);
    elseif strcmp(options.Direction(dd), "both")
        outputInds = outputInds - round(0.5 * padCounts(dd));
    end

    coordsPadded{dd} = reshape(...
        interp1(coords{dd}(:), outputInds, "linear", "extrap"), ...
        [ones(1, dd - 1), numel(outputInds), 1]);
end

end



%% Argument Validation Functions
function mustBeVectorOrEmpty(coord)
    if isempty(coord)
        return;
    end
    
    if sum(size(coord) ~= 1) > 1
        throwAsCaller(MException("CNDE:mustBeVectorOrEmpty", ...
            "Argument must be a vector or be empty."));
    end
end

function mustBeValidPadSpec(padSpec, coords)
    if any(numel(padSpec) == [1, numel(coords)])
        return;
    end
    throwAsCaller(MException("CNDE:cropArrayMustBeValidPadSpec", ...
        "Value must be scalars or vectors with size matching " + ...
        "the number of grid coordinates."));
end

