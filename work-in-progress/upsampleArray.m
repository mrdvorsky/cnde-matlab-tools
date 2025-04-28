function [varargout] = cropArray(Arrays, coord, coordMin, coordMax, options)
%Crop multidimensional gridded data by min and max.
% This function crops data from a multi-dimensional array, where the
% minimum and maximum coordinate values in each dimension are specified.
%
% Example Usage:
%   [Img, x, y] = cropArray(Img, x, xMin, xMax, y, yMin, yMax);
%   [Img, x, y] = cropArray(Img, [], [], [], y, yMin, []);  % Only crop y.
%   [Data, c1, c2, ...] = cropArray(Data, c1, c1Min, c1Max, c2, c2Min, c2Max, ...);
%   
%   % Multiple arrays.
%   [A1, A2, ..., c1, c2, ...] = cropArray({A1, A2, ...}, ...
%                           c1, c1Min, c1Max, c2, c2Min, c2Max, ...);
%
%
% Inputs:
%   Arrays - Array or cell array of "broadcastable" arrays to be cropped.
%   coord (Repeating) - Coordinate vector of each dimension. If empty, this
%       dimension will be ignored.
%   coordMin (Repeating) - Min value of coord to remain in cropped array.
%       If empty, will be equal to "min(coord)".
%   coordMax (Repeating) - Max value of coord to remain in cropped array.
%       If empty, will be equal to "max(coord)".
%
% Outputs:
%   ArraysCropped (Repeating) - Cropped input array or arrays (if cell
%       array input).
%   coordCropped (Repeating) - Cropped coordinate vector of each dimension.
%
% Named Arguments:
%   RoundMinMaxToNearestCoord (false) - If true, round coordMin and
%       coordMax to the nearest value of coord.
%
% Author: Matt Dvorsky

arguments (Input)
    Arrays {mustBeValidArraysArgument};
end
arguments (Repeating)
    coord {mustBeVectorOrEmpty};
    coordMin {mustBeReal, mustBeScalarOrEmpty};
    coordMax {mustBeReal, mustBeScalarOrEmpty};
end
arguments (Input)
    options.RoundMinMaxToNearestCoord(1, 1) logical = false;
end

if ~iscell(Arrays)
    Arrays = {Arrays};
end

%% Check Input Size
compatArraySize = sizeBroadcasted(Arrays{:});
if numel(coord) < numel(compatArraySize)
    coord = [coord, cell(1, numel(compatArraySize) - numel(coord))];
end
compatArraySize = sizeBroadcasted(Arrays{:}, Dimension=1:numel(coord));

%% Find Valid Range for Each Dimension
isInRange = cell(numel(coord), 1);
for ii = 1:numel(isInRange)
    if isempty(coord{ii})
        isInRange{ii} = true(compatArraySize(ii), 1);
        continue;
    elseif (numel(coord{ii}) ~= compatArraySize(ii)) && (compatArraySize(ii) ~= 1)
        error("Coordinate vector for dimension (%d) is not " + ...
            "compatible with input array(s) size.", ii);
    end

    cMin = coordMin{ii};
    if isempty(cMin)
        cMin = min(coord{ii});
    end

    cMax = coordMax{ii};
    if isempty(cMax)
        cMax = max(coord{ii});
    end

    if options.RoundMinMaxToNearestCoord
        [~, minInd] = min(abs(coord{ii} - cMin));
        cMin = coord{ii}(minInd);

        [~, maxInd] = min(abs(coord{ii} - cMax));
        cMax = coord{ii}(maxInd);
    end

    isInRange{ii} = (coord{ii}(:) >= cMin) & (coord{ii}(:) <= cMax);
end

%% Crop Output Arrays
varargout = cell(numel(Arrays) + numel(coord), 1);
for ii = 1:numel(Arrays)
    arraySingletonDims = size(Arrays{ii}, 1:numel(coord)) == 1;
    
    isInRangeTmp = isInRange;
    isInRangeTmp(arraySingletonDims) = {true};
    varargout{ii} = Arrays{ii}(isInRangeTmp{:});
end

%% Crop Output Coordinate Vectors
coordOffset = numel(Arrays);
for ii = 1:numel(coord)
    if isempty(coord{ii})
        varargout{ii + coordOffset} = [];
        continue;
    end
    
    varargout{ii + coordOffset} = reshape(coord{ii}(isInRange{ii}), ...
        [ones(1, ii - 1), sum(isInRange{ii}), 1]);
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
        throwAsCaller(MException("CNDE:mustBeVectorOrEmpty", ...
            "Argument must be a vector or be empty."));
    end
end

