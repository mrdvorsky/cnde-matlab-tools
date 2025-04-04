function [varargout] = tableToArray(numDims, Data, options)
%Convert a 2D table into a uniform nd-array with grids.
% This functions takes in a 2D array, where each row describes a data
% point(s) with coordinates (e.g., each row is [x, y, z, d1, d2, ...]),
% and returns a multi-dimensional array(s) describing each data column
% along with grid vectors describing each dimension. The 2D array
% must describe a full (i.e., non-sparse) uniform data set. This function
% is the inverse of "arrayToTable".
%
% The typical use of this function is to convert the table on the left to
% the dense nd-array form on the right. The example below is for a 2D
% array, but of course this works for any number of dimensions. The
% ordering of the table rows will not affect the output.
%
%       *Table Form*
%   +-----+-----+------+
%   |  x  |  y  | Data |
%   +-----+-----+------+
%   | -2  | -1  |  d1  |                            *Array Form*
%   |  0  | -1  |  d2  |                      |-----+----------------+
%   |  1  | -1  |  d3  |                      | x\y |  -1    0    1  |
%   |  9  | -1  |  d4  |                      |-----+----------------+
%   | -2  |  0  |  d5  |  -- tableToArray --> | -2  |  d1   d5   d9  |
%   |  0  |  0  |  d6  | <-- arrayToTable --  |  0  |  d2   d6   d10 |
%   |  1  |  0  |  d7  |                      |  1  |  d3   d7   d11 |
%   |  9  |  0  |  d8  |                      |  9  |  d4   d8   d12 |
%   | -2  |  1  |  d9  |                      |-----+----------------+
%   |  0  |  1  |  d10 |
%   |  1  |  1  |  d11 |
%   |  9  |  1  |  d12 |
%   +-----+-----+------+
%
% Note that the input data can also be specified as multiple 1D/2D
% arrays with the same number of rows that will be concatenated
% column-wise. The "numDims" argument specifies the expected number of
% dimensions in the gridded data set. By default, the dimensions of the
% data set will be determined using columns 1:numDims in order, although
% this can be changed using the "GridColumns" argument. The order of the
% "GridColumns" argument changes which grid dimension corresponds to each
% column. For example, the first dimension of the output array(s) will be
% described by the column with index "GridColumns(1)".
%
% Example Usage:
%   % These two calls do the same thing.
%   [x, y, Data] = tableToArray(2, xFlat, yFlat, DataFlat);
%   [x, y, Data] = tableToArray(2, [xFlat, yFlat, DataFlat]);
%
%   % Can be done with any number of dimensions.
%   [x, y, z, Data] = tableToArray(3, xFlat, yFlat, zFlat, DataFlat);
%   [x, y, z, Data1, Data2, ...] = tableToArray(3, ...
%       xFlat, yFlat, zFlat, DataFlat1, DataFlat2, ...);
%
%   % If coordinate grid columns are not first, or if they are in the
%   %  wrong order, then the locations can be specified using the
%   %  "GridColumns" argument.
%   [Data, x, y] = tableToArray(2, DataFlat, xFlat, yFlat, ...
%       GridColumns=[2, 3]).
%   [x, y, Data] = tableToArray(2, xFlat, yFlat, DataFlat, ...
%       GridColumns=[2, 1]).    % Data will be numel(y)-by-numel(x)
%
%
% The output data and coordinate vectors are all broadcastable with each
% other and the grid vectors have the correct dimension. This means that
% an operation like "Data = Data - x.*y;" will work as it should.
%
% Inputs:
%   numDims - Number of dimensions described by the input data.
%   Data (Repeating) - 1D/2D array where each column corresponds to either
%       a grid coordinate or a data point. All arrays must have the same
%       number of rows and will be concatenated together.
%
% Outputs:
%   The position of each output parameter will match the index of the
%       column it corresponds to. Each is either a grid coordinate or a
%       data array, depending on which columns were specified by the
%       "GridColumns" argument.
%   [x, y, z, ...] - Grid coordinate vectors. The dimension of each vector
%       will match the dimension it describes. By default, this means x
%       is nx-by-1, y is 1-by-ny, z is 1-by-1-by-nz, and so on.
%   [Data1, Data2, ...] - The data for each data column organized into an
%       nd-array. Permuting the "GridColumns" argument corresponds to
%       permuting the dimensions of the array.
%
% Named Arguments:
%   GridColumns (1:numDims) - Array of unique column indices describing
%       which columns of the input are grid coordinates. Specify this if
%       the first columns of the input data are not the grid coordinates or
%       if you want to reorder the dimensions of the output.
%
% Author: Matt Dvorsky

arguments
    numDims(1, 1) {mustBeInteger, mustBePositive};
end
arguments (Repeating)
    Data(:, :) {mustBeNonempty};
end
arguments
    options.GridColumns(1, :) {mustBeInteger, mustBePositive} = [];
end

%% Check Inputs
% Concatenate Data cell array into one 2D table.
Data = cat(2, Data{:});

% Get number of columns.
numColumns = size(Data, 2);

if isempty(options.GridColumns)
    options.GridColumns = 1:numDims;
end
if ~all(options.GridColumns >= 1 & options.GridColumns <= numColumns) ...
        || numel(unique(options.GridColumns)) ~= numDims
    error("'GridColumns' arguments must contain (%d) unique and " + ...
        "valid column indices.", numDims);
end

%% Determine Grid Vectors
varargout = cell(numColumns, 1);
gridDimensions = cell(1, numDims);
Data = sortrows(Data, flip(options.GridColumns), ...
    ComparisonMethod="real");

% Loop over input columns to find grid vectors
currentStep = 1;
for ii = 1:numel(options.GridColumns)
    columnInd = options.GridColumns(ii);

    gridCoords = reshape(Data(:, columnInd), currentStep, []);
    [gridValCounts, gridVals] = groupcounts(gridCoords(1, :).');

    % Check that the grid values are repeating with the proper period and
    % that the multiplicities of each value are equal.
    if all(gridCoords(1, :) == gridCoords, "all") ...
            && all(gridValCounts(1) == gridValCounts)
        varargout{columnInd} = reshape(gridVals, ...
            [ones(1, columnInd - 1), numel(gridVals), 1]);
        currentStep = currentStep * numel(gridVals);
        gridDimensions{ii} = numel(gridVals);
    else
        error("Column (%d) of input cannot be arranged into a " + ...
            "uniform grid. Check that the first (%d) columns of " + ...
            "the input are grid coordinates or specify these " + ...
            "columns using the 'GridColumns' argument.", columnInd, numDims);
    end
end

%% Check for Extra Data
extraDimSize = size(Data, 1) ./ prod(cell2mat(gridDimensions));
if extraDimSize > 1     %#ok<BDSCI>
    warning("Extra dimensions found in input data. An additional " + ...
        "dimenion (%d) will be added to the output to accommodate " + ...
        "extra data.", numDims + 1);
    
    % Reorganize extra dimension so it is last.
    Data = reshape(pagetranspose(reshape(Data, extraDimSize, [], numColumns)), ...
        [], numColumns);
end

%% Assign Output
for cc = 1:numColumns
    if isempty(varargout{cc})
        varargout{cc} = reshape(Data(:, cc), gridDimensions{:}, []);
    end
end

end



