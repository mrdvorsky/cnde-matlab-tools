function [varargout] = getCursorLocations(options)
%GETCURSORLOCATIONS Get values and locations of current plot cursors.
% Get locations of data cursors in current plot.
%
% Example Usage:
%   [xc, yc] = getCursorLocations();
%   [xc, yc, zc] = getCursorLocations();        % For 3D plot.
%   [xc, yc] = getCursorLocations(FigureHandle=fig);
%
% Author: Matt Dvorsky

arguments
    options.FigureHandle(1, 1) matlab.ui.Figure;
end

%% Get Cursor Locations
if isfield(options, "FigureHandle")
    fig = options.FigureHandle;
else
    fig = gcf;
end

cursorStruct = getCursorInfo(datacursormode(fig));
coord = reshape([cursorStruct.Position], [], numel(cursorStruct));

varargout = cell(max(nargout, 1));
for ii = 1:numel(varargout)
    varargout{ii} = coord(ii, :).';
end

end

