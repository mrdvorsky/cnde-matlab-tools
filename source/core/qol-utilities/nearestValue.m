function [xNearest] = nearestValue(xSearchSpace, x)
%Rounds the value(s) of "x" to the nearest value in "xSearchSpace".
% Returns the values of the search space that are closest to the value
% that are being searched for. Essentially, just a shorthand for
% "xSearchSpace(nearestIndex(xSearchSpace, x))"
%
% Example Usage:
%   [xNearest] = nearestValue(xVecSearch, x);
%   [xNearest] = nearestValue(xSearch2D, x);
%   [xNearest] = nearestValue(xSearchND, x);
%
%
% Inputs:
%   xSearchSpace - Potentially multi-dimensional array to search.
%   x - Values of x to be "rounded".
%
% Outputs:
%   [xNearest] - Value of "x", but rounded to the closest value in
%       "xSearchSpace". Has the same size as "x".
%
% Author: Matt Dvorsky

arguments
    xSearchSpace;
    x;
end

%% "Round" to Nearest
xNearest = zerosLike(x, Type=class(xSearchSpace));
xNearest(:) = xSearchSpace(nearestIndex(xSearchSpace, x(:)));

end

