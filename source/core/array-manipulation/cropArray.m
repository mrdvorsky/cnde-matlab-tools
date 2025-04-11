function [ArrayOut, coordsOut] = cropArray(Array, coord, coordMin, coordMax, options)
%Crop multidimensional gridded data by min and max.
% This function crops data from a multi-dimensional array, where the
% minimum and maximum coordinate values in each dimension are specified.
%
% Example Usage:
%   [Img, x, y] = cropArray(Img, x, xMin, xMax, y, yMin, yMax);
%   [Img, x, y] = cropArray(Img, [], [], [], y, yMin, []);  % Only crop y.
%   [Data, c1, c2, ...] = cropArray(Data, c1, c1Min, c1Max, c2, c2Min, c2Max, ...);
%
%
% Inputs:
%   Arrays - Array to be cropped.
%   coord (Repeating) - Coordinate vector of each dimension. If empty, this
%       dimension will be ignored.
%   coordMin (Repeating) - Min value of coord to remain in cropped array.
%       If empty, will be equal to "min(coord)".
%   coordMax (Repeating) - Max value of coord to remain in cropped array.
%       If empty, will be equal to "max(coord)".
%
% Outputs:
%   ArrayCropped - Cropped input array.
%   coordCropped (Repeating) - Cropped coordinate vector of each dimension.
%
% Named Arguments:
%   RoundMinMaxToNearestCoord (false) - If true, round coordMin and
%       coordMax to the nearest value of coord.
%
% Author: Matt Dvorsky

arguments (Input)
    Array;
end
arguments (Input, Repeating)
    coord {mustBeVectorOrEmpty};
    coordMin {mustBeReal, mustBeScalarOrEmpty};
    coordMax {mustBeReal, mustBeScalarOrEmpty};
end
arguments (Input)
    options.RoundMinMaxToNearestCoord(1, 1) logical = false;
end

arguments (Output)
    ArrayOut;
end
arguments (Output, Repeating)
    coordsOut;
end

%% Check Input Size
arraySize = size(Array, 1:max([ndims(Array), numel(coord), nargout - 1]));
if numel(coord) < numel(arraySize)
    coordMin = [coordMin, cell(1, numel(arraySize) - numel(coord))];
    coordMax = [coordMax, cell(1, numel(arraySize) - numel(coord))];
    coord = [coord, cell(1, numel(arraySize) - numel(coord))];
end

%% Find Valid Range for Each Dimension
isInRange = cell(numel(coord), 1);
for ii = 1:numel(isInRange)
    if isempty(coord{ii})
        if (~isempty(coordMin{ii}) || ~isempty(coordMax{ii})) ...
                && (arraySize(ii) > 0)
            error("CNDE:cropArrayEmptyCoordWithMinMaxSpecified", ...
                "Coordinate vector for dimension (%d) is empty, " + ...
                "but a min or max value was specified.", ii);
        end

        isInRange{ii} = true(arraySize(ii), 1);
        continue;
    elseif (numel(coord{ii}) ~= arraySize(ii)) && (arraySize(ii) ~= 1)
        error("CNDE:cropArrayCoordSizeMismatch", ...
            "Coordinate vector for dimension (%d) is not " + ...
            "compatible with input array size.", ii);
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

%% Crop Output Array
ArrayOut = Array(isInRange{:});

%% Crop Output Coordinate Vectors
coordsOut = cell(numel(coord), 1);
for ii = 1:numel(coord)
    if isempty(coord{ii})
        coordsOut{ii} = [];
        continue;
    end
    
    coordsOut{ii} = vectorize(coord{ii}(isInRange{ii}), ii);
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

