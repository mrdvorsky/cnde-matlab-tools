function varargout = plotErrorAuto(x, y, varargin)

yS = squeeze(y);
xS = squeeze(x);

if ~isvector(xS)
    error("First argument must be a vector.");
end
if ndims(yS) > 2
    error("Second argument must have no more than 2 dimensions.");
end

if size(yS, 1) == length(xS)
    yDim = 2;
else
    yDim = 1;
end

yAvg = mean(yS, yDim);
yMin = min(yS, [], yDim);
yMax = max(yS, [], yDim);

[varargout{1:nargout}] = plotError(x, yAvg, yMin, yMax, varargin{:});

end

