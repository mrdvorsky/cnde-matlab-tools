function varargout = plots(varargin)
%PLOTS Call plot function with squeeze called on all arguments

plotArgs = cellfun(@squeeze, varargin, 'UniformOutput', false);
[varargout{1:nargout}] = plot(plotArgs{:});

end

