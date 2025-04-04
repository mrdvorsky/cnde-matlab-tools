function [zerosArray] = zeros_like(arrayIn, options)
%Creates an array of zeros with the same size as argument.
% Essentially, this is just a shorthand for "zeros(size(arrayIn))", if a
% single input is passed in. If multiple arrays are passed, the
% "broadcasted" size will be used instead.
%
% Example Usage:
%   % The output "zerosArray" has the same size as "existingArray".
%   [zerosArray] = zeros_like(existingArray);
%
%   % The output "zerosArray" has the "broadcasted" size of all inputs.
%   [zerosArray] = zeros_like(arr1, arr2, arr3, ...);
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
zerosArray = zeros(broadcastSize(arrayIn{:}), options.Type);

end

