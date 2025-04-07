function [AB] = innerProduct(A, B, dims, options)
%Compute the inner product of two arrays along one dimension.
% Functionally equivalent* to the code 'sum(A.*B, dims)', but avoids
% computing the intermediate product 'A.*B' directly. This avoids memory
% overallocation issues caused by the size of 'A.*B 'being too large due to
% singleton dimension expansion. It is also much more efficient for large
% inputs. The 'SummationMode' argument can also be set to "mean", in which
% case the output will be equavalent to 'mean(A.*B, dims)'.
%
% *Note that if 'dims' is an empty array, this function will do nothing,
% while 'sum(A.*B, dims)' will operate along the first non-singleton
% dimension. This function opts for consistent behavior as opposed to
% following the bad example set by the 'sum' function.
%
% Also note that the Matlab function 'dot' does a similar thing but does
% not support many of the features such as singleton expansion and vector
% dimension arguments.
%
% Example Usage:
%   [AB] = innerProduct(A, B, 1);
%   [AB] = innerProduct(A, B, "all");
%   [AB] = innerProduct(A, B, [1, 4], SummationMode="Mean");
%
%
% Inputs:
%   A, B - Input arrays to be multiplied. Must have broadcastable sizes.
%   dim - Dimension to sum along. Can be a positive integer vector or
%       scalar dimension indices or can be the string "all".
% Outputs:
%   AB - Calculated inner product. Equivalent to 'sum(A.*B, dims)'.
%
% Named Arguments:
%   SummationMode ("Sum") - Which mode to use for summation. Must be 
%       either "Sum" or "Mean".
%
% Author: Matt Dvorsky

arguments
    A;
    B {mustBeBroadcastable(A, B)};
    dims(1, :) {mustBeValidDimension};
    options.SummationMode(1, 1)  string ...
        {mustBeMember(options.SummationMode, ["sum", "mean"])} = "sum";
end

%% Check Inputs
AB_size = broadcastSize(A, B);
maxDims = numel(AB_size);

dims = dims(dims <= maxDims);
if strcmp(dims, "all")
    dims = 1:maxDims;
end

outputSize = AB_size;
outputSize(dims) = 1;

if prod(outputSize) == 0
    AB = zeros(outputSize);
    return;
end

%% Deal with Summation Dimensions Where Either A or B are Singleton.
A_singletonDims = intersect(find(size(A, 1:maxDims) == 1), dims);
B_singletonDims = intersect(find(size(B, 1:maxDims) == 1), dims);

A = sum(A, [B_singletonDims, maxDims + 1]);
B = sum(B, [A_singletonDims, maxDims + 1]);

%% Deal with remaining summation dimensions.
remainingDims = setdiff(dims, union(A_singletonDims, B_singletonDims));
dimensionPerm = [remainingDims, setdiff(1:maxDims, remainingDims)];

% Move summation dimensions to the front, if needed.
if ~issorted(dimensionPerm)
    A = permute(A, dimensionPerm);
    B = permute(B, dimensionPerm);
end

A_remainingSize = num2cell(size(A, (numel(remainingDims) + 1):maxDims));
B_remainingSize = num2cell(size(B, (numel(remainingDims) + 1):maxDims));

% Use pagemtimes to do the work.
AB = reshape(pagemtimes(...
    reshape(A, 1, [], A_remainingSize{:}), ...
    reshape(B, [], 1, B_remainingSize{:})), ...
    outputSize);

if strcmp(options.SummationMode, "mean")
    AB = AB .* (prod(outputSize) ./ prod(AB_size));
end

end

