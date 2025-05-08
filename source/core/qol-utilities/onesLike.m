function [onesArray] = onesLike(arrayIn, options)
%Creates an array of ones with the same size as argument.
% Essentially, this is just a shorthand for "ones(size(arrayIn))", if a
% single input is passed in. If multiple arrays are passed, the
% "broadcasted" size will be used instead.
%
% The type of the output array can be specified using the "Type" named
% argument, otherwise it will be inferred such that the type of
% "onesLike(A, B, C, ...)" will be the same type as 
% "1 + 0*(A + B + C + ...)" if possible, or it will be "double";
%
% Example Usage:
%   % The output "onesArray" has the same size and type as "existingArray".
%   [onesArray] = onesLike(existingArray);
%
%   % The output "onesArray" has the "broadcasted" size of all inputs.
%   [onesArray] = onesLike(arr1, arr2, arr3, ...);
%
%   % The type of the output "onesArray" will be "single".
%   [onesArray] = onesLike(arr1, arr2, arr3, ..., Type="single");
%
%
% Author: Matt Dvorsky

arguments (Repeating)
    arrayIn;
end
arguments
    options.Type(1, 1) string {mustBeMember(options.Type, ["infer", ...
        "double", "single", "logical", "int8", "uint8", "int16", ...
        "uint16", "int32", "uint32", "int64", "uint64"])} = "infer";
end
mustHaveAtLeastOneRepeatingArg(arrayIn);

%% Create Output Array
if strcmp(options.Type, "infer")
    try
        A = zeros(1, like=arrayIn{1});
        for ii = 2:numel(arrayIn)
            A = A + zeros(1, like=arrayIn{ii});
        end
        options.Type = class(A);
    catch ex
        if ~any(strcmp(ex.identifier, ...
                ["MATLAB:zeros:invalidInputClass", ...
                "MATLAB:mixedClasses"]))
            rethrow(ex);
        end
        options.Type = "double";
    end
end
onesArray = ones(broadcastSize(arrayIn{:}), options.Type);

end

