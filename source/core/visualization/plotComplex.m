function [lineHandles, updateFun] = plotComplex(f, val, lineSpec, options, plotOptions)
%Plot complex-valued data with interactive format control and dynamic updates.
% This function visualizes complex-valued data in various formats (polar,
% magnitude, phase, etc.) with interactive controls. It supports dynamic
% updates through the returned update function handle.
%
% ===== Basic Usage =====
%   plotComplex(f, val);
%   h = plotComplex(f, val);        % Return handles to lines.
%
% ===== Complex Data Visualization =====
%   plotComplex(f, val, DisplayFormat="Polar");
%   plotComplex(f, val, DisplayFormat="dB", AxisRangeDB=40);
%
% ===== Multiple Plots =====
%   % In the example below, the DisplayFormat will be overwritten on the
%   % second call, as if the first call was also "dB".
%   figure;
%   plotComplex(f, val1, DisplayFormat="Polar");
%   hold on;
%   plotComplex(f, val2, DisplayFormat="dB", AxisRangeDB=40);
%
% ===== Advanced Features =====
%   % Update plot data after creation.
%   [~, updateFun] = plotComplex(f, val);
%   updateFun(newVal);      % Update with new data
%   drawnow;
%
%   % Customize appearance
%   plotComplex(f, val, "-o", LineWidth=2, MarkerSize=8, ...
%               DisplayFormat="Phase", SetAxisLimits=false);
%
%
% Inputs:
%   f      - Vector of x-coordinates (typically frequency).
%   val    - Complex-valued vector to plot, with same length as "f". Can
%            be a 2D input, where each column generates a separate line.
%   lineSpec ("") - Line style specification (same as "plot" function).
%
% Outputs:
%   lineHandles - Array of line object handles for each plotted trace.
%   updateFun   - Function handle to update plot data: updateFun(newVal).
%
% Options (name-value pairs):
%   DisplayFormat ("Polar") - Visualization format:
%       "Polar"    - Complex plane with unit circle
%       "Magnitude"- Magnitude vs frequency
%       "dB"       - Magnitude (20*log10) vs frequency
%       "Phase"    - Phase (degrees) vs frequency
%       "Real"     - Real component vs frequency
%       "Imag"     - Imaginary component vs frequency
%
%   AxisRangeDB (60)      - Dynamic range for dB-scale plots (positive value)
%   Axis (gca)            - Target axes for plotting
%   AddCustomDataTips (true) - Enable detailed data tips showing complex values
%   SetAxisLimits (true)  - Auto-set appropriate axis limits for each format
%   ShowMenu (true)       - Add context menu for interactive format control
%
%   plotOptions - Additional line properties (name-value pairs):
%       Any valid Line property (e.g., 'LineWidth', 'Marker', 'Color')
%
% Notes:
%   - New menu-bar allows changing display format interactively.
%   - Data tips show: Frequency, [Real, Imag], Magnitude, and Phase.
%   - For polar plots, unit circle and axes are shown as reference.
%   - updateFun preserves all formatting when updating data.
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
    lineHandles(ii).UserData.val = val(:, ii);
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

%% Create "updateFun" Return Argument
if nargout >= 2
    updateFun = @(newVal) updateFunHandler(options.Axis, lineHandles, newVal);
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



%% UpdateFun Handler
function updateFunHandler(axis, lineHandles, newVal)
    newVal = squeeze(newVal);
    if isvector(newVal)
        newVal = newVal(:);
    end

    options = axis.UserData.options;

    for ii = 1:numel(lineHandles)
        [xp, yp] = convertData(options, ...
            lineHandles(ii).UserData.f, newVal(:, ii));

        lineHandles(ii).XData = xp;
        lineHandles(ii).YData = yp;

        lineHandles(ii).UserData.val = newVal(:, ii);
    end

    if options.AddCustomDataTips
        for ii = 1:numel(lineHandles)
            lineHandles(ii).DataTipTemplate.DataTipRows(2).Value ...
                = real(newVal(:, ii));
            lineHandles(ii).DataTipTemplate.DataTipRows(3).Value ...
                = imag(newVal(:, ii));
            lineHandles(ii).DataTipTemplate.DataTipRows(4).Value ...
                = abs(newVal(:, ii));
            lineHandles(ii).DataTipTemplate.DataTipRows(5).Value ...
                = rad2deg(angle(newVal(:, ii)));
        end
    end
end

%% Display Format Update Function
function displayFormatUpdateFun(itemLabel, axisHandle)
    axisHandle.UserData.options.DisplayFormat = itemLabel;
    options = axisHandle.UserData.options;

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


