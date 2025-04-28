function [y] = hypotn(x)
%Generalization of the hypot function to n arguments.
% This function behaves the same as the built-in function "hypot", but it
% can take any number of input arguments. For example, "hypotn(x, y, z)"
% will be equivalent to "hypot(hypot(x, y), z)".
%
% Example Usage:
%   r = hypotn(x, y);       % Identical to "hypot(x, y)".
%   y = hypotn(x);          % Identical to "abs(x)".
%   p = hypotn(x, y, z);    % Identical to "hypot(hypot(x, y), z)".
%
%
% Inputs:
%   x1, x2, x3, ... - Arguments for which to find root sum of squares.
%
% Outputs:
%   y - Sum of squares of inputs.
%
% Author: Matt Dvorsky

arguments (Repeating)
    x;
end
mustHaveAtLeastOneRepeatingArg(x);

if isscalar(x)
    y = abs(x{1});
    return;
end

%% Calculate Output
y = hypot(x{1}, x{2});
for ii = 3:numel(x)
    y = hypot(y, x{ii});
end

end

