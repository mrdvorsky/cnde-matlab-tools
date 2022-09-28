function [varargout] = flattenArrays(Data, options)
%FLATTENARRAYS Flatten multi-dimensional array(s) into 1D vectors.
% This function takes in an arbitrary number of array-valued arguments of
% compatible sizes (see MATLAB documentation on compatible array sizes)
% and linearizes each into a 1D column vector of the same length after
% making each of the inputs the same size by duplicating along singleton
% dimensions.
% 
% The output can be a 2D array, where each column is one of the
% linearized input arrays (default), or each column can be a separate
% output.
%
% Example Usage:
%   ColumnVector = flattenArrays(Data);     % Equivalent to Data(:).
%   DataTable = flattenArrays(Data1, Data2);
%   DataTable = flattenArrays(Data1, Data2, Data3, ...);
%   [DataFlat1, DataFlat2, ...] = flattenArrays(Data1, Data2, ..., 
%       SeparateOutputs=true);
%
% Inputs:
%   Data (Repeating) - Arrays of arbitrary size. All elements must have
%       compatible sizes.
% Outputs:
%   DataTable - 2D array, where each column is the linearized column vector
%       corresponding to each input array.
%   DataFlat (Repeating) - If SeparateOutputs is true, each output
%       parameter will be a 1D column vector corresponding to each input.
%       
% Named Arguments:
%   SeparateOutputs (false) - If true, each output parameter will be a 1D
%       column vector corresponding to each input. If false, the output
%       will be a 2D array made up of these column vectors.
%
% Author: Matt Dvorsky

arguments (Repeating)
    Data {mustBeNonempty};
end

arguments
    options.SeparateOutputs(1, 1) logical = false;
end

%% Set Outputs
% Make all elements of Data be equal size.
[Data{1:length(Data)}] = makeArraysSameSize(Data{:});

% Linearize each input array.
Data = cellfun(@(x) x(:), Data, UniformOutput=false);

if options.SeparateOutputs
    if nargout ~= length(Data)
        warning("Number of output parameters expected to be (%d). " + ...
            "Output may not include all data. Use option " + ...
            "'Output2dArray=true' for a 2D array output.", length(Data));
    end
    varargout = Data;
else
    if nargout > 1
        error("Number of output parameters should be 1. Use option " + ...
            "'Output2dArray=false' to have an output parameter for " + ...
            "each column of the output.");
    end
    varargout{1} = cat(2, Data{:});
end

