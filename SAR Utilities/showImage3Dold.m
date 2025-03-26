function show3DImage(x, y, z, Img3D, options)
%SHOW3DIMAGE Shows a 3D image with a slider to control the displayed slice.
% This function extends showImage to handle 3D images, allowing the user to
% navigate through slices using a slider. The z input describes the third dimension.
%
% Example Usage:
%   show3DImage(x, y, z, Img3D);
%   show3DImage(x, y, z, Img3D, DisplayFormat="Magnitude");
%   show3DImage(x, y, z, Img3D, DisplayFormat="Magnitude", Normalize=true);
%
% Inputs:
%   x - vector of coordinates for the x-axis.
%   y - vector of coordinates for the y-axis.
%   z - vector of coordinates for the third dimension (e.g., slice positions or time).
%   Img3D - 3D array containing the image stack (x, y, slices).
%   options - Named arguments to control display (same as showImage).
%
% Author: Adapted from showImage by Matt Dvorsky

arguments
    x(:, 1);
    y(:, 1);
    z(:, 1);
    Img3D(:, :, :) {mustBeFinite, mustBeValidImageSize3D(Img3D, x, y, z)};
    options.DisplayFormat {mustBeTextScalar, mustBeMember(options.DisplayFormat, ...
        ["Magnitude", "dB", "Real", "Imag", "RealAbs", "ImagAbs", ...
        "Phase", "MagPhase", "Animated"])} = "Real";
    
    options.Normalize(1, 1) logical = false;
    options.NormalizeFactor(1, 1) {mustBePositive} = 1;
    options.ColorScaleRangeDB(1, 1) {mustBePositive} = 60;
    options.PhaseMultiplier(1, 1) {mustBePositive} = 1;
    
    options.ShowColorbar(1, 1) logical = true;
    options.ColorbarLabel {mustBeTextScalar};
    options.Axis(1, 1) {mustBeA(options.Axis, "matlab.graphics.axis.Axes")} = gca;

    options.ShowDisplayFormatMenu(1, 1) logical = true;
end

%% Initialize
numSlices = size(Img3D, 3); % Number of slices in the 3D image
currentSlice = 1; % Start with the first slice

% Create figure and axes
fig = figure;
ax = options.Axis;

% Add a slider for slice navigation
sliderPosition = [100 20 400 20]; % Position of the slider
slider = uicontrol('Style', 'slider', ...
    'Min', 1, 'Max', numSlices, 'Value', currentSlice, ...
    'SliderStep', [1/(numSlices-1) 1/(numSlices-1)], ...
    'Position', sliderPosition, ...
    'Callback', @sliderCallback);

% Add a text label for the slider
sliderLabel = uicontrol('Style', 'text', ...
    'Position', [250 50 100 20], ...
    'String', sprintf('Slice: %d/%d, z = %.2f', currentSlice, numSlices, z(currentSlice)));

% Display the initial slice
displaySlice(currentSlice);

%% Nested Functions
    function sliderCallback(src, ~)
        % Callback for the slider: updates the displayed slice
        currentSlice = round(src.Value);
        set(sliderLabel, 'String', sprintf('Slice: %d/%d, z = %.2f', currentSlice, numSlices, z(currentSlice)));
        displaySlice(currentSlice);
    end

    function displaySlice(sliceIndex)
        % Display the selected slice
        ImgSlice = Img3D(:, :, sliceIndex);
        
        % Use the original showImage logic to display the slice
        if ~isfield(options, "Axis")
            options.Axis = ax;
        end
        
        maxImgAbs = max(abs(ImgSlice(:)));
        if any(strcmp(options.DisplayFormat, ["MagPhase", "Animated"]))
            imagesc(options.Axis, x, y, ...
                options.PhaseMultiplier .* rad2deg(angle(ImgSlice.')), ...
                AlphaData=convertImage(ImgSlice.', options, maxImgAbs));
        else
            imagesc(options.Axis, x, y, ...
                convertImage(ImgSlice.', options, maxImgAbs));
        end
        
        axis(options.Axis, "image");
        axis(options.Axis, "xy");
        set(options.Axis, Color="k");
        setColormap(options.Axis, options, maxImgAbs);
        
        % Show colorbar if enabled
        if options.ShowColorbar
            if isfield(options, "ColorbarLabel")
                colorbarLabel = options.ColorbarLabel;
            else
                colorbarLabel = getColorbarLabel(options.DisplayFormat);
            end
            colorbarHandle = colorbar(options.Axis);
            colorbarHandle.Label.String = colorbarLabel;
        end
    end

%% Helper Functions (copied from showImage)
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
end

%% Custom Validation Function for 3D Image
function mustBeValidImageSize3D(Img3D, x, y, z)
    if all(size(Img3D, [1, 2]) == [numel(x), numel(y)]) && size(Img3D, 3) == numel(z)
        return;
    end
    throwAsCaller(MException("MATLAB:mustBeValidImageSize", ...
        "Image size (%d, %d, %d) is inconsistent with the lengths " + ...
        "of the x-, y-, and z-coordinate vectors (%d, %d, %d).", ...
        size(Img3D, 1), size(Img3D, 2), size(Img3D, 3), numel(x), numel(y), numel(z)));
end