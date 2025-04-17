function [DataTable] = arrayToTable(Data, coords)
%Flattens a multi-dimensional array(s) with coordinates to table form.
% This function takes an array along with a cell array of grid vectors
% describing each dimension of the array, and flattens it into a table
% where each row contains one elements of the array and its coordinates
% (e.g., each row could be [x, y, z, value]). Multiple inputs arrays can
% be provided, as long as they "broadcastable", each adding an additional
% column to the output.
%
% ** Note that the inputs can be any type (e.g., strings), and the output
% table columns will preserve the type.
%
% The output is a table, where each column is either one of the
% linearized input arrays or a coordinate, with the type matching the
% input. See below, which shows the table and array forms for a 2D
% example. Note that this function will work for any number of dimensions.
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
% Example Usage:
%   DataTable = arrayToTable(Data, x, y, z, ...);
%
%   % Each data element will add an additional column to the table.
%   DataTable = arrayToTable({Data1, Data2, ...}, x, y, z);
%
%
% Inputs:
%   Data - Nd-array of arbitrary size. Can be a cell array containg
%       multiple nd-arrays of broadcastable sizes.
%   coords (Repeating) - Vectors defining grid coordinates for each
%       dimension of the array input(s). The length of each vector must
%       match the size of the corresponding "Data" dimension.
%
% Outputs:
%   DataTable - Matlab Table, where each column is the linearized column
%       vector corresponding to either the grid coordinates (which will be
%       first) or the nd-array value(s).
%
% Author: Matt Dvorsky

arguments
    Data;
end
arguments (Repeating)
    coords(1, :);
end

if ~iscell(Data)
    Data = {Data};
end
mustHaveValidCoordinateVectors(Data, coords, AllowBroadcasting=true);

%% Check Inputs
% Make all elements of Data be equal size.
[Data{:}] = broadcastArrays(Data{:});

% Check for missing grid vectors.
if numel(coords) < ndims(Data{1})
    warning("arrayToTable:missingGridVectors", ...
        "Number of grids (%d) is less than the number of " + ...
        "dimensions of Data (%d). Extra grids will be added. " + ...
        "It is recommended to have grid vectors for each " + ...
        "non-singleton dimension", ...
        numel(coords), ndims(Data{1}));
    coords = [coords, arrayfun(@(x) 1:x, ...
        size(Data{1}, numel(coords) + 1:ndims(Data{1})), ...
        UniformOutput=false)];
end

%% Set Outputs
[coords{1:numel(coords)}] = ndgrid(coords{:});

[coordAndData{1:(numel(coords) + numel(Data))}] = ...
    broadcastArrays(coords{:}, Data{:});

tableCell = cellfun(@(arr) arr(:), coordAndData, UniformOutput=false);
colNames = [compose("x%d", 1:numel(coords)), ...
    compose("data%d", 1:numel(Data))];

%% Arrange into Matlab Table
DataTable = table(tableCell{:}, ...
    VariableNames=colNames);

end

