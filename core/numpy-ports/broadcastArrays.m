function [varargout] = broadcastArrays(Arrays)
%Make inputs the same size by duplicating along singleton dimensions.
% This functions takes in multiple nd-arrays with compatible sizes (see
% MATLAB documentation on compatible array sizes) and returns each after
% duplicating along any singleton dimensions such that all have the same
% size.
%
% Example Usage:
%   % x and y will be 5-by-5
%   [x, y] = broadcastArrays(ones(5, 1), ones(1, 5));
%
%   % x and y will be 5-by-6-by-7
%   [x, y] = broadcastArrays(ones(5, 6, 1), ones(5, 1, 7));
%
%   % Error: Dimension 2 mismatch
%   [x, y] = broadcastArrays(ones(5, 6), ones(1, 5));
%
%
% Inputs:
%   Arrays (Repeating) - Arrays with compatible sizes.
%
% Outputs:
%   ArraysOut (Repeating) - Input arrays after duplicating data.
%
% Author: Matt Dvorsky

arguments (Repeating)
    Arrays;
end
mustHaveCompatibleSizes(Arrays{:});

%% Format Output
maxInputDim = max(cellfun(@(x) ndims(x), Arrays));
inputDims = cell2mat(...
    cellfun(@(x) size(x, 1:maxInputDim).', Arrays, UniformOutput=false)).';
outputDims = max(inputDims, [], 1);

varargout = cell(size(Arrays));
for ii = 1:numel(Arrays)
    varargout{ii} = repmat(Arrays{ii}, outputDims ./ inputDims(ii, :));
end

end

