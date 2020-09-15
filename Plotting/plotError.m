function varargout = plotError(x, yAvg, yMin, yMax, varargin)

prevHold = ishold();

h = plot(x, yAvg, varargin{:});
hold on;
fill([x(:); flip(x(:))], [yMin(:); flip(yMax(:))], ...
    get(h, "Color"), "FaceAlpha", 0.25, "EdgeColor", "None", ...
    "HandleVisibility", "Off");

if ~prevHold
    hold off;
end

if nargout == 1
    [varargout{1:nargout}] = h;
end

end

