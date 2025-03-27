function [onesArray] = ones_like(arrayIn, options)
%Creates an array of ones with the same size as argument.
% Essentially, this is just a shorthand for "ones(size(arrayIn))", if a
% single input is passed in. If multiple arrays are passed, the
% "broadcasted" size will be used instead.
%
% Example Usage:
%   % The output "onesArray" has the same size as "existingArray".
%   [onesArray] = ones_like(existingArray);
%
%   % The output "onesArray" has the "broadcasted" size of all inputs.
%   [onesArray] = ones_like(arr1, arr2, arr3, ...);
%
%
% Author: Matt Dvorsky

arguments (Repeating)
    arrayIn;
end
arguments
    options.Type(1, 1) string {mustBeMember(options.Type, [ ...
        "double", "single", "logical", "int8", "uint8", "int16", ...
        "uint16", "int32", "uint32", "int64", "uint64"])} = "double";
end

%% Create Output Array
onesArray = ones(sizeBroadcasted(arrayIn{:}), options.Type);

end

