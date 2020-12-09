function [ ] = reorderPlotItems( varargin )
%REORDERLEGEND Reorder legend items in active plot
%   Usages: Either example usage below will transform the legend items
%   ("item1", "item2", "item3") to ("item2", "item3", "item1")
%       reorderPlotItems(2, 3, 1);
%       reorderPlotItems([2, 3, 1]);
%       reorderPlotItems 2 3 1;

try
    if nargin == 1
        newOrder = int32(varargin{1});
    elseif iscellstr(varargin) %#ok<ISCLSTR>
        newOrder = int32(str2double(varargin));
    else
        newOrder = int32(cell2mat(varargin));
    end
catch
    error("Input must be made up of unique positive integers.");
end

disp(newOrder)
assert(all(newOrder(:) > 0) && length(newOrder(:)) == length(unique(newOrder(:))), ...
    "Input must be made up of unique positive integers.");

ax = gca;
prevLegendStrings = get(legend(), "String");
plotHandles = flip(ax.Children);
ax.Children = flip(plotHandles(newOrder));
legend(prevLegendStrings(newOrder));


end

