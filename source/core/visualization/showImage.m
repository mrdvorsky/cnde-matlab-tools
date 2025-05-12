function [imageHandle, updateFun] = showImage(x, y, ImgIn, options)
%Display a 2D image with support for complex-valued data and visualization options.
% This function displays 2D images with proper aspect ratio and provides
% specialized handling for complex-valued images through various display
% formats. It includes features like normalization, different scaling
% options, and interactive controls.
%
% ===== Basic Usage =====
%   showImage(x, y, Img);
%   h = showImage([], [], Img);     % Uses indices as coordinates
%
% ===== Complex Data Visualization =====
%   showImage(x, y, complexImg, DisplayFormat="Magnitude");
%   showImage(x, y, complexImg, DisplayFormat="MagPhase");
%   showImage(x, y, complexImg, DisplayFormat="Animated");
%
% ===== Advanced Features =====
%   % Update image data after creation
%   [~, updateFun] = showImage(x, y, ImgComplex);
%   updateFun(newImgCompelx);   % Update with new complex-valued data.
%   drawnow;
%
%   % Customize display
%   showImage(x, y, Img, DisplayFormat="Phase", Normalize=true, ...
%             ColorScaleRangeDB=40, Interpolation="Bilinear");
%
%
% Inputs:
%   x - Vector of x-coordinates (first dimension of ImgIn).
%   y - Vector of y-coordinates (second dimension of ImgIn).
%   ImgIn - 2D array containing image data. Can be real or complex-valued.
%           Must satisfy size(squeeze(ImgIn)) = [length(x), length(y)].
%
% Outputs:
%   imageHandle - Handle to the image object created by imagesc.
%   updateFun   - Function handle to update the displayed image with new
%                 complex-valued data. This function will properly handle
%                 the complex-valued display format.
%
% Options (name-value pairs):
%   DisplayFormat ("Magnitude") - How to display complex data:
%       "Magnitude" - Show absolute value
%       "Real"      - Show real component
%       "Imag"      - Show imaginary component
%       "Phase"     - Show phase (degrees)
%       "MagPhase"  - Magnitude (alpha) + Phase (color)
%       "Animated"  - Animated phase with magnitude alpha
%
%   DisplayScale ("Abs") - Scaling for magnitude/real/imag displays:
%       "Linear"    - Linear scale
%       "Abs"       - Absolute value
%       "dB"        - 20*log10(abs())
%
%   Normalize (false)      - Normalize image by its maximum value.
%   NormalizeFactor (1)    - Scaling factor applied after normalization.
%   ColorScaleRangeDB (60) - Dynamic range in dB for dB-scale displays.
%
%   Interpolation ("Nearest") - Image interpolation method:
%       "Nearest"   - Pixelated (no interpolation)
%       "Bilinear"  - Smooth interpolation
%
%   ShowColorbar (true)   - Whether to show colorbar.
%   ColorbarLabel         - Custom label for colorbar.
%   Axis (gca)            - Target axes for plotting.
%
%   AddCustomDataTips (true) - Enable detailed data tips showing complex
%                              values.
%   ShowMenu (true)          - Add context menu for interactive controls.
%
%   AnimationFPS (30)      - Frame rate for animated display (1-30 fps).
%   AnimationPeriodSeconds (2) - Period for phase animation (0.5-10 sec).
%
% Notes:
%   - For "MagPhase" and "Animated" formats, magnitude controls transparency
%   - Data tips show complex values as [Real, Imag], Magnitude, and Phase
%   - Right-click menu allows changing display parameters interactively
%
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(:, 1);
    ImgIn(:, :) {mustBeFinite, mustBeValidImageSize(ImgIn, x, y)};
    
    options.DisplayFormat(1, 1) string {mustBeMember(options.DisplayFormat, ...
        ["Magnitude", "Real", "Imag", "Phase", "MagPhase", "Animated"])} = "Magnitude";
    options.DisplayScale(1, 1) string {mustBeMember(options.DisplayScale, ...
        ["Linear", "Abs", "dB"])} = "Abs";
    
    options.Normalize(1, 1) logical = false;
    options.NormalizeFactor(1, 1) {mustBePositive} = 1;
    options.ColorScaleRangeDB(1, 1) {mustBePositive} = 60;

    options.Interpolation(1, 1) string {mustBeMember(options.Interpolation, ...
        ["Nearest", "Bilinear"])} = "Nearest";
    
    options.ShowColorbar(1, 1) logical = true;
    options.ColorbarLabel(1, 1) string;
    options.Axis(1, 1) matlab.graphics.axis.Axes;

    options.AddCustomDataTips(1, 1) logical = true;
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
displayFormatItems = [...
    "Magnitude", ...
    "Real", ...
    "Imag", ...
    "Phase", ...
    "MagPhase", ...
    "Animated", ...
    ];

displayScaleItems = [...
    "Linear", ...
    "Abs", ...
    "dB", ...
    ];

interpItems = [...
    "Nearest", ...
    "Bilinear", ...
    ];

%% Show Image
maxImgAbs = max(abs(ImgIn(:)));
[ImgC, ImgA] = convertImage(ImgIn.', options, maxImgAbs);
[imageHandle] = imagesc(options.Axis, x, y, ...
    ImgC, AlphaData=ImgA, ...
    Interpolation=options.Interpolation, ...
    AlphaDataMapping="scaled");
options.Axis.ALim = [0, 1];

axis(options.Axis, "image");
axis(options.Axis, "xy");
set(options.Axis, Color="k");

%% Store Data in Axis
options.Axis.UserData.options = options;
options.Axis.UserData.maxImgAbs = maxImgAbs;
options.Axis.UserData.Img = ImgIn;
options.Axis.UserData.PlotHandle = imageHandle;

%% Add Custom Data Tips
if options.AddCustomDataTips
    tmpTip = datatip(imageHandle, x(1), y(1), Visible="off");

    imageHandle.DataTipTemplate.DataTipRows(2) = dataTipTextRow(...
        "[R, I]", ...
        @(x) dataTipHandler_realImag(options.Axis, imageHandle, x), ...
        "auto");

    imageHandle.DataTipTemplate.DataTipRows(3) = dataTipTextRow(...
        "Mag", ...
        @(x) dataTipHandler_mag(options.Axis, imageHandle, x), ...
        "%.6g");

    imageHandle.DataTipTemplate.DataTipRows(4) = dataTipTextRow(...
        "Phase", ...
        @(x) dataTipHandler_phase(options.Axis, imageHandle, x), ...
        "%.6g deg");

    delete(tmpTip);
end

%% Set Colormap
setColormap(options.Axis);

%% Show Colorbar
if options.ShowColorbar
    if isfield(options, "ColorbarLabel")
        colorbarLabel = options.ColorbarLabel;
    else
        colorbarLabel = getColorbarLabel(options);
    end
    
    colorbarHandle = colorbar(options.Axis);
    colorbarHandle.Label.String = colorbarLabel;
end

%% Create "updateFun" Return Argument
if nargout >= 2
    updateFun = @(ImgIn) updateFunHandler(options.Axis, ImgIn);
end

%% Add UI to Allow Changing Colormap
if ~options.ShowMenu
    if strcmp(options.DisplayFormat, "Animated")
        error("The 'DisplayFormat' argument was set to 'Animated', " + ...
            "but the 'ShowMenu' argument was 'false'. " + ...
            "This configuration is not supported.");
    end
    return;
end

fig = ancestor(options.Axis, "matlab.ui.Figure");
menu = uimenu(fig, Text="Display Format");

% Add menu items.
createMenuList(menu, displayFormatItems, options.DisplayFormat, ...
    {@displayFormatUpdateFun, options.Axis});
createMenuList(menu, displayScaleItems, options.DisplayScale, ...
    {@displayScaleUpdateFun, options.Axis});
createMenuList(menu, interpItems, options.Interpolation, ...
    {@interpolationUpdateFun, options.Axis});

%% Set Up Animation Timer
phaseShiftPerUpdate = (2*pi) ...
    ./ options.AnimationFPS ...
    ./ options.AnimationPeriodSeconds;
options.Axis.UserData.animationTimer = timer(...
    Name=sprintf("Fig_%d_timer", fig.Number), ...
    ExecutionMode="fixedRate", ...
    Period=0.001*round(1000/options.AnimationFPS), ...
    TimerFcn={@animationTimerFunction, ...
    options.Axis, phaseShiftPerUpdate});

options.Axis.DeleteFcn = @closeRequest;

% Start the timer, if animation is enabled.
if strcmp(options.DisplayFormat, "Animated")
    start(options.Axis.UserData.animationTimer);
end

end






%% UpdateFun Handler
function updateFunHandler(axis, ImgIn)
    axis.UserData.maxImgAbs = max(abs(ImgIn(:)));
    axis.UserData.Img = ImgIn;

    [ImgC, ImgA] = convertImage(ImgIn, ...
        axis.UserData.options, axis.UserData.maxImgAbs);

    axis.UserData.PlotHandle.CData = ImgC.';
    axis.UserData.PlotHandle.AlphaData = ImgA.';
end

%% Data Tip Handler
function [realImag] = dataTipHandler_realImag(axis, imgHandle, xyCoords)
    xPick = xyCoords(1);
    yPick = xyCoords(2);

    xInd = nearestIndex(imgHandle.XData, xPick);
    yInd = nearestIndex(imgHandle.YData, yPick);

    realImag = axis.UserData.Img(xInd, yInd);
    realImag = [real(realImag), imag(realImag)];
end

function [mag] = dataTipHandler_mag(axis, imgHandle, xyCoords)
    xPick = xyCoords(1);
    yPick = xyCoords(2);

    xInd = nearestIndex(imgHandle.XData, xPick);
    yInd = nearestIndex(imgHandle.YData, yPick);

    mag = abs(axis.UserData.Img(xInd, yInd));
end

function [ph] = dataTipHandler_phase(axis, imgHandle, xyCoords)
    xPick = xyCoords(1);
    yPick = xyCoords(2);

    xInd = nearestIndex(imgHandle.XData, xPick);
    yInd = nearestIndex(imgHandle.YData, yPick);

    ph = rad2deg(angle(axis.UserData.Img(xInd, yInd)));
end

%% Display Format Update Functions
function displayFormatUpdateFun(itemText, axis)
    axis.UserData.options.DisplayFormat = itemText;
    updateDisplay(axis);

    if strcmp(itemText, "Animated") ...
            && strcmp(axis.UserData.animationTimer.Running, "off")
        start(axis.UserData.animationTimer);
    elseif ~strcmp(itemText, "Animated") ...
            && strcmp(axis.UserData.animationTimer.Running, "on")
        stop(axis.UserData.animationTimer);
    end
end

function displayScaleUpdateFun(itemText, axis)
    axis.UserData.options.DisplayScale = itemText;
    updateDisplay(axis);
end

function interpolationUpdateFun(itemText, axis)
    axis.UserData.options.Interpolation = itemText;
    axis.UserData.PlotHandle.Interpolation = itemText;
end

function updateDisplay(axis)
    PlotHandle = axis.UserData.PlotHandle;
    Img = axis.UserData.Img;
    options = axis.UserData.options;
    maxImgAbs = axis.UserData.maxImgAbs;

    [ImgC, ImgA] = convertImage(Img.', options, maxImgAbs);
    PlotHandle.CData = ImgC;
    PlotHandle.AlphaData = ImgA;

    setColormap(axis);
    if ~isempty(axis.Colorbar)
        axis.Colorbar.Label.String = getColorbarLabel(options);
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

function animationTimerFunction(~, ~, axis, phaseShiftPerUpdate)
    currentColormap = colormap(axis);
    colormap(axis, circshift(currentColormap, ...
        round(size(currentColormap, 1) * phaseShiftPerUpdate/(-2*pi)), 1));
    drawnow;
end

%% Helper Functions
function [ImgC, ImgA] = convertImage(ImgIn, options, maxVal)
    scaleFactor = 1;
    if options.Normalize
        scaleFactor = options.NormalizeFactor ./ maxVal;
    end

    ImgA = 1;
    switch options.DisplayFormat
        case "Magnitude"
            ImgC = abs(ImgIn) * scaleFactor;
        case "Real"
            ImgC = real(ImgIn) * scaleFactor;
        case "Imag"
            ImgC = imag(ImgIn) * scaleFactor;
        case "Phase"
            ImgC = rad2deg(angle(ImgIn));
        case "MagPhase"
            ImgC = rad2deg(angle(ImgIn));
            ImgA = abs(ImgIn) * (options.NormalizeFactor ./ maxVal);
        case "Animated"
            ImgC = rad2deg(angle(ImgIn));
            ImgA = abs(ImgIn) * (options.NormalizeFactor ./ maxVal);
        otherwise
            error("'DisplayFormat' argument '%s' is not recognized", ...
                options.DisplayFormat);
    end

    if any(strcmp(options.DisplayFormat, ["Magnitude", "Real", "Imag"]))
        switch options.DisplayScale
            case "Linear"
            case "Abs"
                ImgC = abs(ImgC);
            case "dB"
                ImgC = 20*log10(abs(ImgC));
            otherwise
                error("'DisplayScale' argument '%s' is not recognized", ...
                    options.DisplayScale);
        end
    end
end

function colorbarLabel = getColorbarLabel(options)
    switch options.DisplayFormat
        case "Magnitude"
            colorbarLabel = "Magnitude";
        case "Real"
            colorbarLabel = "Real";
        case "Imag"
            colorbarLabel = "Imag";
        case "Phase"
            colorbarLabel = "Phase (deg)";
        case "MagPhase"
            colorbarLabel = "Phase (deg)";
        case "Animated"
            colorbarLabel = "Phase (deg)";
        otherwise
            error("'DisplayFormat' argument '%s' is not recognized", ...
                options.DisplayFormat);
    end

    if any(strcmp(options.DisplayFormat, ["Magnitude", "Real", "Imag"]))
        switch options.DisplayScale
            case "Linear"
                colorbarLabel = strcat(colorbarLabel, " (Linear)");
            case "Abs"
                colorbarLabel = strcat(colorbarLabel, " (Abs)");
            case "dB"
                colorbarLabel = strcat(colorbarLabel, " (dB)");
            otherwise
                error("'DisplayScale' argument '%s' is not recognized", ...
                    options.DisplayScale);
        end
    end
end

function setColormap(axis)
    options = axis.UserData.options;
    maxVal = axis.UserData.maxImgAbs;

    if options.Normalize
        maxVal = options.NormalizeFactor;
    end
    if maxVal == 0
        maxVal = 1;
    end

    switch options.DisplayScale
        case "Linear"
            colormap(axis, "colormapplusminus");
            clim(axis, [-maxVal, maxVal]);
        case "Abs"
            colormap(axis, "jet");
            clim(axis, [0, maxVal]);
        case "dB"
            colormap(axis, "jet");
            clim(axis, [-options.ColorScaleRangeDB, 0] + db(maxVal));
        otherwise
            error("'DisplayScale' argument '%s' is not recognized", ...
                options.DisplayScale);
    end

    switch options.DisplayFormat
        case "Phase"
            colormap(axis, "hsv");
            clim(axis, [-180, 180]);
        case "MagPhase"
            colormap(axis, "hsv");
            clim(axis, [-180, 180]);
        case "Animated"
            ph = linspace(-180, 180, 512).';
            switch options.DisplayScale
                case "Linear"
                    cmap = interp1(ph/180, ...
                        colormapplusminus(numel(ph)), cosd(ph));
                    colormap(axis, cmap);
                case "Abs"
                    cmap = interp1((ph + 180)/360, ...
                        gray(numel(ph)), abs(cosd(ph)));
                    colormap(axis, cmap);
                case "dB"
                    cmap = interp1((ph + 180)/360, ...
                        gray(numel(ph)), abs(cosd(ph)));
                    colormap(axis, cmap);
            end
            clim(axis, [-180, 180]);
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

%% Custom Argument Validation Function
function mustBeValidImageSize(Img, x, y)
    if all(size(Img) == [numel(x), numel(y)])
        return;
    end
    if (numel(Img) == numel(x)*numel(y)) && (isscalar(x) || isscalar(y))
        return;
    end
    throwAsCaller(MException("showImage:mustBeValidImageSize", ...
        "Image size (%d, %d) is inconsistent with the lengths " + ...
        "of the x- and y-coordinate vectors (%d, %d).", ...
        size(Img, 1), size(Img, 2), numel(x), numel(y)));
end