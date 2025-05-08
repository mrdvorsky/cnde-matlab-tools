function [varargout] = showImage(x, y, ImgIn, options)
%Shows an 2D (potentially complex-valued) image.
% This function shows a 2D image, and it optionally formats a complex
% image for display. It also sets the axis aspect ratio properly.
%
% Example Usage:
%   showImage(x, y, Img);
%   h = showImage(x, y, Img);
%   showImage(x, y, Img, DisplayFormat="Magnitude");
%   showImage(x, y, Img, DisplayFormat="Magnitude", Normalize=true);
%
%
% If the "DisplayFormat" option is set to "MagPhase", the image will be
% shown using color to represent phase, and intesity to represent
% magnitude.
%
% If the "DisplayFormat" option is set to "Animated", a time changing
% image will be shown. This will be similar to the "Real" or "Imag"
% options, but the current phase will change using the e^-jwt convention.
% This is useful to show electric or magnetic field plots with radiation.
%
% Inputs:
%   x - vector of coordinates of ImgIn (first dimension).
%   y - vector of coordinates of ImgIn (second dimension).
%   ImgIn - Array containing image. Should have at most 2 non-singleton
%       dimensions. Can be complex.
%
% Outputs:
%   Passed through from "imagesc". See imagesc documentation for details.
%
% Named Arguments:
%   DisplayFormat ("Real") - For a complex-valued image, this argument
%       specifies which component to show.
%   Normalize (false) - If true, normalize image before showing.
%   NormalizeFactor (1) - If Normalize=true or DisplayFormat="MagPhase",
%       this scaling factor is applied post-normalization.
%   ColorScaleRangeDB (60) - Range, in dB to plot when in any 'dB' mode.
%   ShowColorbar (true) - Whether or not to display colorbar.
%   ColorbarLabel - If specified, use as the colorbar label string.
%   Interpolation ("Nearest") - Type of image scaling interpolation to
%       use. Essentially, should the image be pixelated or smooth.
%   Axis (gca()) - Axis on which to plot.
%   ShowMenu (true) - If true, add a context menu with display options.
%   AnimationFPS (30) - Animation update rate, if animation mode is on.
%   AnimationPeriodSeconds (2) - Animation periodicity.
%
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(:, 1);
    ImgIn(:, :) {mustBeFinite, mustBeValidImageSize(ImgIn, x, y)};
    
    options.DisplayFormat {mustBeTextScalar, mustBeMember(options.DisplayFormat, ...
        ["Magnitude", "dB", "Real", "Imag", "RealAbs", "ImagAbs", ...
        "Phase", "MagPhase", "Animated"])} = "Real";
    
    options.Normalize(1, 1) logical = false;
    options.NormalizeFactor(1, 1) {mustBePositive} = 1;
    options.ColorScaleRangeDB(1, 1) {mustBePositive} = 60;

    options.Interpolation(1, 1) string {mustBeMember(options.Interpolation, ...
        ["Nearest", "Bilinear"])} = "Nearest";
    
    options.ShowColorbar(1, 1) logical = true;
    options.ColorbarLabel(1, 1) string;
    options.Axis(1, 1) matlab.graphics.axis.Axes;

    options.ShowMenu(1, 1) logical = true;

    options.AnimationFPS(1, 1) ...
        {mustBeInRange(options.AnimationFPS, 0, 30, "exclude-lower")} = 30;
    options.AnimationPeriodSeconds(1, 1) ...
        {mustBeInRange(options.AnimationPeriodSeconds, 0.5, 10)} = 2;
end

%% Check Inputs
if ~isfield(options, "Axis")
    options.Axis = gca();
end
if isempty(x)
    x = 1:size(ImgIn, 1);
end
if isempty(y)
    y = 1:size(ImgIn, 2);
end

%% Define List of Options for UI
displayItems = [...
    "Magnitude", ...
    "dB", ...
    "Real", ...
    "Imag", ...
    "RealAbs", ...
    "ImagAbs", ...
    "Phase", ...
    "MagPhase", ...
    "Animated" ...
    ];

interpItems = [...
    "Nearest", ...
    "Bilinear"
    ];

%% Show Image
maxImgAbs = max(abs(ImgIn(:)));
[varargout{1:max(nargout, 1)}] = imagesc(options.Axis, x, y, ...
    convertImage(ImgIn.', options, maxImgAbs), ...
    Interpolation=options.Interpolation, ...
    AlphaDataMapping="scaled");
options.Axis.ALim = [0, 1];

if any(strcmp(options.DisplayFormat, ["MagPhase", "Animated"]))
    varargout{1}.CData = rad2deg(angle(ImgIn.'));
    varargout{1}.AlphaData = convertImage(ImgIn.', options, maxImgAbs);
end

axis(options.Axis, "image");
axis(options.Axis, "xy");
set(options.Axis, Color="k");
setColormap(options.Axis, options, maxImgAbs);

%% Show Colorbar
if options.ShowColorbar
    if isfield(options, "ColorbarLabel")
        colorbarLabel = options.ColorbarLabel;
    else
        colorbarLabel = getColorbarLabel(options.DisplayFormat);
    end
    
    colorbarHandle = colorbar(options.Axis);
    colorbarHandle.Label.String = colorbarLabel;
end

%% Add UI to Allow Changing Colormap
fig = ancestor(options.Axis, "matlab.ui.Figure");
if ~options.ShowMenu
    if strcmp(options.DisplayFormat, "Animated")
        error("The 'DisplayFormat' argument was set to 'Animated', " + ...
            "but the 'ShowDisplayFormatMenu' argument was 'false'. " + ...
            "This configuration is not supported.");
    end
    return;
end

menu = uimenu(fig, Text="Display Format");

% DisplayFormat
for ii = 1:numel(displayItems)
    item = uimenu(menu, Text=displayItems(ii), ...
        MenuSelectedFcn={@displayFormatUpdateFun, options.Axis});
    if strcmp(displayItems(ii), options.DisplayFormat)
        item.Checked = "on";
    end
end

% Normalization
item = uimenu(menu, Text="Normalize", Separator="on", ...
    MenuSelectedFcn={@normalizeUpdateFunction, options.Axis});
if options.Normalize
    item.Checked = "on";
end

% Interpolation
for ii = 1:numel(interpItems)
    item = uimenu(menu, Text=interpItems(ii), ...
        MenuSelectedFcn={@interpolationUpdateFun, options.Axis});
    if strcmp(interpItems(ii), options.Interpolation)
        item.Checked = "on";
    end
    if ii == 1
        item.Separator="on";
    end
end

% Axis Storage
dataStruct.Img = ImgIn;
dataStruct.PlotHandle = varargout{1};
dataStruct.options = options;
dataStruct.maxImgAbs = maxImgAbs;

% Set up animation.
animMapSize = 256;

animationColorMap = interp1( ...
    linspace(-1, 1, 1024), ...
    colormapplusminus(1024), ...
    cosd(linspace(-180, 180, animMapSize)));

shiftCountPerUpdate = -animMapSize ...
    ./ (options.AnimationPeriodSeconds .* options.AnimationFPS);
dataStruct.animationTimer = timer(...
    Name=sprintf("Fig_%d_timer", fig.Number), ...
    ExecutionMode="fixedRate", ...
    Period=0.001*round(1000/options.AnimationFPS), ...
    TimerFcn={@animationTimerFunction, ...
    options.Axis, animationColorMap, shiftCountPerUpdate});

options.Axis.DeleteFcn = @closeRequest;

% Store data in figure.
options.Axis.UserData = dataStruct;

if strcmp(options.DisplayFormat, "Animated")
    start(dataStruct.animationTimer);
end



end





%% Display Format Update Function
function displayFormatUpdateFun(eventSource, ~, axis)
    if eventSource.Checked == "on"
        return;
    end

    for ii = 4:numel(eventSource.Parent.Children)
        eventSource.Parent.Children(ii).Checked = "off";
    end
    eventSource.Checked = "on";

    updateData = axis.UserData;
    updateData.options.DisplayFormat = eventSource.Text;

    if ~strcmp(updateData.options.DisplayFormat, "Animated")
        stop(updateData.animationTimer);
    end

    updateDisplayFormat(updateData.Img, updateData.PlotHandle, ...
        updateData.options, updateData.maxImgAbs);
    
    if strcmp(updateData.options.DisplayFormat, "Animated")
        start(updateData.animationTimer);
    end
    
    axis.UserData = updateData;
end

function normalizeUpdateFunction(eventSource, ~, axis)
    if eventSource.Checked == "on"
        eventSource.Checked = "off";
    else
        eventSource.Checked = "on";
    end

    updateData = axis.UserData;
    updateData.options.Normalize = (eventSource.Checked == "on");
    updateDisplayFormat(updateData.Img, updateData.PlotHandle, ...
        updateData.options, updateData.maxImgAbs);
    axis.UserData = updateData;
end

function interpolationUpdateFun(eventSource, ~, axis)
    if eventSource.Checked == "on"
        return;
    end

    for ii = 1:2
        eventSource.Parent.Children(ii).Checked = "off";
    end
    eventSource.Checked = "on";

    updateData = axis.UserData;
    updateData.PlotHandle.Interpolation = eventSource.Text;
    axis.UserData = updateData;
end

function updateDisplayFormat(Img, PlotHandle, options, maxImgAbs)
    if any(strcmp(options.DisplayFormat, ["MagPhase", "Animated"]))
        PlotHandle.CData = rad2deg(angle(Img.'));
        PlotHandle.AlphaData = convertImage(Img.', options, maxImgAbs);
    else
        PlotHandle.CData = convertImage(Img.', options, maxImgAbs);
        PlotHandle.AlphaData = 1;
    end

    axis = options.Axis;
    setColormap(axis, options, maxImgAbs);
    if ~isempty(axis.Colorbar)
        axis.Colorbar.Label.String = getColorbarLabel(options.DisplayFormat);
    end
end

%% Window Animation Functions
function closeRequest(axis, ~)
    try
        figureData = axis.UserData;
        stop(figureData.animationTimer);
        delete(figureData.animationTimer);
    catch ex
        delete(axis);
        rethrow(ex);
    end
    delete(axis);
end

function animationTimerFunction(eventSource, ~, axis, animColor, shiftCountPerUpdate)
    colormap(axis, circshift(animColor, ...
        round(shiftCountPerUpdate*eventSource.TasksExecuted), 1));
    drawnow;
end

%% Helper Functions
function ImgOut = convertImage(ImgIn, options, maxVal)
    scaleFactor = 1;
    if options.Normalize
        scaleFactor = options.NormalizeFactor ./ maxVal;
    end

    switch options.DisplayFormat
        case "Magnitude"
            ImgOut = abs(ImgIn) * scaleFactor;
        case "dB"
            ImgOut = db(ImgIn * scaleFactor);
        case "Real"
            ImgOut = real(ImgIn) * scaleFactor;
        case "Imag"
            ImgOut = imag(ImgIn) * scaleFactor;
        case "RealAbs"
            ImgOut = real(ImgIn) * scaleFactor;
        case "ImagAbs"
            ImgOut = imag(ImgIn) * scaleFactor;
        case "Phase"
            ImgOut = rad2deg(angle(ImgIn));
        case "MagPhase"
            ImgOut = abs(ImgIn) .* (options.NormalizeFactor ./ maxVal);
        case "Animated"
            ImgOut = abs(ImgIn) .* (options.NormalizeFactor ./ maxVal);
        otherwise
            error("'DisplayFormat' argument '%s' is not recognized", ...
                options.DisplayFormat);
    end
end

function colorbarLabel = getColorbarLabel(displayFormat)
    switch displayFormat
        case "Magnitude"
            colorbarLabel = "Magnitude (Linear)";
        case "dB"
            colorbarLabel = "Magnitude (dB)";
        case "Real"
            colorbarLabel = "Real";
        case "Imag"
            colorbarLabel = "Imag";
        case "RealAbs"
            colorbarLabel = "Real";
        case "ImagAbs"
            colorbarLabel = "Imag";
        case "Phase"
            colorbarLabel = "Phase (deg)";
        case "MagPhase"
            colorbarLabel = "Phase (deg)";
        case "Animated"
            colorbarLabel = "Phase (deg)";
        otherwise
            error("'DisplayFormat' argument '%s' is not recognized", ...
                displayFormat);
    end
end

function setColormap(axis, options, maxVal)
    if options.Normalize
        maxVal = options.NormalizeFactor;
    end
    if maxVal == 0
        maxVal = 1;
    end

    switch options.DisplayFormat
        case "Magnitude"
            colormap(axis, "jet");
            clim(axis, [0, maxVal]);
        case "dB"
            colormap(axis, "jet");
            clim(axis, [-options.ColorScaleRangeDB, 0] + db(maxVal));
        case "Real"
            colormap(axis, "colormapplusminus");
            clim(axis, [-maxVal, maxVal]);
        case "Imag"
            colormap(axis, "colormapplusminus");
            clim(axis, [-maxVal, maxVal]);
        case "RealAbs"
            colormap(axis, "colormapplusminusabs");
            clim(axis, [-maxVal, maxVal]);
        case "ImagAbs"
            colormap(axis, "colormapplusminusabs");
            clim(axis, [-maxVal, maxVal]);
        case "Phase"
            colormap(axis, "hsv");
            clim(axis, [-180, 180]);
        case "MagPhase"
            colormap(axis, "hsv");
            clim(axis, [-180, 180]);
        case "Animated"
            colormap(axis, "hsv");
            clim(axis, [-180, 180]);
        otherwise
            error("'DisplayFormat' argument '%s' is not recognized", ...
                options.DisplayFormat);
    end
end

%% Custom Argument Validation Function
function mustBeValidImageSize(Img, x, y)
    if all(size(Img) == [numel(x), numel(y)])
        return;
    end
    if (numel(Img) == numel(x)*numel(y)) && (isscalar(x) || isscalar(y))
        return;
    end
    throwAsCaller(MException("MATLAB:mustBeValidImageSize", ...
        "Image size (%d, %d) is inconsistent with the lengths " + ...
        "of the x- and y-coordinate vectors (%d, %d).", ...
        size(Img, 1), size(Img, 2), numel(x), numel(y)));
end

