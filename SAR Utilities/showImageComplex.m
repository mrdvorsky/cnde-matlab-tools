function [ varargout ] = showImageComplex( x, y, Img, varargin )
%SHOWIMAGE Shows an xy complex-valued image using color for phase

% Img = Img ./ max(abs(Img(:)));

%% Parse Inputs
p = inputParser;
addParameter(p, "PhaseMultiplier", 1);
addParameter(p, "NormalizeFactor", 1);
parse(p, varargin{:});

%% Normalize
if p.Results.NormalizeFactor > 0
    Img = Img ./ max(abs(Img(:))) .* p.Results.NormalizeFactor;
end

%% Plot
[varargout{1:nargout}] = imagesc(squeeze(x), squeeze(y), ...
    squeeze(p.Results.PhaseMultiplier .* rad2deg(angle(Img))).', ...
    "AlphaData", squeeze(abs(Img)).');
set(gca, "Color", "k");
colormap hsv;
axis image;
axis xy;

end

