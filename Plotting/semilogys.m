function varargout = semilogys(varargin)
%PLOTS Call semilogy function with squeeze called on all arguments

plotArgs = cellfun(@squeeze, varargin, 'UniformOutput', false);
[varargout{1:nargout}] = semilogy(plotArgs{:});

end

