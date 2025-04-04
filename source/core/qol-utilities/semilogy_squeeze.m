function [varargout] = semilogy_squeeze(plotArgs, options)
%Call "semilogy" function with squeeze called on all arguments.
% This function should be a drop-in replacement for the "semilogy"
% function, except that it calls squeeze on the positional arguments.
%
% Author: Matt Dvorsky

arguments (Repeating)
    plotArgs;
end
arguments
    options.?matlab.graphics.primitive.Line;
end

%% Call Plot Function
plotArgs = cellfun(@squeeze, plotArgs, UniformOutput=false);
[varargout{1:nargout}] = semilogy(plotArgs{:}, options);

end

