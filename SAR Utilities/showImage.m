function [varargout] = showImage(x, y, ImgIn, options, imagescOptions)
%SHOWIMAGE Shows an xy image.
% This function is very similar to imagesc(), except that it transposes and
% squeezes input ImgIn, and it optionally formats a complex image for
% diplay. It also sets the axis aspect ratio properly. Otherwise, the
% functionality is very similar to imagesc. Name value pair arguments are
% passed through to imagesc, and any output arguments of imagesc are
% forwarded.
%
% Example Usage:
%   showImage(x, y, Img);
%   h = showImage(x, y, Img);
%   showImage(x, y, Img, DisplayFormat="Magnitude");
%   showImage(x, y, Img, DisplayFormat="Magnitude", Normalize=true);
%   showImage(x, y, Img, DisplayFormat="MagPhase", PhaseMultiplier=2);
%
% If the DisplayFormat option is set to "MagPhase", the image will be shown
% using color to represent phase, and intesity to represent magnitude. The
% named options NormalizeFactor and PhaseMultiplier are scale factors for
% the image intensity and phase colormap, respectively, in this case.
%
% Inputs:
%   x - vector of coordinates of ImgIn (first dimension).
%   y - vector of coordinates of ImgIn (first dimension).
%   ImgIn - Array containing image. Should have at most 2 non-singleton
%       dimensions. Can be complex if DisplayFormat is specified.
%
% Outputs:
%   Passed through from "imagesc". See imagesc documentation for details.
%
% Named Options:
%   DisplayFormat ("None") - For a complex-valued image, this argument
%       specifies which component to show. Options are "None", "Magnitude",
%       "dB", "Phase", "Real", "Imag", "MagPhase".
%   Normalize (false) - If true, normalize image before showing.
%   NormalizeFactor (1) - If Normalize=true or DisplayFormat="MagPhase",
%       this scaling factor is applied post-normalization.
%   ColorScaleRangeDB (60) - Range, in dB to plot when in 'dB' mode.
%   PhaseMultiplier (1) - If DisplayFormat="MagPhase", this scale factor is
%       applied to the phase before displaying.
%   ShowColorbar (true) - Whether or not to display colorbar.
%   ColorbarLabel - If specified, use as the colorbar label string.
%   Axes (gca()) - Axis on which to plot.
%
% Author: Matt Dvorsky

arguments
    x(:, 1);
    y(:, 1);
    ImgIn(:, :) {mustBeFinite, mustBeValidImageSize(ImgIn, x, y)};
    options.DisplayFormat {mustBeTextScalar, mustBeMember(options.DisplayFormat, ...
        ["Magnitude", "dB", "Real", "Imag", "RealAbs", "ImagAbs", ...
        "Phase", "MagPhase", "Animated"])};
    
    options.Normalize(1, 1) logical = false;
    options.NormalizeFactor(1, 1) {mustBePositive} = 1;
    options.ColorScaleRangeDB(1, 1) {mustBePositive} = 60;
    options.PhaseMultiplier(1, 1) {mustBePositive} = 1;
    options.ShowColorbar(1, 1) logical = true;
    options.ColorbarLabel {mustBeTextScalar};
    options.Axes(1, 1) {mustBeA(options.Axes, "Axes")};

    options.ShowDisplayFormatMenu(1, 1) logical = true;
    options.AnimationFPS(1, 1) ...
        {mustBeInRange(options.AnimationFPS, 0, 20, "exclude-lower")} = 20;
    options.AnimationPeriodSeconds(1, 1) ...
        {mustBeInRange(options.AnimationPeriodSeconds, 0.5, 10)} = 2;
    
    imagescOptions.AlphaData;
    imagescOptions.AlphaDataMapping;
end

%% Show Image
if ~isfield(options, "DisplayFormat")
    if ~isreal(ImgIn)
        warning("Complex data was passed in, but the 'DisplayFormat' " + ...
            "argument was not specified. Only the real part will be shown");
    end
    options.DisplayFormat = "Real";
end

if ~isfield(options, "Axes")
    options.Axes = gca;
end

maxImgAbs = max(abs(ImgIn(:)));
if any(strcmp(options.DisplayFormat, ["MagPhase", "Animated"]))
    [varargout{1:max(nargout, 1)}] = imagesc(options.Axes, x, y, ...
        options.PhaseMultiplier .* rad2deg(angle(ImgIn)).', ...
        imagescOptions, ...
        AlphaData=convertImage(ImgIn.', options, maxImgAbs));
else
    [varargout{1:max(nargout, 1)}] = imagesc(options.Axes, x, y, ...
        convertImage(ImgIn.', options, maxImgAbs), ...
        imagescOptions);
end

axis(options.Axes, "image");
axis(options.Axes, "xy");
set(options.Axes, Color="k");
setColormap(options.Axes, options, maxImgAbs);

%% Show Colorbar
if options.ShowColorbar
    if isfield(options, "ColorbarLabel")
        colorbarLabel = options.ColorbarLabel;
    else
        colorbarLabel = getColorbarLabel(options.DisplayFormat);
    end
    
    colorbarHandle = colorbar(options.Axes);
    colorbarHandle.Label.String = colorbarLabel;
end

%% Add UI to Allow Changing Colormap
if options.ShowDisplayFormatMenu
    fig = options.Axes.Parent;
    if ~isa(fig, "matlab.ui.Figure")
        warning("Parent object of the current axis is not a figure. " + ...
            "Complex format menu will be disabled.");
    else
        menu = uimenu(fig, Text="Display Format");
        
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

        for ii = 1:numel(displayItems)
            item = uimenu(menu, Text=displayItems(ii), ...
                MenuSelectedFcn=@displayFormatUpdateFun);
            if strcmp(displayItems(ii), options.DisplayFormat)
                item.Checked = "on";
            end
        end
        item = uimenu(menu, Text="Normalize", Separator="on", ...
            MenuSelectedFcn=@normalizeUpdateFunction);
        if options.Normalize
            item.Checked = "on";
        end

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
        
        shiftCountPerUpdate = animMapSize ...
            ./ (options.AnimationPeriodSeconds .* options.AnimationFPS);
        dataStruct.animationTimer = timer(...
            Name=sprintf("Fig_%d_timer", fig.Number), ...
            ExecutionMode="fixedRate", ...
            Period=0.001*round(1000/options.AnimationFPS), ...
            TimerFcn={@animationTimerFunction, ...
                options.Axes, animationColorMap, shiftCountPerUpdate});
        
        fig.CloseRequestFcn = @closeRequest;

        % Store data in figure.
        guidata(fig, dataStruct);

        if strcmp(options.DisplayFormat, "Animated")
            start(dataStruct.animationTimer);
        end
    end
end

end





%% Display Format Update Function
function displayFormatUpdateFun(eventSource, ~)
    for ii = 2:numel(eventSource.Parent.Children)
        eventSource.Parent.Children(ii).Checked = "off";
    end
    eventSource.Checked = "on";

    updateData = guidata(eventSource);
    updateData.options.DisplayFormat = eventSource.Text;

    if ~strcmp(updateData.options.DisplayFormat, "Animated")
        stop(updateData.animationTimer);
    end

    updateDisplayFormat(updateData.Img, updateData.PlotHandle, ...
        updateData.options, updateData.maxImgAbs);
    
    if strcmp(updateData.options.DisplayFormat, "Animated")
        start(updateData.animationTimer);
    end
    
    guidata(eventSource, updateData);
end

function normalizeUpdateFunction(eventSource, ~)
    if eventSource.Checked == "on"
        eventSource.Checked = "off";
    else
        eventSource.Checked = "on";
    end

    updateData = guidata(eventSource);
    updateData.options.Normalize = (eventSource.Checked == "on");
    updateDisplayFormat(updateData.Img, updateData.PlotHandle, ...
        updateData.options, updateData.maxImgAbs);
    guidata(eventSource, updateData);
end

function updateDisplayFormat(Img, PlotHandle, options, maxImgAbs)
    if any(strcmp(options.DisplayFormat, ["MagPhase", "Animated"]))
        PlotHandle.CData = rad2deg(angle(Img.'));
        PlotHandle.AlphaData = convertImage(Img.', options, maxImgAbs);
    else
        PlotHandle.CData = convertImage(Img.', options, maxImgAbs);
        PlotHandle.AlphaData = 1;
    end

    axes = PlotHandle.Parent;
    setColormap(axes, options, maxImgAbs);
    if ~isempty(axes.Colorbar)
        axes.Colorbar.Label.String = getColorbarLabel(options.DisplayFormat);
    end
end

%% Window Animation Functions
function closeRequest(eventSource, ~)
    try
        figureData = guidata(eventSource);
        stop(figureData.animationTimer);
        delete(figureData.animationTimer);
    catch ex
        delete(eventSource);
        rethrow(ex);
    end
    delete(eventSource);
end

function animationTimerFunction(eventSource, ~, axis, animColor, shiftCountPerUpdate)
    colormap(axis, circshift(animColor, ...
        round(shiftCountPerUpdate*eventSource.TasksExecuted), 1));
    drawnow limitrate;
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

function setColormap(axes, options, maxVal)
    if options.Normalize
        maxVal = options.NormalizeFactor;
    end
    if maxVal == 0
        maxVal = 1;
    end

    switch options.DisplayFormat
        case "Magnitude"
            colormap(axes, "jet");
            clim([0, maxVal]);
        case "dB"
            colormap(axes, "jet");
            clim([-options.ColorScaleRangeDB, 0] + db(maxVal));
        case "Real"
            colormap(axes, "colormapplusminus");
            clim([-maxVal, maxVal]);
        case "Imag"
            colormap(axes, "colormapplusminus");
            clim([-maxVal, maxVal]);
        case "RealAbs"
            colormap(axes, "colormapplusminusabs");
            clim([-maxVal, maxVal]);
        case "ImagAbs"
            colormap(axes, "colormapplusminusabs");
            clim([-maxVal, maxVal]);
        case "Phase"
            colormap(axes, "hsv");
            clim([-180, 180]);
        case "MagPhase"
            colormap(axes, "hsv");
            clim([-180, 180]);
        case "Animated"
            colormap(axes, "hsv");
            clim([-180, 180]);
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

