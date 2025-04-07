function [varargout] = getDataTipCoordinates(options)
%Get the coordinates of the current data tips in a plot.
%
% Example Usage:
%   [xc, yc] = getCursorLocations();
%   [xc, yc, zc] = getCursorLocations();        % For 3D plot.
%   [xc, yc] = getCursorLocations(FigureHandle=fig);
%
%
% Named Arguments:
%   FigureHandle (gcf()) - Figure handle on which data tips are located.
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

