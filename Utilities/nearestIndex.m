function [ varargout ] = nearestIndex(X, searchX)
%NEARESTINDEX Finds index of value closest to searchX in X
%   X - n-dimensional values to be searched
%   searchX - value of X to search for, can be m-dimentional
%
%   [x1, x2, ..., xn] - Output, each of xi is same size as searchX, and 
%    is the index of the maximum value along the ith dimension of X

xInd = zeros(size(searchX));
for ii = 1:length(searchX(:))
    [~, xInd(ii)] = min(abs(X(:) - searchX(ii)));
end

[varargout{1:nargout}] = ind2sub(size(X), xInd);

end

