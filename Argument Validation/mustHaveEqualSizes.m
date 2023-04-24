function [] = mustHaveEqualSizes(Arrays, options)
%MUSTHAVEEQUALSIZES Validate that input arrays have equal sizes.
% Throws an error if the input arrays do not have equal sizes. Optionally,
% only checks specified dimensions for equality.
%
% Example Usage:
%   arguments
%       Array1;
%       Array2 {mustHaveEqualSizes(Array1, Array2)};    % Check all dimensions.
%       Array3 {mustHaveEqualSizes(Array1, Array3, Dimenions=[1, 3])};
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
arguments
    options.Dimensions(1, :) {mustBeValidDimension} = "all";
end

%% Check Sizes
maxInputDim = max(cellfun(@(x) ndims(x), Arrays));
if strcmp(options.Dimensions, "all")
    options.Dimensions = 1:maxInputDim;
end
maxInputDim = max(maxInputDim, max(options.Dimensions));

inputDims = cell2mat(...
    cellfun(@(x) size(x, 1:maxInputDim).', Arrays, UniformOutput=false)).';
outputDims = max(inputDims, [], 1);

dimMismatch = any(inputDims ~= outputDims, 1);
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

    throwAsCaller(MException("MATLAB:mustHaveEqualSizes", ...
        "Arguments must have equal sizes%s:%s%s%s", ...
        dimString, newline(), newline(), ...
        join(compose("    size(arg%d) == [%s]", ...
        (1:size(inputDims, 1)).', ...
        join(inputDimsString, ", ", 2)), ...
        newline(), 1)));
end

end

