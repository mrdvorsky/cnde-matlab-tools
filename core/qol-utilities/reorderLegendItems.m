function [] = reorderLegendItems(newOrderInds, options)
%Reorder legend items in active plot.
% This function "properly" reorders the items in a plot so that the legend
% is also reordered. Useful if this is a saved plot that you can't easily
% regenerate.
%
% Example Usage:
%   reorderLegendItems([3, 1, 2]);  % Changes order from 1,2,3 to 3,1,2
%   reorderLegendItems([1, 3, 2], Axis=ax);
%
%
% Inputs:
%   newOrderInds - Array of indices for the new plot item order. If the
%       current order is 1:n, the new order will be newOrderInds(1:n);
%
% Named Arguments:
%   Axis(gca): Axis to target.
%
% Author: Matt Dvorsky

arguments
    newOrderInds(:, 1) {mustBePositive, mustBeInteger};
    
    options.Axis(1, 1) matlab.graphics.axis.Axis;
end

%% 

ax = gca;
prevLegendStrings = get(legend(), "String");
plotHandles = flip(ax.Children);
ax.Children = flip(plotHandles(newOrder));
legend(prevLegendStrings(newOrder));


end

