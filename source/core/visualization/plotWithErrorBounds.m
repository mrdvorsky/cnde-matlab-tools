function [plotHandle, fillHandle] = plotWithErrorBounds(x, y, lineSpec, options, plotOptions)
%Plots a line, along with a shaded region surrounding the line.
% This function plots a single line, and then plots a transparent shaded
% region specified by the input min/max bounds.
%
% Example Usage:
%   figure;
%   plotWithShadedBounds(x, y, ErrorBoundType="Std*1");
%   hold on;
%   plotWithShadedBounds(x, y2, ":", LineWidth=1.5);
%
%
% Inputs:
%   x - Input x-coordinates for plot.
%   y - 2D array, where each column has the y-coordinates for the plot.
%   lineSpec - Linespec argument, passed to "plot" function.
%
% Outputs:
%   plotHandle - Output of the "plot" function.
%   fillHandle - Output of the "fill" function.
%
% Named Arguments:
%   ShadedRegionAlpha (0.25) - Alpha value for shaded region.
%   ShadedRegionLineWidth (0.5) - Linewidth for shaded region edge.
%   Axis (gca()) - Axis on which to plot.
%   ErrorBoundType ("MinMax") - What method to use to calculate error
%       bounds. Can be "MinMax", "Std*1", "Std*2", "Std*3".
%
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(:, :) {mustHaveEqualSizes(y, x, Dimensions=1)};

    lineSpec(1, 1) string = "";

    options.ShadedRegionAlpha(1, 1) {mustBeInRange(...
        options.ShadedRegionAlpha, 0, 1)} = 0.25;
    options.ShadedRegionLineWidth(1, 1) {mustBeNonnegative} = 0.5;

    options.Axis(1, 1) matlab.graphics.axis.Axes;

    options.ErrorBoundType(1, 1) string {mustBeMember(...
        options.ErrorBoundType, ...
        ["MinMax", "Std*1", "Std*2", "Std*3"])} = "MinMax";

    plotOptions.?matlab.graphics.primitive.Line;
end

%% Check Inputs
if ~isfield(options, "Axis")
    options.Axis = gca();
end

%% Calculate Min and Max Values
yMean = mean(y, 2);
yMin = min(y, [], 2);
yMax = max(y, [], 2);
if strcmp(options.ErrorBoundType, "Std*1")
    yMin = yMean - 1*std(y, 0, 2);
    yMax = yMean + 1*std(y, 0, 2);
elseif strcmp(options.ErrorBoundType, "Std*2")
    yMin = yMean - 2*std(y, 0, 2);
    yMax = yMean + 2*std(y, 0, 2);
elseif strcmp(options.ErrorBoundType, "Std*3")
    yMin = yMean - 3*std(y, 0, 2);
    yMax = yMean + 3*std(y, 0, 2);
end

%% Plot Line
plotOptionsCell = namedargs2cell(plotOptions);
[plotHandle, fillHandle] = plotWithShadedBounds(x, yMean, yMin, yMax, ...
    lineSpec, ...
    plotOptionsCell{:}, ...
    Axis=options.Axis, ...
    ShadedRegionAlpha=options.ShadedRegionAlpha, ...
    ShadedRegionLineWidth=options.ShadedRegionLineWidth);

end

