function [varargout] = nearestIndex(xSearchSpace, x)
%Finds index of "xSearchSpace" with the closest value to "x".
% Returns the "subscripts" of the values of the search space that are
% closest to the value that are being searched for.
%
% Essentially, if this function returns subscripts [x1, x2, ...], then the
% element of "xSearchSpace" that is closest to "x(ii)" will be
% "xSearchSpace(x1(ii), x2(ii), ...)".
%
% Example Usage:
%   [xInd] = nearestIndex(xVecSearch, x);
%   [row, col] = nearestIndex(xSearch2D, x);
%   [x1, x2, ...] = nearestIndex(xSearchND, x);
%
%
% Inputs:
%   xSearchSpace - Potentially multi-dimensional array to search.
%   x - Values of x to search for in "xSearchSpace".
%
% Outputs:
%   [x1, x2, ...] - Subscripts of closest element. Each will have the same
%       size as "x".
%
% Author: Matt Dvorsky

arguments
    xSearchSpace {mustBeNonempty};
    x;
end

%% Calculate
xInd = zerosLike(x, Type="double");
for ii = 1:length(x(:))
    [~, xInd(ii)] = min(abs(xSearchSpace(:) - x(ii)));
end

[varargout{1:nargout}] = ind2sub(size(xSearchSpace), xInd);

end

