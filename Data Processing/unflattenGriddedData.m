function [varargout] = unflattenGriddedData(numDims, Data, options)
%UNFLATTENGRIDDATA Convert a 2D table into a uniform nd-array with grids.
% This functions takes in a 2D array, where each row describes a data
% point(s) with coordinates (e.g., each row is [x, y, z, d1, d2, ...]),
% and returns a multi-dimensional array(s) describing each data column
% along with grid vectors describing each dimension. The 2D array
% (obviously) must describe a full (i.e., non-sparse) uniform data set.
% This function is the inverse of "flattenGriddedData".
%
% The input data can be specified as a single 2D array, or multiple 1D/2D
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
%   [x, y, Data] = unflattedGriddedData(2, xFlat, yFlat, DataFlat).
%   [x, y, Data] = unflattedGriddedData(2, DataFlat2D).
%   [x, y, Data] = unflattedGriddedData(2, [xFlat, yFlat, DataFlat]).
%   [x, y, z, Data] = unflattedGriddedData(3, xFlat, yFlat, zFlat, DataFlat).
%   [x, y, z, Data1, Data2, ...] = unflattedGriddedData(3, ...
%       xFlat, yFlat, zFlat, DataFlat1, DataFlat2, ...).
%
%   [Data, x, y] = unflattedGriddedData(2, DataFlat, xFlat, yFlat, ...
%       GridColumns=[2, 3]).
%   [x, y, Data] = unflattedGriddedData(2, xFlat, yFlat, DataFlat, ...
%       GridColumns=[2, 1]).    % Data will be length(y)-by-length(x)
%
% The output data and coordinate vectors are all compatible with each
% other and the grid vectors have the correct dimension. This means that
% an operation like "Data = Data - x.*y;" will work as it should.
%
% Inputs:
%   numDims - Number of dimensions described by the input data.
%   Data (Repeating) - 1D/2D array where each column corresponds to either
%       a grid coordinate or a data point. All arrays must have the same
%       number of rows and will be concatenated together.
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
    Data(:, :) {mustBeNonempty};
    options.GridColumns(1, :) {mustBeInteger, mustBePositive} = [];
end

%% Check Inputs
if isempty(options.GridColumns)
    options.GridColumns = 1:numDims;
end
if ~all(options.GridColumns >= 1 & options.GridColumns <= size(Data, 2)) ...
        || numel(unique(options.GridColumns)) ~= numDims
    error("'GridColumns' arguments must contain (%d) unique and " + ...
        "valid column indices.", numDims);
end

%% Determine Grid Vectors
varargout = cell(size(Data, 2), 1);
gridDimensions = cell(1, numDims);
Data = sortrows(Data, flip(options.GridColumns));

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
if prod(cell2mat(gridDimensions)) ~= size(Data, 1)
    warning("Extra dimensions found in input data. An additional " + ...
        "dimenion (%d) will be added to the output to accommodate " + ...
        "extra data.", numDims + 1);
end

%% Assign Output
for cc = 1:size(Data, 2)
    if isempty(varargout{cc})
        varargout{cc} = reshape(Data(:, cc), gridDimensions{:}, []);
    end
end

end



