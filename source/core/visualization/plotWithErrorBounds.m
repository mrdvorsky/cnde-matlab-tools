function [plotHandle, fillHandle] = plotWithErrorBounds(x, y, lineSpec, options, plotOptions)
%Plot data with automatically calculated error bounds.
% This function plots the mean of input data with shaded regions
% representing different statistical bounds (min/max, ±1σ, ±2σ, or ±3σ).
%
% ===== Basic Usage =====
%   plotWithErrorBounds(x, yData);
%   h = plotWithErrorBounds(x, yData, "b-", ErrorBoundType="Std*2");
%
% ===== Multiple Plots =====
%   figure;
%   plotWithErrorBounds(x, yData1, ErrorBoundType="Std*1");
%   hold on;
%   plotWithErrorBounds(x, yData2, ":", ErrorBoundType="MinMax");
%
%
% Inputs:
%   x      - Vector of x-coordinates
%   y      - Matrix where each column represents a different
%            measurement/sample and rows correspond to x-values.
%   lineSpec ("") - Line style specification (same as "plot" function).
%
% Outputs:
%   plotHandle - Handle to the mean line plot object.
%   fillHandle - Handle to the error bound patch object.
%
% Options (name-value pairs):
%   ErrorBoundType ("MinMax") - Statistical bound calculation method:
%       "MinMax" - Minimum and maximum bounds.
%       "Std*1"  - Mean ±1 standard deviation.
%       "Std*2"  - Mean ±2 standard deviations.
%       "Std*3"  - Mean ±3 standard deviations.
%
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
%   - Automatically calculates mean and specified bounds.
%   - Shaded region matches line color automatically.
%   - For pre-calculated bounds, use plotWithShadedBounds.
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

