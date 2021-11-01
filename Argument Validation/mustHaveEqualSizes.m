function [] = mustHaveEqualSizes(Arrays)
%MUSTHAVEEQUALSIZES Validate that input arrays have equal sizes.
% Throws an error if the input arrays do not have equal sizes.
%
% Example Usage:
%   arguments
%       Array1;
%       Array2 {mustHaveEqualSizes(Array1, Array2)};
%       Array3 {mustHaveEqualSizes(Array1, Array3)};
%   end
%
%   arguments (Repeating)
%       Arrays;
%   end
%   mustHaveEqualSizes(Arrays{:});
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

dimMismatch = any(inputDims ~= outputDims, 1);
if any(dimMismatch)
    inputDimsString = string(inputDims);
    inputDimsString(:, dimMismatch) = ...
        strcat("*", inputDimsString(:, dimMismatch), "*");

    throwAsCaller(MException("MATLAB:mustHaveEqualSizes", ...
        "Arguments must have equal sizes:%s%s%s", newline(), newline(), ...
        join(compose("    size(arg%d) == [%s]", ...
        (1:size(inputDims, 1)).', ...
        join(inputDimsString, ", ", 2)), ...
        newline(), 1)));
end

end

