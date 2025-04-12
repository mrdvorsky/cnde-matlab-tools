function [Data, coords] = tableToArray(numDims, DataTable, options)
%Convert a table into a uniform nd-array with grids.
% This functions takes in a Matlab Table, where each row describes a data
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
% Note that the "numDims" argument specifies the expected number of
% dimensions in the gridded data set. By default, the coordinate vectors
% of the data set will be determined using columns 1:numDims in order,
% although this can be changed using the "GridColumns" argument. The order
% of the "GridColumns" argument changes which grid dimension corresponds
% to each column. For example, the nth dimension of the output array(s)
% will be described by the column with index "GridColumns(n)".
%
% Example Usage:
%   % Both use cases below will result in the same output.
%   [Data, x, y] = tableToArray(2, [xCol, yCol, DataCol]);
%   [Data, x, y] = tableToArray(2, table(xCol, yCol, DataCol));
%
%   % Can be done with any number of dimensions.
%   [Data, x, y, z] = tableToArray(3, [xCol, yCol, zCol, DataCol]);
%
%   % Multiple data columns will result in a cell array output.
%   [DataAll, x, y, z] = tableToArray(3, ...
%       [xCol, yCol, zCol, DataCol1, DataCol2, ...]);
%   [Data1, Data2, ...] = DataAll{:};
%
%   % If coordinate grid columns are not first, or if they are in the
%   % wrong order, then the locations can be specified using the
%   % "GridColumns" argument.
%   [Data, x, y] = tableToArray(2, [DataCol, xCol, yCol], ...
%       GridColumns=[2, 3]).
%   [Data, x, y] = tableToArray(2, [yCol, xCol, DataCol], ...
%       GridColumns=[2, 1]).
%
%
% The output data and coordinate vectors are all broadcastable with each
% other and the grid vectors have the correct dimension. This means that
% an operation like "Data = Data - x.*y;" will work as it should.
%
% Inputs:
%   numDims - Number of dimensions described by the input data.
%   Data - Table where each column corresponds to either a grid
%       coordinate or a data point. As described above, the first
%       "numDims" columns should be the n-dimensional coordinates,
%       although this can be changed using the "GridColumns" argument.
%
% Outputs:
%   Data - An nd-array containing the data in the data column. If there
%       are multiple data columns, this argument will be a cell array
%       corresponding to each data column, in the order they appear.
%   [x, y, z, ...] - Grid coordinate vectors, infered from the coordinate
%       vector columns. The dimension of each vector will match the
%       dimension it describes. This means "x" is nx-by-1, "y" is 1-by-ny,
%       "z" is 1-by-1-by-nz, and so on.
%
% Named Arguments:
%   GridColumns (1:numDims) - Array of unique column indices describing
%       which columns of the input are grid coordinates. Specify this if
%       the first columns of the input data are not the grid coordinates or
%       if they are in the wrong order.
%
% Author: Matt Dvorsky

arguments (Input)
    numDims(1, 1) {mustBeInteger, mustBePositive};
    DataTable(:, :) {mustBeNonempty};

    options.GridColumns(1, :) {mustBeValidGridColumns(...
        options.GridColumns, numDims, DataTable)} = 1:numDims;
end

arguments (Output)
    Data;
end
arguments (Output, Repeating)
    coords;
end

%% Check Inputs
numColumns = size(DataTable, 2);

if numColumns <= numel(options.GridColumns)
    error("CNDE:tableToArrayTooFewColumns", ...
        "Not enough columns in table.");
end

%% Determine Grid Vectors
coords = cell(numDims, 1);
gridDimensions = cell(1, numDims);
try
    DataTable = sortrows(DataTable, flip(options.GridColumns));
catch ex
    throw(addCause(ex, MException(...
        "CNDE:tableToArrayNonScalarTableElement", ...
        "The provided table likely has non-scalar elements.")));
end

% Loop over input columns to find grid vectors
currentStep = 1;
for dd = 1:numel(options.GridColumns)
    columnInd = options.GridColumns(dd);

    DataCol = DataTable(:, columnInd);
    if istable(DataTable)
        DataCol = table2array(DataCol);
    end
    gridCoords = reshape(DataCol, currentStep, []);
    [gridValCounts, gridVals] = groupcounts(gridCoords(1, :).');

    % Check that the grid values are repeating with the proper period and
    % that the multiplicities of each value are equal.
    if all(gridCoords(1, :) == gridCoords, "all") ...
            && all(gridValCounts(1) == gridValCounts)
        coords{dd} = vectorize(gridVals, dd);
        currentStep = currentStep * numel(gridVals);
        gridDimensions{dd} = numel(gridVals);
    else
        error("CNDE:tableToArrayNonuniformData", ...
            "Column (%d) of input cannot be arranged into a " + ...
            "uniform grid. Check that the first (%d) columns of " + ...
            "the input are grid coordinates or specify these " + ...
            "columns using the 'GridColumns' argument.", columnInd, numDims);
    end
end

%% Check for Extra Data
extraDimSize = size(DataTable, 1) ./ prod(cell2mat(gridDimensions));
if extraDimSize > 1     %#ok<BDSCI>
    warning("CNDE:tableToArrayExtraDataWarning", ...
        "Extra dimensions found in input data. An additional " + ...
        "dimension (%d) will be added to the output to accommodate " + ...
        "extra data. This is potentially not an issue if " + ...
        "the row order of the input table is consistent, since the " + ...
        "row sorting methods are stable.", numDims + 1);
end

%% Assign Output
dataColumns = setdiff(1:numColumns, options.GridColumns);
Data = cell(numel(dataColumns), 1);
for cc = 1:numel(dataColumns)
    DataCol = DataTable(:, dataColumns(cc));
    if istable(DataTable)
        DataCol = table2array(DataCol);
    end
    Data{cc} = shiftdim(...
        reshape(DataCol, extraDimSize, gridDimensions{:}, []), ...
        1);
end

if isscalar(Data)
    Data = Data{1};
end

end


%% Argument Validation Function
function mustBeValidGridColumns(gridCol, numDims, DataTable)
    mustBeInteger(gridCol);
    mustBePositive(gridCol);
    
    if numel(unique(gridCol)) ~= numel(gridCol) ...
            || numel(gridCol) ~= numDims ...
            || max(gridCol) > size(DataTable, 2)
        throwAsCaller(MException("CNDE:tableToArrayInvalidGridColumn", ...
            "'GridColumns' arguments must contain (%d) unique and " + ...
            "valid column indices.", numDims));
    end
end



