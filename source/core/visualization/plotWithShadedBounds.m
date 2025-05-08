function [plotHandle, fillHandle] = plotWithShadedBounds(x, y, yMin, yMax, lineSpec, options, plotOptions)
%Plots a line, along with a shaded region surrounding the line.
% This function plots a single line, and then plots a transparent shaded
% region specified by the input min/max bounds.
%
% Example Usage:
%   figure;
%   plotWithShadedBounds(x, y, yMin, yMax, LineWidth=1.5);
%   hold on;
%   plotWithShadedBounds(x, y2, yMin2, yMax2, ":", LineWidth=1.5);
%
%
% Inputs:
%   x - Input x-coordinates for plot.
%   y - Input y-coordinates for plot.
%   yMin - Input y-coordinates for bottom of shaded region.
%   yMax - Input y-coordinates for top of shaded region.
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
%
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(:, 1) {mustHaveEqualSizes(y, x)};
    yMin(:, 1) {mustHaveEqualSizes(yMin, x)};
    yMax(:, 1) {mustHaveEqualSizes(yMax, x)};

    lineSpec(1, 1) string = "";

    options.ShadedRegionAlpha(1, 1) {mustBeInRange(...
        options.ShadedRegionAlpha, 0, 1)} = 0.25;
    options.ShadedRegionLineWidth(1, 1) {mustBeNonnegative} = 0.5;
    
    options.Axis(1, 1) matlab.graphics.axis.Axes;

    plotOptions.?matlab.graphics.primitive.Line;
end

%% Check Inputs
if ~isfield(options, "Axis")
    options.Axis = gca();
end

%% Plot Line
plotHandle = plot(options.Axis, x, y, lineSpec, plotOptions);

%% Plot Shaded Region
prevHold = ishold(options.Axis);
hold(options.Axis, "on");
fillHandle = fill([x(:); flip(x(:))], [yMin(:); flip(yMax(:))], ...
    plotHandle.Color, ...
    FaceAlpha=options.ShadedRegionAlpha, ...
    EdgeColor=plotHandle.Color, ...
    LineStyle=plotHandle.LineStyle, ...
    HandleVisibility="off");

if options.ShadedRegionLineWidth > 0
    fillHandle.LineWidth = options.ShadedRegionLineWidth;
else
    fillHandle.EdgeColor = "none";
end

%% Revert Hold State
if ~prevHold
    hold(options.Axis, "off");
end

end

