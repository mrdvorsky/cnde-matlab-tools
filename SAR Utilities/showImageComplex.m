function [ varargout ] = showImageComplex( x, y, Img, varargin )
%SHOWIMAGE Shows an xy complex-valued image using color for phase

% Img = Img ./ max(abs(Img(:)));

%% Parse Inputs
p = inputParser;
addParameter(p, "PhaseMultiplier", 1);
parse(p, varargin{:});

%% Plot
[varargout{1:nargout}] = imagesc(squeeze(x), squeeze(y), ...
    squeeze(p.Results.PhaseMultiplier .* rad2deg(angle(Img))).', ...
    "AlphaData", squeeze(abs(Img)).');
set(gca, "Color", "k");
colormap hsv;
axis image;
axis xy;

end

