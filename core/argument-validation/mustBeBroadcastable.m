function [] = mustHaveCompatibleSizes(Arrays, options)
%MUSTHAVECOMPATIBLESIZES Validate that input arrays have compatible sizes.
% Throws an error if the input arrays do not have compatible sizes (see
% MATLAB documentation on compatible array sizes for more information).
%
% Example Usage:
%   arguments
%       Array1;
%       Array2 {mustHaveCompatibleSizes(Array1, Array2)};   % Check all dimensions.
%       Array3 {mustHaveCompatibleSizes(Array1, Array2, Array3, ...
%           Dimensions=[1, 3])};
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
arguments
    options.Dimensions(1, :) {mustBeValidDimension} = "all";
    options.ExcludeDimensions(1, :) {mustBeValidDimension} = [];
end

%% Check Sizes
maxInputDim = max(cellfun(@(x) ndims(x), Arrays));
if strcmp(options.Dimensions, "all")
    options.Dimensions = 1:maxInputDim;
end
options.Dimensions = setdiff(options.Dimensions, options.ExcludeDimensions);
maxInputDim = max(maxInputDim, max(options.Dimensions));

inputDims = cell2mat(...
    cellfun(@(x) size(x, 1:maxInputDim).', Arrays, UniformOutput=false)).';
outputDims = max(inputDims, [], 1) .* (min(inputDims, [], 1) ~= 0);

dimMismatch = any((inputDims ~= outputDims) & (inputDims ~= 1), 1);
if any(dimMismatch(options.Dimensions))
    inputDimsString = string(inputDims);
    inputDimsString(:, dimMismatch) = ...
        strcat("*", inputDimsString(:, dimMismatch), "*");

    if isequal(options.Dimensions, 1:maxInputDim)
        dimString = "";
    else
        dimString = sprintf(" along dimensions (%s)", ...
            join(string(options.Dimensions), ", "));
    end

    throwAsCaller(MException("MATLAB:mustHaveCompatibleSizes", ...
        "Arguments must have compatible sizes%s (see MATLAB " + ...
        "documentation on compatible array sizes for " + ...
        "more information):%s%s%s", dimString, newline(), newline(), ...
        join(compose("    size(arg%d) == [%s]", ...
        (1:size(inputDims, 1)).', ...
        join(inputDimsString, ", ", 2)), ...
        newline(), 1)));
end

end

