function [] = mustHaveCompatibleSizes(Arrays)
%MUSTHAVECOMPATIBLESIZES Validate that input arrays have compatible sizes.
% Throws an error if the input arrays do not have compatible sizes (see
% MATLAB documentation on compatible array sizes for more information).
%
% Example Usage:
%   arguments
%       Array1;
%       Array2 {mustHaveCompatibleSizes(Array1, Array2)};
%       Array3 {mustHaveCompatibleSizes(Array1, Array2, Array3)};
%   end
%
%   arguments (Repeating)
%       Arrays;
%   end
%   mustHaveCompatibleSizes(Arrays{:});
%
% Author: Matt Dvorsky

arguments (Repeating)
    Arrays;
end

%% Check Sizes
maxInputDim = max(cellfun(@(x) ndims(x), Arrays));
inputDims = cell2mat(...
    cellfun(@(x) size(x, 1:maxInputDim).', Arrays, UniformOutput=false)).';
outputDims = max(inputDims, [], 1);

dimMismatch = any((inputDims ~= outputDims) & (inputDims ~= 1), 1);
if any(dimMismatch)
    inputDimsString = string(inputDims);
    inputDimsString(:, dimMismatch) = ...
        strcat("*", inputDimsString(:, dimMismatch), "*");

    throwAsCaller(MException("MATLAB:mustHaveCompatibleSizes", ...
        "Arguments must have compatible sizes (see MATLAB " + ...
        "documentation on compatible array sizes for " + ...
        "more information):%s%s%s", newline(), newline(), ...
        join(compose("    size(arg%d) == [%s]", ...
        (1:size(inputDims, 1)).', ...
        join(inputDimsString, ", ", 2)), ...
        newline(), 1)));
end

end

