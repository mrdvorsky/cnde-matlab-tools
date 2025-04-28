function [onesArray] = onesLike(arrayIn, options)
%Creates an array of ones with the same size as argument.
% Essentially, this is just a shorthand for "ones(size(arrayIn))", if a
% single input is passed in. If multiple arrays are passed, the
% "broadcasted" size will be used instead.
%
% Example Usage:
%   % The output "onesArray" has the same size and type as "existingArray".
%   [onesArray] = onesLike(existingArray);
%
%   % The output "onesArray" has the "broadcasted" size of all inputs.
%   [onesArray] = onesLike(arr1, arr2, arr3, ...);
%   
%   Force a specific type.
%   [onesArray] = onesLike(arr1, arr2, arr3, ..., Type="uint8");
%
%
% Author: Matt Dvorsky

arguments (Repeating)
    arrayIn;
end
arguments
    options.Type(1, 1) string {mustBeMember(options.Type, [ ...
        "infer", "double", "single", "logical", "int8", "uint8", "int16", ...
        "uint16", "int32", "uint32", "int64", "uint64"])} = "infer";
end

%% Create Output Array
onesArray = ones(sizeBroadcasted(arrayIn{:}), options.Type);

end

