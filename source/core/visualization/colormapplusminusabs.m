function [colorMap] = colormapplusminusabs(n)
%CHRISTMAS Colormap function for images with positive and negative values.
% The function returns a colormap that is green at high values, red for low
% values, and black for middle values. This function is suitable for
% showing data that has positive and negative values, where it is desired
% to have values close to zero show up as black. Typically you should call
% "clim" to set the maximum and minimum values to be the same magntide, so
% that a value of zero corresponds to black.
%
% Example Usage:
%   colormap colormapPlusMinus;
%   clim(scale * [-1, 1]);
%
%
% Inputs:
%   n - Number of points in colormap array.
%
% Outputs:
%   colorMap - Array of size n-by-3 with RGB values.
%
% Author: Matt Dvorsky

arguments
    n {mustBeInteger, mustBePositive} = 256;
end

%% Create Colormap Array
test1 = jet(floor(0.5 * n));
test2 = jet(ceil(0.5 * n));

colorMap = [flip(test2); test1];

end

