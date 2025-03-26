function varargout = loglogs(varargin)
%PLOTS Call loglog function with squeeze called on all arguments

plotArgs = cellfun(@squeeze, varargin, 'UniformOutput', false);
[varargout{1:nargout}] = loglog(plotArgs{:});

end

