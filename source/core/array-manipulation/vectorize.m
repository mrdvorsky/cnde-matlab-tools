function [vec] = vectorize(arrayIn, dim)
%Reshape input array into 1D vector along a specified dimension.
% Linearizes input array and reshapes so that the non-singleton dimension
% is equal to the "dim" argument.
%
% Example Usage:
%   [vec] = vectorize(arr, 1);      % Equivalent to vec(:, 1) = arr(:);
%   [vec] = vectorize(arr, 2);      % Equivalent to vec(1, :) = arr(:);
%   [vec] = vectorize(arr, 3);      % Equivalent to vec(1, 1, :) = arr(:);
%
% If the input array is empty, the output will have size 0 along the
% specified dimension. For example, vectorize([], 3) will have size
% 1-by-1-by-0.
%
% Author: Matt Dvorsky

arguments
    arrayIn;
    dim(1, 1) {mustBePositive, mustBeInteger} = 1;
end

%% Reshape
vec = shiftdim(arrayIn(:), 1 - dim);

end

