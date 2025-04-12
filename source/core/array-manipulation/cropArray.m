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
%   coord (Repeating) - Coordinate vector of each dimension. If empty,
%       this dimension will be ignored.
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
    coord(:, 1);
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

mustHaveValidCoordinateVectors({Array}, coord, AllowEmptyCoord=true);

%% Check Input Size
arraySize = size(Array, 1:max([ndims(Array), numel(coord), nargout - 1]));
if numel(coord) < numel(arraySize)
    coordMin = [coordMin, cell(1, numel(arraySize) - numel(coord))];
    coordMax = [coordMax, cell(1, numel(arraySize) - numel(coord))];
    coord = [coord, cell(1, numel(arraySize) - numel(coord))];
end

%% Update Empty Min and Max
for dd = 1:numel(coord)
    if isempty(coord{dd})
        if (~isempty(coordMin{dd}) || ~isempty(coordMax{dd})) ...
                && arraySize(dd) ~= 0
            error("CNDE:cropArrayEmptyCoordWithMinMaxSpecified", ...
                "Coordinate vector for dimension (%d) is empty, " + ...
                "but a min or max value was specified.", dd);
        end
        continue;
    end

    if isempty(coordMin{dd})
        coordMin{dd} = min(coord{dd});
    end

    if isempty(coordMax{dd})
        coordMax{dd} = max(coord{dd});
    end
end


%% Find Valid Range for Each Dimension
isInRange = cell(numel(coord), 1);
for dd = 1:numel(coord)
    if isempty(coord{dd})
        isInRange{dd} = true(arraySize(dd), 1);
        continue;
    end

    cMin = coordMin{dd};
    cMax = coordMax{dd};

    if options.RoundMinMaxToNearestCoord
        [~, minInd] = min(abs(coord{dd} - cMin));
        cMin = coord{dd}(minInd);

        [~, maxInd] = min(abs(coord{dd} - cMax));
        cMax = coord{dd}(maxInd);
    end

    isInRange{dd} = (coord{dd}(:) >= cMin) & (coord{dd}(:) <= cMax);
end

%% Crop Output Array
ArrayOut = Array(isInRange{:});

%% Crop Output Coordinate Vectors
coordsOut = cell(numel(coord), 1);
for dd = 1:numel(coord)
    if isempty(coord{dd})
        coordsOut{dd} = [];
        continue;
    end
    
    coordsOut{dd} = vectorize(coord{dd}(isInRange{dd}), dd);
end

end


