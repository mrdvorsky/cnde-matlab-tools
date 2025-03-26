function [y] = db(x)
%DB Converts input to dB units. Equivalent to '20*log10(abs(x))'.
%
% Example Usage:
%   val_dB = db(0.1);       % Returns '-20'.
%
% Inputs:
%   x - Input value.
%
% Outputs:
%   y - Input value converted to dB.
%
% Author: Matt Dvorsky

arguments
    x;
end

y = 20*log10(abs(x));

end

