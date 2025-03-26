function [varargout] = showImage3D(x, y, z, ImgIn, options)
%SHOWIMAGE Shows slices of a volumetric image using a slider.
% This function is very similar to showImage(), except that it takes a 3D
% (volumetric) data set, and shows a specific slice using a slider.
%
% Example Usage:
%   showImage(x, y, z, Img);
%   h = showImage(x, y, z, Img);
%   showImage(x, y, z, Img, DisplayFormat="Magnitude");
%   showImage(x, y, z, Img, DisplayFormat="Magnitude", Normalize=true);
%
% If the "DisplayFormat" option is set to "MagPhase", the image will be
% shown using color to represent phase, and intesity to represent
% magnitude. The named options NormalizeFactor and PhaseMultiplier are
% scale factors for the image intensity and phase colormap, respectively,
% in this case.
%
% If the "DisplayFormat" option is set to "Animated", a time changing
% image will be shown. This will be similar to the "Real" or "Imag"
% options, but the current phase will change using the e^-jwt convention.
% This is useful to show electric or magnetic field plots with radiation.
%
% Inputs:
%   x - vector of coordinates of ImgIn (first dimension).
%   y - vector of coordinates of ImgIn (second dimension).
%   z - vector of coordinates of ImgIn (third dimension).
%   ImgIn - Array containing image. Should have at most 3 non-singleton
%       dimensions. Can be complex.
%
% Outputs:
%   Passed through from "imagesc". See imagesc documentation for details.
%
% Named Arguments:
%   DisplayFormat ("Real") - For a complex-valued image, this argument
%       specifies which component to show. Options are "Magnitude",
%       "dB", "Phase", "Real", "Imag", "RealAbs", "ImagAbs", "MagPhase",
%       and "Animated".
%   Normalize (false) - If true, normalize image before showing.
%   NormalizeFactor (1) - If Normalize=true or DisplayFormat="MagPhase",
%       this scaling factor is applied post-normalization.
%   ColorScaleRangeDB (60) - Range, in dB to plot when in any 'dB' mode.
%   PhaseMultiplier (1) - If DisplayFormat="MagPhase", this scale factor is
%       applied to the phase before displaying.
%   ShowColorbar (true) - Whether or not to display colorbar.
%   ColorbarLabel - If specified, use as the colorbar label string.
%   Axis (gca()) - Axis on which to plot.
%
% Author: Matt Dvorsky

    arguments
        x(:, 1);
        y(:, 1);
        z(:, 1);
        ImgIn(:, :, :) {mustBeFinite, mustBeValidImageSize(ImgIn, x, y, z)};
        options.DisplayFormat {mustBeTextScalar, mustBeMember(options.DisplayFormat, ...
            ["Magnitude", "dB", "Real", "Imag", "RealAbs", "ImagAbs", ...
            "Phase", "MagPhase", "Animated"])};

        options.Normalize(1, 1) logical = false;
        options.NormalizeFactor(1, 1) {mustBePositive} = 1;
        options.ColorScaleRangeDB(1, 1) {mustBePositive} = 60;
        options.PhaseMultiplier(1, 1) {mustBePositive} = 1;

        options.ShowColorbar(1, 1) logical = true;
        options.ColorbarLabel {mustBeTextScalar};
        options.Axis(1, 1) {mustBeA(options.Axis, "Axis")};

        options.ShowDisplayFormatMenu(1, 1) logical = true;

        options.AnimationFPS(1, 1) ...
            {mustBeInRange(options.AnimationFPS, 0, 20, "exclude-lower")} = 20;
        options.AnimationPeriodSeconds(1, 1) ...
            {mustBeInRange(options.AnimationPeriodSeconds, 0.5, 10)} = 2;
    end

    %% Show Image
    if ~isfield(options, "DisplayFormat")
        if ~isreal(ImgIn)
            warning("Complex data was passed in, but the 'DisplayFormat' " + ...
                "argument was not specified. Only the real part will be shown");
        end
        options.DisplayFormat = "Real";
    end

    if ~isfield(options, "Axis")
        options.Axis = gca;
    end

    maxImgAbs = max(abs(ImgIn(:)));
    if any(strcmp(options.DisplayFormat, ["MagPhase", "Animated"]))
        [varargout{1:max(nargout, 1)}] = imagesc(options.Axis, x, y, ...
            options.PhaseMultiplier .* rad2deg(angle(ImgIn)).', ...
            AlphaData=convertImage(ImgIn.', options, maxImgAbs));
    else
        [varargout{1:max(nargout, 1)}] = imagesc(options.Axis, x, y, ...
            convertImage(ImgIn.', options, maxImgAbs));
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
    fig = options.Axis.Parent;
    if options.ShowDisplayFormatMenu && ~isa(fig, "matlab.ui.Figure")
        error("Parent object of the current axis is not a figure.");
    end

    if ~options.ShowDisplayFormatMenu && strcmp(options.DisplayFormat, "Animated")
        warning("The 'DisplayFormat' argument was set to 'Animated', " + ...
            "but the 'ShowDisplayFormatMenu' argument was 'false'. " + ...
            "The display format will be set to 'MagPhase' instead.")
    end

    if options.ShowDisplayFormatMenu
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
                MenuSelectedFcn={@displayFormatUpdateFun, options.Axis});
            if strcmp(displayItems(ii), options.DisplayFormat)
                item.Checked = "on";
            end
        end
        item = uimenu(menu, Text="Normalize", Separator="on", ...
            MenuSelectedFcn={@normalizeUpdateFunction, options.Axis});
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

    %% Add Slider
    sliderPosition = [0.1, 0.05, 0.9, 0.05];
    slider = uicontrol(Style="slider", ...
        Position=sliderPosition, ...
        Units="normalized", ...
        Callback=@sliderMoveHandle);


end





%% Display Format Update Function
function displayFormatUpdateFun(eventSource, ~, axis)
    if eventSource.Checked == "on"
        return;
    end

    for ii = 2:numel(eventSource.Parent.Children)
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
    drawnow limitrate;
end

%% Slider and Slicing Functions
function sliderMoveHandle(src, ev)
    src
    ev
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
function mustBeValidImageSize(Img, x, y, z)
    if all(size(Img, 1:3) == [numel(x), numel(y), numel(z)])
        return;
    end
    % if (numel(Img) == numel(x)*numel(y)) && (isscalar(x) || isscalar(y))
    %     return;
    % end
    throwAsCaller(MException("MATLAB:mustBeValidImageSize", ...
        "Image size (%d, %d) is inconsistent with the lengths " + ...
        "of the x- and y-coordinate vectors (%d, %d).", ...
        size(Img, 1), size(Img, 2), numel(x), numel(y)));
end

