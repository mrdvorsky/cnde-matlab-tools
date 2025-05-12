function [plotHandle, fillHandle] = plotWithShadedBounds(x, y, yMin, yMax, lineSpec, options, plotOptions)
%Plot a line with shaded bounds showing min/max or confidence intervals.
% This function creates a line plot with a semi-transparent shaded region
% between specified minimum and maximum bounds, useful for visualizing
% uncertainty ranges or confidence intervals.
%
% ===== Basic Usage =====
%   plotWithShadedBounds(x, y, yMin, yMax);
%   h = plotWithShadedBounds(x, y, yMin, yMax, "r-", LineWidth=1.5);
%
% ===== Multiple Plots =====
%   figure;
%   plotWithShadedBounds(x, y1, yMin1, yMax1);
%   hold on;
%   plotWithShadedBounds(x, y2, yMin2, yMax2, '--');
%
%
% Inputs:
%   x      - Vector of x-coordinates.
%   y      - Vector of y-coordinates (central line).
%   yMin   - Vector of lower bound values.
%   yMax   - Vector of upper bound values.
%   lineSpec ("") - Line style specification (same as "plot" function).
%
% Outputs:
%   plotHandle - Handle to the line plot object.
%   fillHandle - Handle to the shaded region patch object.
%
% Options (name-value pairs):
%   ShadedRegionAlpha (0.25) - Transparency of shaded region (0-1).
%   ShadedRegionLineWidth (0.5) - Edge line width of shaded region
%                                 (set to 0 for no edge).
%   Axis (gca) - Target axes for plotting.
%
%   plotOptions - Additional line properties (name-value pairs):
%                 Any valid Line property (e.g., 'LineWidth', 'Color').
%                 See the "plot" function for more details.
%
% Notes:
%   - Shaded region automatically matches the line color.
%   - Maintains hold state of the target axes.
%   - For statistical bounds, see plotWithErrorBounds.
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
fillHandle = fill(options.Axis, ...
    [x(:); flip(x(:))], [yMin(:); flip(yMax(:))], ...
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

