function [] = plotUnitCircle()
%PLOTUNITCIRCLE Plots the unit circle and axes with proper legend visibiliy. 
% This function has a very similar behavior to calling zplane([]), except
% that the handle visibiliy is set to off. This allows a legend to be added
% without the unit circle being added as an item.
%
% Example Usage:
%   figure;
%   plot(...);
%   hold on;
%   plotUnitCircle();
%
% Author: Matt Dvorsky

[h1, h2, h3] = zplane([]);
h1.HandleVisibility = "off";
h2.HandleVisibility = "off";
h3.HandleVisibility = "off";

end

