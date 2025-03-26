function [ ] = makeLinesUnique( varargin )
%MAKELINESUNIQUE Make lines of a plot unique (using marker and line type)
%   TODO: Add Description (works on active plot), Add settings for order

lineTypes(1, :) = ["-", "--", "-.", ":"];
markerTypes(:, 1) = ["none", "+", "o", "*", "x", "s", "d"];

lineTypes = repmat(lineTypes, size(markerTypes, 1), 1);
markerTypes = repmat(markerTypes, 1, size(lineTypes, 2));

lineTypes = lineTypes.';
markerTypes = markerTypes.';

plotLines = get(gca, "Children");
plotLines = flip(plotLines);

if length(plotLines) > length(lineTypes(:))
    error("Number of lines in plot (%d) is greater than number of line setups", length(plotLines), length(lineTypes(:)));
end

for ii = 1:length(plotLines)
    set(plotLines(ii), "Linestyle", lineTypes(ii), "Marker", markerTypes(ii));
end


end

