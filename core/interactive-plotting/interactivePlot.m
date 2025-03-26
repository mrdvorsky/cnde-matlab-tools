function [] = interactivePlot(x, y, updateFun, options)
%INTERACTIVEPLOT Add draggable points to current plot with update function.
%
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(:, 1);
    updateFun;

    options.Axes(1, 1);
    options.DragClampFun(1, 1) {mustBeCallable(...
        options.DragClampFun, {0, 0}, "x, y")} = @(x, y) [x, y];
    options.MarkerSize(1, 1) {mustBePositive} = 20;
    options.MarkerColor(1, 1) string = "k";
end

%% Get Current Axes
if ~isfield(options, "Axes")
    options.Axes = gca;
end

%% Plot Markers
handle_marker = plot(options.Axes, x, y, ".", ...
    MarkerSize=options.MarkerSize, ...
    Color=options.MarkerColor, ...
    HandleVisibility="off");

xlim(options.Axes, xlim(options.Axes));
ylim(options.Axes, ylim(options.Axes));

handle_marker.ButtonDownFcn={@clickMarker, ...
    handle_marker, updateFun, options.DragClampFun};

%% Run Drag Handler Once
xy_clamped = options.DragClampFun(x, y);
x_clamped = xy_clamped(:, 1);
y_clamped = xy_clamped(:, 2);
if iscell(updateFun)
    [x, y] = updateFun{1}(x_clamped, y_clamped, 1, updateFun{2:end});
else
    [x, y] = updateFun(x_clamped, y_clamped, 1);
end
handle_marker.XData = x;
handle_marker.YData = y;

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





