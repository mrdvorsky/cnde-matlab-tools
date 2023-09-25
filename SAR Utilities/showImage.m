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
%   PhaseMultiplier (1) - If DisplayFormat="MagPhase", this scale factor is
%       applied to the phase before displaying.
%   ShowColorbar (true) - Whether or not to display colorbar.
%   ColorbarLabel - If specified, use as the colorbar label string.
%   Axes - If specified, use as current axes.
%
% Author: Matt Dvorsky

arguments
    x(:, 1) double;
    y(:, 1) double;
    ImgIn(:, :) double {mustBeValidImageSize(ImgIn, x, y)};
    options.DisplayFormat {mustBeTextScalar, mustBeMember(options.DisplayFormat, ...
        ["None", "Magnitude", "dB", "Phase", "Real", "Imag", "MagPhase"])} = "None";
    options.Normalize(1, 1) logical = false;
    options.NormalizeFactor(1, 1) {mustBePositive} = 1;
    options.PhaseMultiplier(1, 1) {mustBePositive} = 1;
    options.ShowColorbar(1, 1) logical = true;
    options.ColorbarLabel {mustBeTextScalar};
    options.Axes(1, 1) {mustBeA(options.Axes, "Axes")};
    
    imagescOptions.AlphaData;
    imagescOptions.AlphaDataMapping;
end

%% Normalize Image
if options.Normalize || options.DisplayFormat == "MagPhase"
    ImgIn = ImgIn ./ max(abs(ImgIn(:))) .* options.NormalizeFactor;
end

%% Convert Data
switch options.DisplayFormat
    case "None"
        if ~isreal(ImgIn)
            error(strcat("Input image must be real-valued. If complex, ", ...
                "specify the complex display format you would like to use ", ...
                "by specifying the DisplayFormat named argument."));
        end
        Img = ImgIn;
        colorbarLabel = "";
    case "Magnitude"
        Img = abs(ImgIn);
        colorbarLabel = "Magnitude (Linear)";
    case "dB"
        Img = db(ImgIn);
        colorbarLabel = "Magnitude (dB)";
    case "Phase"
        Img = rad2deg(angle(ImgIn));
        colorbarLabel = "Phase (deg)";
    case "Real"
        Img = real(ImgIn);
        colorbarLabel = "Real";
    case "Imag"
        Img = imag(ImgIn);
        colorbarLabel = "Imag";
    case "MagPhase"
        Img = ImgIn;
        colorbarLabel = "Phase (deg)";
end

%% Show Image
if ~isfield(options, "Axes")
    options.Axes = gca;
end

if options.DisplayFormat == "MagPhase"
    [varargout{1:nargout}] = imagesc(options.Axes, x, y, ...
        options.PhaseMultiplier .* rad2deg(angle(Img)).', ...
        imagescOptions, AlphaData=abs(Img).');
    set(options.Axes, "Color", "k");
    colormap(options.Axes, "hsv");
else
    [varargout{1:nargout}] = imagesc(options.Axes, x, y, Img.', ...
        imagescOptions);
    colormap(options.Axes, "jet");
end

axis(options.Axes, "image");
axis(options.Axes, "xy");

%% Colorbar
if options.ShowColorbar
    if isfield(options, "ColorbarLabel")
        colorbarLabel = options.ColorbarLabel;
    end
    
    colorbarHandle = colorbar(options.Axes);
    colorbarHandle.Label.String = colorbarLabel;
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

