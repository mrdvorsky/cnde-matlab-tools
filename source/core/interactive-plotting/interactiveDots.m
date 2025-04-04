function [] = interactiveDots(xDotInitial, yDotInitial, updateFun, options)
%Add draggable dots to current plot with update function.
% This function adds dots to the current plot. The points will
% "draggable", meaning the user can click and drag them, and they will
% move as expected. When any dot is dragged, the input function handle
% "updateFun" will be called with the new xy-coordinates and the index of
% which dot is being moved.
%
% Example Usage:
%   % Make a plot as needed.
%   figure;
%   plotHandle = plot(...);
%
%   % Add the draggable dots.
%   interactiveDots(xDotInitial, yDotInitial, ...
%       {@updateFunction, plotHandle, arg1, arg2, ...});
%
%   % Update function (this function is called whenever a dot moves)
%   [x, y] = updateFunction(x, y, ind, plotHandle, arg1, arg2, ...)
%       % Update the plot here (or do something else).
%       % Inputs "x" and "y" are arrays with coordinates of all dots.
%       % Input "ind" is the index of the currently moving dot.
%       % If the returned "x" and "y" are different from the inputs, the
%           dot will move to the returned location.
%   end
%
%
% Inputs:
%   xDotInitial - Initial x-coordinates of draggable dots.
%   yDotInitial - Initial y-coordinates of draggable dots.
%   updateFuntion - Function handle of update function or cell array, where
%       the first argument is the function handle, and additional elements
%       will be passed as arguments (e.g., plot handles).
%
% Named Arguments:
%   Axis (gca) - Axis on which to add draggable dots.
%   DragClampFun - Function handle that can be used to restrict movement
%       of the draggable dots. The function handle should accept x- and
%       y-coordinates and return new coordinates.
%   MarkerSize (20) - Size of draggable dots.
%   MarkerColor ("black") - Color of draggable dots.
%
% Author: Matt Dvorsky

arguments
    xDotInitial(:, 1);
    yDotInitial(:, 1) {mustHaveEqualSizes(xDotInitial, yDotInitial)};
    updateFun;

    options.Axis(1, 1) matlab.graphics.axis.Axes;
    options.DragClampFun(1, 1) {mustBeCallable(...
        options.DragClampFun, {0, 0}, "x, y")} = @(x, y) [x, y];
    options.MarkerSize(1, 1) {mustBePositive} = 20;
    options.MarkerColor(1, 1) string = "k";
end

%% Check Arguments
if isempty(xDotInitial)
    return;
end
if ~isfield(options, "Axis")
    options.Axis = gca;
end

%% Plot Markers
handle_marker = plot(options.Axis, xDotInitial, yDotInitial, ".", ...
    MarkerSize=options.MarkerSize, ...
    Color=options.MarkerColor, ...
    HandleVisibility="off");

xlim(options.Axis, xlim(options.Axis));
ylim(options.Axis, ylim(options.Axis));

handle_marker.ButtonDownFcn={@clickMarker, ...
    handle_marker, updateFun, options.DragClampFun};

%% Run Drag Handler Once
xy_clamped = options.DragClampFun(xDotInitial, yDotInitial);
x_clamped = xy_clamped(:, 1);
y_clamped = xy_clamped(:, 2);
if iscell(updateFun)
    [xDotInitial, yDotInitial] = updateFun{1}(x_clamped, y_clamped, 1, updateFun{2:end});
else
    [xDotInitial, yDotInitial] = updateFun(x_clamped, y_clamped, 1);
end
handle_marker.XData = xDotInitial;
handle_marker.YData = yDotInitial;

end



function clickMarker(src, ~, handle_marker, updateFun, dragClampFun)
    ax = src.Parent;
    fig = ax.Parent;

    cursorPoint = ax.CurrentPoint;
    xPoint = cursorPoint(1, 1, 1);
    yPoint = cursorPoint(1, 2, 1);
    x = handle_marker.XData;
    y = handle_marker.YData;
    [~, cursorInd] = min(hypot(x - xPoint, y - yPoint));

    fig.WindowButtonMotionFcn = {@dragMarker, ax, cursorInd, ...
        handle_marker, updateFun, dragClampFun};
    fig.WindowButtonUpFcn = @unclickMarker;
end

function unclickMarker(fig, ~)
    fig.WindowButtonMotionFcn = "";
    fig.WindowButtonUpFcn = "";
end

function dragMarker(~, ~, ax, cursorInd, handle_marker, updateFun, dragClampFun)
    cursorPoint = ax.CurrentPoint;
    [xy] = dragClampFun(cursorPoint(1, 1, 1), cursorPoint(1, 2, 1));
    xPoint = xy(1);
    yPoint = xy(2);

    x = handle_marker.XData(:);
    y = handle_marker.YData(:);

    x(cursorInd) = xPoint;
    y(cursorInd) = yPoint;

    if iscell(updateFun)
        [x, y] = updateFun{1}(x, y, cursorInd, updateFun{2:end});
    else
        [x, y] = updateFun(x, y, cursorInd);
    end

    handle_marker.XData = x;
    handle_marker.YData = y;
end





