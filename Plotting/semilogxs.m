function varargout = semilogxs(varargin)
%PLOTS Call semilogx function with squeeze called on all arguments

plotArgs = cellfun(@squeeze, varargin, 'UniformOutput', false);
[varargout{1:nargout}] = semilogx(plotArgs{:});

end

