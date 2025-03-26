function [dimSizes] = sizeBroadcasted(Arrays, options)
%SIZEBROADCASTED Gets the size vector of the broadcasted version of input arrays.
% The output will be a vector containing the size of all inputs after
% using a binary operation to combine them together. For example,
% 'sizeBroadcasted(A, B, C, Dimension=dims)' is functionally equivalent to
% 'size(A + B + C, dims)', except no actual computation of 'A + B + C' is
% performed.
%
% All inputs must have broadcastable sizes.
%
% Example Usage:
%   newSize = sizeCompatible(A, B, C);
%   newSize = sizeCompatible(A, B, C, ..., Dimension=2);
%   newSize = sizeCompatible(A, B, C, ..., Dimension=1:5);
%   newSize = sizeCompatible(A, B, C, ..., Dimension=[1, 7]);
%
% Inputs:
%   Arrays (repeating) - Input arrays with broadcastable sizes.
% Outputs:
%   dimSizes - Row vector containing the size of each dimension specified
%       by the Dimension named argument.
%
% Named Arguments:
%   Dimension (1:ndims) - Dimensions indices for which to calculate the
%       size. If unspecified, return the size of all dimensions in order.
%
% Author: Matt Dvorsky

arguments (Repeating)
    Arrays;
end
arguments
    options.Dimension(1, :) {mustBeValidDimension} = "all";
end
mustBeBroadcastable(Arrays{:});

%% Calculate Size
numDims = max(cellfun(@ndims, Arrays));

if strcmp(options.Dimension, "all")
    options.Dimension = 1:numDims;
end

ArraySizes = cell2mat(...
    cellfun(@(A) size(A, options.Dimension), Arrays, ...
    UniformOutput=false).');
dimSizes = max(ArraySizes, [], 1) .* (min(ArraySizes, [], 1) ~= 0);

end

