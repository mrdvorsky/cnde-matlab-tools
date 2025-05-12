function [lineHandles, updateFun] = plotComplex(f, val, lineSpec, options, plotOptions)
%Plot a complex-valued function in polar or other formats.
% This function plots complex-valued data in various formats including polar,
% magnitude, dB, phase, real, and imaginary components. It provides interactive
% controls to switch between display formats.
%
% Example Usage:
%   plotComplex(f, val);
%   h = plotComplex(f, val);
%   plotComplex(f, val, DisplayFormat="Polar");
%   plotComplex(f, val, DisplayFormat="dB", AxisRangeDB=40);
%   plotComplex(f, val, "-o", LineWidth=2);
%
%
% If the "DisplayFormat" option is set to "Polar", the complex values will be
% plotted on a polar plot with a unit circle reference. Other formats plot
% the selected component against the frequency (or x-axis) values.
%
% Inputs:
%   f - vector of x-axis values (typically frequency).
%   val - Array containing complex values to plot. Can be a vector or matrix.
%       If a matrix, each column will be plotted as a separate line.
%   lineSpec - (Optional) Line specification string (e.g., '-r' for red solid line).
%
% Outputs:
%   lineHandles - Array of line handles for each plotted line.
%
% Named Arguments:
%   DisplayFormat ("Polar") - Which complex component to show:
%       "Polar" - Complex plane plot with unit circle
%       "Magnitude" - Magnitude vs frequency
%       "dB" - Magnitude in dB vs frequency
%       "Phase" - Phase in degrees vs frequency
%       "Real" - Real component vs frequency
%       "Imag" - Imaginary component vs frequency
%   AxisRangeDB (60) - Range in dB for dB scale plots.
%   Axis (gca()) - Axis on which to plot.
%   AddCustomDataTips (true) - If true, adds detailed data tips showing
%       real/imag/magnitude/phase values.
%   SetAxisLimits (true) - If true, sets appropriate axis limits for each display format.
%   ShowMenu (true) - If true, adds a context menu to change display format.
%
%   plotOptions - Additional line properties can be specified as name-value pairs
%       (e.g., 'LineWidth', 2, 'Marker', 'o').
%
% Author: Matt Dvorsky

arguments
    f(:, 1);
    val(:, :) {mustBeValidPlotData(f, val)};
    lineSpec(1, 1) string = "";

    options.DisplayFormat(1, 1) string {mustBeMember(options.DisplayFormat, ...
        ["Polar", "Magnitude", "dB", "Phase", "Real", "Imag"])} = "Polar";

    options.AxisRangeDB(1, 1) {mustBePositive} = 60;
    options.Axis(1, 1) matlab.graphics.axis.Axes;

    options.AddCustomDataTips(1, 1) logical = true;
    options.SetAxisLimits(1, 1) logical = true;
    options.ShowMenu(1, 1) logical = true;

    plotOptions.?matlab.graphics.primitive.Line;
end

%% Check Inputs
if ~isfield(options, "Axis")
    options.Axis = gca();
end

if isvector(val)
    val = val(:);
end

displayFormatItems = [...
    "Polar", ...
    "Magnitude", ...
    "dB", ...
    "Phase", ...
    "Real", ...
    "Imag", ...
    ];

%% Draw Primary Plot
[xp, yp] = convertData(options, f, val);
lineHandles = plot(options.Axis, xp, yp, lineSpec, plotOptions);

for ii = 1:size(val, 2)
    lineHandles(ii).UserData.f = f;
    lineHandles(ii).UserData.val = val;
end

%% Add Custom Data Tips
if options.AddCustomDataTips
    for ii = 1:size(val, 2)
        dataTipsCustom = [...
            dataTipTextRow("Freq", f, "%.6g GHz"), ...
            dataTipTextRow("Real", real(val(:, ii)), "%.6g"), ...
            dataTipTextRow("Imag", imag(val(:, ii)), "%.6g"), ...
            dataTipTextRow("Mag", abs(val(:, ii)), "%.6g"), ...
            dataTipTextRow("Phase", rad2deg(angle(val(:, ii))), "%.6g deg"), ...
            ];
        
        lineHandles(ii).DataTipTemplate.DataTipRows = dataTipsCustom;
    end
end

%% Draw Unit Circle and Axes
if ~isfield(options.Axis.UserData, "unitCircleHandle")
    theta = linspace(0, 2*pi, 400);
    cx = [cos(theta), nan, 0, 0, nan, -100, 100];
    cy = [sin(theta), nan, -100, 100, nan, 0, 0];

    options.Axis.UserData.unitCircleHandle = line(options.Axis, ...
        cx, cy, ...
        LineStyle=":", ...
        LineWidth=0.5, ...
        SeriesIndex="none", ...
        HitTest="off", ...
        PickableParts="none", ...
        HandleVisibility="off", ...
        AffectAutoLimits="off", ...
        Visible="off");
end

%% Add Menu Items
% Checking for "options" field so that we only do this on the first run.
if options.ShowMenu && ~isfield(options.Axis.UserData, "options")
    fig = ancestor(options.Axis, "matlab.ui.Figure");
    menu = uimenu(fig, Text="Display Format");
    createMenuList(menu, displayFormatItems, options.DisplayFormat, ...
        {@displayFormatUpdateFun, options.Axis});
end

options.Axis.UserData.options = options;
displayFormatUpdateFun(options.DisplayFormat, options.Axis);

end




%% Display Format Update Function
function displayFormatUpdateFun(itemLabel, axisHandle)
    options = axisHandle.UserData.options;
    
    options.DisplayFormat = itemLabel;

    for ii = 1:numel(axisHandle.Children)
        f = axisHandle.Children(ii).UserData.f;
        val = axisHandle.Children(ii).UserData.val;

        [px, py] = convertData(options, f, val);

        axisHandle.Children(ii).XData = px;
        axisHandle.Children(ii).YData = py;
    end

    if strcmp(options.DisplayFormat, "Polar")
        options.Axis.UserData.unitCircleHandle.Visible = "on";
        axis(options.Axis, "image");
    else
        options.Axis.UserData.unitCircleHandle.Visible = "off";
        axis(options.Axis, "normal");
    end

    if options.SetAxisLimits
        switch options.DisplayFormat
            case "Polar"
                xlim(options.Axis, 1.1 * [-1, 1]);
                ylim(options.Axis, 1.1 * [-1, 1]);
            case "Magnitude"
                xlim(options.Axis, [-inf, inf]);
                ylim(options.Axis, 1.0 * [0, 1]);
            case "dB"
                xlim(options.Axis, [-inf, inf]);
                ylim(options.Axis, [-options.AxisRangeDB, 0]);
            case "Phase"
                xlim(options.Axis, [-inf, inf]);
                ylim(options.Axis, [-200, 200]);
            case "Real"
                xlim(options.Axis, [-inf, inf]);
                ylim(options.Axis, 1.0 * [-1, 1]);
            case "Imag"
                xlim(options.Axis, [-inf, inf]);
                ylim(options.Axis, 1.0 * [-1, 1]);
        end
    end
end

%% Data Conversion Helper Function
function [x, y] = convertData(options, f, val)
    switch options.DisplayFormat
        case "Polar"
            x = real(val);
            y = imag(val);
        case "Magnitude"
            x = f;
            y = abs(val);
        case "dB"
            x = f;
            y = 20*log10(abs(val));
        case "Phase"
            x = f;
            y = rad2deg(angle(val));
        case "Real"
            x = f;
            y = real(val);
        case "Imag"
            x = f;
            y = imag(val);
    end
end

%% Menu Items Helper Functions
function createMenuList(menu, displayItems, defaultItem, callback)
    itemsInds = (1:numel(displayItems)) ...
        + numel(menu.Children);

    for ii = 1:numel(displayItems)
        item = uimenu(menu, Text=displayItems(ii), ...
            MenuSelectedFcn={@menuCallbackWrapper, itemsInds, callback});
        if strcmp(displayItems(ii), defaultItem)
            item.Checked = "on";
        end
        if ii == 1
            item.Separator = "on";
        end
    end
end

function menuCallbackWrapper(eventSource, ~, itemsInds, callback)
    numMenuItems = numel(eventSource.Parent.Children);
    for ii = (numMenuItems - itemsInds + 1)
        eventSource.Parent.Children(ii).Checked = "off";
    end
    eventSource.Checked = "on";

    callback{1}(eventSource.Text, callback{2:end});
end

%% Validation Function
function mustBeValidPlotData(f, val)
    if isvector(val)
        return;
    end
    mustHaveEqualSizes(f, val, Dimensions=1);
end


