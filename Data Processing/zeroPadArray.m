function [varargout] = zeroPadArray(Arrays, coord, options)
%ZEROPADARRAY Zero pad multidimensional gridded data.
% This function zero pads data from a multidimensional array, and
% extrapolates the uniform linear grid coordinate vectors.
%
% Example Usage:
%   [Img, x, y] = zeroPadArray(Img, x, y, ZeroPadPercent=100);      % Double dim sizes
%   [Img, x, y] = zeroPadArray(Img, x, y, ZeroPadPercent=[100, 0]); % Only pad x
%   [Img, x, ~] = zeroPadArray(Img, x, [], ZeroPadPercent=100);     % Only pad x
%   [Img, ~, y] = zeroPadArray(Img, [], y, ZeroPadCount=20);        % Pad 20 elements each
%   [Img, x, y, ...] = zeroPadArray(Img, x, y, ...);
%   [Img1, Img2, ... , x, y, ...] = zeroPadArray({Img1, Img2, ...}, x, y, ...);
%
% Inputs:
%   Arrays - Array or cell array of compatible arrays to be cropped.
%   coord (Repeating) - Coordinate vector of each dimension. If empty, this
%       dimension will be ignored.
%
% Outputs:
%   ArraysCropped (Repeating) - Padded input array or arrays (if cell
%       array input).
%   coordCropped (Repeating) - Padded coordinate vector of each dimension.
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

arguments
    Arrays {mustBeValidArraysArgument};
end

arguments (Repeating)
    coord {mustBeVectorOrEmpty};
end

arguments
    options.ZeroPadPercent(1, :) {mustBeNonnegative};
    options.ZeroPadCount(1, :) {mustBeNonnegative} = 0;
    options.Direction(1, :) {mustBeMember(options.Direction, ...
        ["both", "pre", "post"])} = "both";
end

if ~iscell(Arrays)
    Arrays = {Arrays};
end

%% Check Inputs
if isfield(options, "ZeroPadPercent") && numel(options.ZeroPadPercent) == 1
    options.ZeroPadPercent = repmat(options.ZeroPadPercent, 1, numel(coord));
end

if numel(options.ZeroPadCount) == 1
    options.ZeroPadCount = repmat(options.ZeroPadCount, 1, numel(coord));
end

if numel(options.Direction) == 1
    options.Direction = repmat(options.Direction, 1, numel(coord));
end

if (isfield(options, "ZeroPadPercent") ...
        && numel(options.ZeroPadPercent) ~= numel(coord)) ...
        || numel(options.ZeroPadCount) ~= numel(coord) ...
        || numel(options.Direction) ~= numel(coord)
    error("'ZeroPadPercent', 'ZeroPadCount', and 'Direction' must be " + ...
        "scalars or vectors with size matching the number of " + ...
        "grid coordinates.");
end

%% Calculate Padding Sizes
compatArraySize = sizeCompatible(Arrays{:}, Dimension=1:numel(coord));

if isfield(options, "ZeroPadPercent")
    options.ZeroPadCount = (0.01 * options.ZeroPadPercent) ...
        .* compatArraySize;
end

%% Pad Output Arrays
padCounts = ceil(options.ZeroPadCount);
varargout = cell(numel(Arrays) + numel(coord), 1);
for ii = 1:numel(Arrays)
    for dd = 1:numel(coord)
        if isempty(coord{dd})
            continue;
        end
        if size(Arrays{ii}, dd) ~= numel(coord{dd})
            if size(Arrays{ii}, dd) == 1
                continue;
            end
            error("Grid coordinate vectors must match the array size(s).");
        end

        zeroArray = zeros([size(Arrays{ii}, 1:dd - 1), padCounts(dd), ...
            size(Arrays{ii}, dd + 1:ndims(Arrays{ii}))]);
        if strcmp(options.Direction(dd), "pre")
            Arrays{ii} = cat(dd, zeroArray, Arrays{ii});
        else
            Arrays{ii} = cat(dd, Arrays{ii}, zeroArray);
            if strcmp(options.Direction(dd), "both")
                Arrays{ii} = circshift(Arrays{ii}, round(0.5 * padCounts(dd)), dd);
            end
        end
    end

    varargout{ii} = Arrays{ii};
end

%% Crop Output Coordinate Vectors
coordOffset = numel(Arrays);
for dd = 1:numel(coord)
    if isempty(coord{dd})
        varargout{dd + coordOffset} = [];
        continue;
    end
    
    outputInds = 1:(numel(coord{dd}) + padCounts(dd));
    if strcmp(options.Direction(dd), "pre")
        outputInds = outputInds - padCounts(dd);
    elseif strcmp(options.Direction(dd), "both")
        outputInds = outputInds - round(0.5 * padCounts(dd));
    end

    varargout{dd + coordOffset} = reshape(...
        interp1(coord{dd}(:), outputInds, "linear", "extrap"), ...
        [ones(1, dd - 1), numel(outputInds), 1]);
end

end

%% Argument Validation Functions
function mustBeValidArraysArgument(Arrays)
    if iscell(Arrays)
        mustHaveCompatibleSizes(Arrays{:});
        return;
    end
end

function mustBeVectorOrEmpty(coord)
    if isempty(coord)
        return;
    end
    
    if sum(size(coord) ~= 1) > 1
        throwAsCaller(MException("MATLAB:mustBeVectorOrEmpty", ...
            "Argument must be a vector or be empty."));
    end
end

