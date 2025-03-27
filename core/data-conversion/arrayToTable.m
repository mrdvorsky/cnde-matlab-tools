function [varargout] = arrayToTable(gridVectors, Data, options)
%Flattens a multi-dimensional array(s) with to table form.
% This function takes an array along with a cell array of grid vectors
% describing each dimension of the array, and flattens it into a table
% where each row contains one elements of the array and its coordinates
% (e.g., each row could be [x, y, z, value]). Multiple inputs arrays can
% be provided, as long as they "broadcastable", each adding an additional
% column to the output.
%
% The output is a 2D array, where each column is either one of the
% linearized input arrays or a coordinate.
% 
% Example Usage:
%   DataTable = arrayToTable({x, y, z}, Data);
%   DataTable = arrayToTable({x, y, z}, Data1, Data2, ...);
%
%   % Coordinates and data outputs can be separated.
%   [xFlat, yFlat, zFlat, DataFlat1, ...] = arrayToTable(...
%       {x, y, z}, Data1, ..., SeparateOutputs=true);
%
%
% Inputs:
%   gridVectors - Cell array of vectors defining grid coordinates for each
%       dimension of the array input(s).
%   Data (Repeating) - Arrays of arbitrary size. All elements must have
%       compatible sizes.
%
% Outputs:
%   DataTable - 2D array, where each column is the linearized column vector
%       corresponding to either the grid coordinates or the array value(s).
%   DataFlat (Repeating) - If SeparateOutputs is true, each output
%       parameter will be a 1D column vector corresponding to the column
%       of the DataTable output above.
%       
% Named Arguments:
%   SeparateOutputs (false) - If true, each output parameter will be a 1D
%       column vector corresponding to each input. If false, the output
%       will be a 2D array made up of these column vectors.
%
% Author: Matt Dvorsky

arguments
    gridVectors(1, :) cell {mustBeNonempty};
end
arguments (Repeating)
    Data {mustBeNonempty};
end
arguments
    options.SeparateOutputs(1, 1) logical = true;
end

%% Check Inputs
% Make all elements of Data be equal size.
[Data{:}] = broadcastArrays(Data{:});

% Check for missing grid vectors.
if numel(gridVectors) < ndims(Data{1})
    warning("Number of grids (%d) is less than the number of " + ...
        "dimensions of Data (%d). Extra grids will be added.", ...
        numel(gridVectors), ndims(Data{1}));
    gridVectors = [gridVectors, arrayfun(@(x) 1:x, ...
        size(Data{1}, numel(gridVectors) + 1:ndims(Data{1})), ...
        UniformOutput=false)];
end

% Make sure grid vector sizes match Data dimension sizes.
for ii = 1:numel(gridVectors)
    if size(Data{1}, ii) ~= numel(gridVectors{ii}) && ...
            size(Data{1}, ii) ~= 1 && numel(gridVectors{ii}) ~= 1
        error("Size mismatch in dimension (%d). The size of Data " + ...
            "along this dimension (%d) and the number of elements " + ...
            "in the corresponding grid vector (%d) must either be " + ...
            "the same or one must be singleton.", ...
            ii, size(Data{1}, ii), numel(gridVectors{ii}));
    end
end

%% Set Outputs
% Reshape each grid vector so that it has the correct vector dimension.
for ii = 1:numel(gridVectors)
    gridVectors{ii} = reshape(gridVectors{ii}, ...
        [ones(1, ii - 1), numel(gridVectors{ii}), 1]);
end

% Use flattenArrays to do the work.
[varargout{1:nargout}] = flattenArrays(gridVectors{:}, Data{:}, ...
    SeparateOutputs=options.SeparateOutputs);

end

