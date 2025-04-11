function [dimSizes] = broadcastSize(Arrays, options)
%Gets the size vector of the broadcasted version of input arrays.
% The output will be a vector containing the size of all inputs after
% using a binary operation to combine them together. For example,
% 'broadcastSize(A, B, C, Dimensions=dims)' is functionally equivalent to
% 'size(A + B + C, dims)', except no actual computation of 'A + B + C' is
% performed.
%
% Example Usage:
%   dimSizes = broadcastSize(A, B);
%   dimSizes = broadcastSize(A, B, C);
%   dimSizes = broadcastSize(A, B, C, ..., Dimensions=2);
%   dimSizes = broadcastSize(A, B, C, ..., Dimensions=1:5);
%   dimSizes = broadcastSize(A, B, C, ..., Dimensions=[1, 7]);
%
%
% Inputs:
%   Arrays (repeating) - Input arrays with broadcastable sizes.
%
% Outputs:
%   dimSizes - Row vector containing the size of each dimension specified
%       by the Dimension named argument.
%
% Named Arguments:
%   Dimensions (1:ndims) - Dimensions indices for which to calculate the
%       size. If unspecified, return the size of all dimensions in order.
%
% Author: Matt Dvorsky

arguments (Repeating)
    Arrays;
end
arguments
    options.Dimensions(1, :) {mustBeValidDimension} = "all";
end
mustBeNonemptyRepeatingArgs(Arrays);
mustBeBroadcastable(Arrays{:});

%% Calculate Size
numDims = max(cellfun(@ndims, Arrays));

if strcmp(options.Dimensions, "all")
    options.Dimensions = 1:numDims;
end

ArraySizes = cell2mat(...
    cellfun(@(A) size(A, options.Dimensions), Arrays, ...
    UniformOutput=false).');
dimSizes = max(ArraySizes, [], 1) .* (min(ArraySizes, [], 1) ~= 0);

end

