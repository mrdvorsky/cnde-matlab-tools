function [ArraysOut] = broadcastArrays(Arrays)
%Make inputs the same size by duplicating along singleton dimensions.
% This functions takes in multiple nd-arrays with broadcastable sizes (see
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

arguments (Input, Repeating)
    Arrays;
end
arguments (Output, Repeating)
    ArraysOut;
end

if isempty(Arrays)
    return;
end

%% Format Output
maxInputDim = max(cellfun(@(x) ndims(x), Arrays));
inputDims = cell2mat(...
    cellfun(@(x) size(x, 1:maxInputDim).', Arrays, UniformOutput=false)).';
outputDims = broadcastSize(Arrays{:}, Dimension=1:maxInputDim);

ArraysOut = cell(size(Arrays));
if any(outputDims == 0)
    for ii = 1:numel(Arrays)
        ArraysOut{ii} = ones(outputDims, class(Arrays{ii}));
    end
    return;
end

for ii = 1:numel(Arrays)
    ArraysOut{ii} = repmat(Arrays{ii}, outputDims ./ inputDims(ii, :));
end

end

